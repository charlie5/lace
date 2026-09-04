# xml: review findings and fixes

A sequential review of the xml component (2026-09-05) found 2 HIGH, 7 MEDIUM
and 8 LOW defects in the element tree (`xml`), the expat binding
(`xml.Reader`) and the writer (`xml.Writer`). All are fixed here except the
ones listed under "Not changed". The only user of the tree API,
`collada.Document`, is adapted.

Two decisions were taken:

- The tree is reference-based. `Element` is limited, `to_XML` returns an
  `Element_view` to the document element itself (the nameless root that
  used to wrap it is gone), and `xml.free` releases a tree.
- The reader parses a file in one call from a heap buffer holding the whole
  file, instead of line by line through an 800 KB stack buffer.

Severity: **HIGH** = wrong result, crash or memory unsafety on a path
collada exercises; **MEDIUM** = wrong result on a common path or a hazard one
call away; **LOW** = latent, edge case or API trap.


## 1. The tree (xml.ads, xml.adb)

- **H1** Character data lost its line breaks. The file was read with
  `get_Line`, which drops the terminator, and each line was handed to expat
  as a chunk, so `<nums>1.0⏎2.0⏎3.0</nums>` read back as `"1.02.03.0"`.
  Every shipped collada asset with wrapped arrays (only
  `gel/applet/assets/collada/mh-human-dae.dae`) survived because its
  exporter left a trailing space on each wrapped line. `to_XML` now reads
  the whole file into a heap string with one `Stream_IO.read` and parses it
  in one call.
- **H2** The document element's `Parent` pointed at a dead stack frame: the
  local root was the parent of the top-level elements and was then returned
  by copy. The tree is now built on the heap and `to_XML` returns the
  document element, whose `Parent` is null.
- **M1** `Attributes` and `Attribute` dereferenced a null attribute view
  (the old root had none) and raised `Constraint_Error`. Both now treat a
  null view as empty; `no_Attributes` is provided.
- **M2** Nothing was freed: the `Parser_Rec`, the expat parser (never
  `XML_ParserFree`d), every element and attribute array. `xml.free` walks
  and frees a tree, `xml.Reader.free` frees a parser, `to_XML` frees its
  parser and text buffer, and `collada.Document.to_Document` frees the tree
  once it has converted it, also on an exception.
- **M3** Errors carried nothing and left things open. `parse_Error` (now
  declared in `xml`) carries "`file: line L, column C: expat message`";
  `to_XML` closes and frees on any exception; an empty file no longer
  raises `End_Error` from `get_Line` but reports "no element found".
- **M7** `add_Child` did not set the child's `Parent`; it does, and
  `to_XML` builds the tree through it.
- **L6** `Element` was a non-limited record with access components, so a
  copy shared children while duplicating data. It is limited now and only
  ever handled through `Element_view`; `Elements` and `Child` use the named
  view type.
- **L7** `Data` of a container element was its indentation whitespace.
  When an element ends, whitespace-only data is dropped, so `Data` is `""`
  for elements holding only children. Data with any non-whitespace is kept
  whole, line breaks included.


## 2. The expat binding (xml-reader.ads, xml-reader.adb)

- **L1** The attribute view given to a start handler was freed on return.
  The handlers now take `Attributes_t` built on the stack (and `String`
  names and data rather than `unbounded_String`); nothing is allocated per
  callback.
- **L2** `XML_Char` was declared `unsigned_short`; expat's is `char`. The
  type is gone; `XML_ParserCreate` takes a `chars_ptr`.
- **L3** `parse` copied the text twice (`To_C`, `New_Char_Array`). It
  passes the string's address and length to `XML_Parse`. The unused
  `XML_STATUS_ERROR` constant is gone.
- **L5** An exception raised in a user handler unwound through expat's C
  frames. The internal handlers now catch it, save the occurrence in the
  parser, and stop expat with `XML_StopParser`; `parse` re-raises it after
  `XML_Parse` returns.
- The expat imports are gathered at the top of the body; `Create_Parser`
  is `new_Parser`.


## 3. The writer (xml-writer.ads, xml-writer.adb)

- **M4** Nothing was escaped and text could not be written. Attribute
  values escape `& < > "`, and the new `put` writes character data escaping
  `& < >`. Data put directly after a start tag stays on the tag's line, so
  `<gollum>My &lt;precious&gt; &amp; mine!</gollum>` is written as one line.
- **M5** Attribute arrays leaked and `"&"` freed its left operand. The
  writer takes `Attributes_t` by value; `"+" (Name, Value)` returns an
  `Attribute_t`, and attribute lists are ordinary aggregates:
  `["hobbit" + "true", "ring" + "1"]`. `MkAtt`, the view-returning `"+"`
  overloads and both `"&"` are gone.
- **M6** Indentation depth was one uninitialised package global shared by
  every file. The writer is now a type, `xml.Writer.item`, holding the file
  and its depth; `start_Document` takes a `File_access`, and
  `end_Document` raises `unbalanced_Error` if elements are still open, as
  does `finish` with none open.


## 4. Style and nits (L8)

- `Create_Parser`, `The_Parser`, `Is_Final`, `Start_Handler`,
  `End_Handler`, `CD_Handler`, `XML_Parse_Error`, `MkAtt`, `ByeBye`,
  `N_Atts`, `AttAdd`, `AA_Size` and `F` are renamed to house casing.
- "Hierachy" is spelt.
- The commented-out `pragma Linker_Options` and the stray `-g` in the
  gpr's `Linker_Options` are gone.
- The `outline` demo, which feeds the parser a line at a time on purpose,
  puts the terminator back on each line and frees its parser; the `tree`
  demo frees its tree; the `write` demo shows attributes, text and escaping.


## Not changed

- `Attribute_t` and `Attributes_t` keep their `_t` suffix: `Attribute` is
  also the name of the element's lookup function, which collada calls.
- Handlers still need `'unrestricted_Access` for nested procedures; that is
  inherent to library-level access-to-subprogram types (L4).
- collada's `to_Document` raises `collada.Error` when the document element
  is not `COLLADA`, where it used to dereference null.


## Verification

- The library, the three demos, collada and `build_all` build warning-free.
- A dump of every element, attribute and data string of all 31 collada
  assets in the tree was taken before and after. After dropping the 2 890
  whitespace-only data strings and normalising line breaks, all 31 are
  identical, and the human model's ten wrapped arrays now keep their line
  breaks.
- A scratch test checks a multi-line data element, entity decoding, the
  document element's null parent, attribute lookup on the document
  element, `free`, the messages for an empty, a malformed and a missing
  file, and an exception raised inside a handler.
- The gel box rig, loaded through collada, renders pixel-identical with the
  previous and the new xml library.
