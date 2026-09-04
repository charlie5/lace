# collada: review findings and fixes

A sequential review of the collada component (2026-09-05) found 1 HIGH,
9 MEDIUM and 12 LOW defects. The HIGH one and the first MEDIUM were
hotfixed on master the same day (`fb714ac`); the rest are fixed here, except
the ones listed under "Not changed". The users, `openGL.IO.collada`,
`gel.Rig` and `gel.Human`, are adapted.

Two decisions were taken:

- A document can be freed. `collada.Document.destroy` walks the four
  libraries; each library package has a `destroy` and `collada.Library`
  frees sources and inputs. A document copy shares its contents, so exactly
  one copy is destroyed.
- The parser is strict about what it cannot model and lenient about what
  the spec makes optional. A missing required attribute or child raises
  `collada.Error` naming the element and its id; optional ones take the
  spec's defaults; an unsupported construct that would change the result
  (`lookat`, `skew`, `instance_node`, a `morph` controller, a `convex_mesh`,
  an `int_array` source) raises `collada.Error` instead of being skipped;
  metadata (`asset`, `extra`, cameras, lights) is ignored silently. The
  library no longer prints anything.

Severity: **HIGH** = wrong result, crash or memory unsafety on a path a
shipped asset exercises; **MEDIUM** = wrong result on a common path or a
hazard one call away; **LOW** = latent, edge case or API trap.


## 1. Array parsing (collada-document.adb)

- **H1** The tokenisers split on the space character only, so a number
  followed directly by a line break raised `Constraint_Error`; the xml fix
  of the same day, which keeps line breaks, exposed it on the human model.
  One generic scanner splits at any run of space, tab, line feed or
  carriage return. *(hotfix)*
- **M1** The tokenisers built their result in 500 000-element stack
  arrays, a cap and a stack hazard. The scanner counts first and returns
  exactly that many. *(hotfix)*
- **L8** The `count` attribute of every array is now checked against the
  number of values parsed, and an empty text yields an empty array for
  integers as it did for reals.


## 2. The scene graph

- **M2** Only the first top-level `<node>` of a visual scene was parsed.
  `visual_Scene.root_Nodes` now holds all of them in document order.
  `gel.Rig` and `gel.Human` take the first, as they did.
- **M6** The library printed "TODO" lines to standard output for every
  `instance_geometry`, `extra`, `instance_camera` and `instance_light`. A
  node now records the id of the geometry or controller it instances
  (`Instance`) and the skeleton root of an instanced controller
  (`Skeleton`); `asset`, `extra`, `instance_camera` and `instance_light`
  are ignored; `lookat`, `skew`, `instance_node` and anything else raise
  `collada.Error`.
- **M8** `Child (Named)` raised `Constraint_Error` for "not found" and
  searched descendants by catching it at every level; `Child (Which)`
  raised for "no children". Both return null now, and the descendant
  search is a plain loop; the spec says it searches descendants.
- **L1** `skeletal_Root` was overwritten by every `instance_controller`; it
  now keeps the first, and each node carries its own `Skeleton`.
- **L2** The five unused lookups in `to_Node` are gone.
- **L7** `Rotate_X/Y/Z` and `set_*_rotation_Angle` tried `rotationX` and
  then `rotateX` through exception handlers; one `find_Rotation` accepts
  both sids. `find_Transform` and `fetch_Transform` no longer dereference
  a null transform array. `Scale`'s local was called `the_Translation`.


## 3. Sources, controllers and animations

- **M3** Nothing freed a document, so every model load leaked it.
  `collada.Document.destroy` and the library `destroy`s free everything;
  `openGL.IO.collada.to_Model` destroys the document once it has copied
  the geometry, also on an exception; `gel.Rig` keeps its document, since
  its joints are the document's nodes, and gains a `destroy` that frees it.
  `gel.Human` keeps its global document as before.
- **M4** Nested animations lost all but the first child per container and
  a container without a sampler dereferenced null. The parser now gathers,
  recursively, every `<animation>` that has a sampler, however exporters
  nest them.
- **M5** `to_Source` ignored `IDREF_array`, so the human model's joint names
  were null and `joint_Names_of` would dereference null. `IDREF_array` is
  read like `Name_array` (the human model now yields its 82 joint names);
  `int_array`, `bool_array` and `SIDREF_array` raise `collada.Error`;
  `joint_Names_of` raises `collada.Error` with the source id when the
  joint source has no names.
- **M7** `to_Time` swallowed `Constraint_Error` and returned `Clock`. It
  parses ISO 8601 with optional fractional seconds and a `Z` or `±hh:mm`
  zone, and yields the new `collada.Asset.unknown_Time` (1901-01-01) for
  anything else, which is also the default when the document gives no date.
- **M9** Optional parts were dereferenced as if required. `sid` on
  `translate`, `rotate` and `scale` defaults to empty like `matrix`'s;
  `unit`'s `name` and `meter` default to "meter" and 1.0 (also the record
  defaults); `asset`, `skeleton` and `name` attributes are optional; a
  geometry without a `mesh`, a controller without a `skin`, a source
  without an `id`, an input without `semantic` or `source`, and a missing
  `vertices`, `vcount`, `p`, `joints`, `vertex_weights`, `sampler` or
  `channel` raise `collada.Error` naming the element and id.
- **L3** The five `*_Offset_of` functions now all raise
  `collada.Library.Input_not_found` for a missing input, through one
  `Offset_of`; `no_coord_Offset` is gone.
- **L4** `Source_of`, `Inputs_view` and `Int_array_view` are declared once
  in `collada.Library`; the three copies and the `"+"` renamings are gone.
- **L5** `bind_shape_Matrix_of` and `bind_Poses_of` use `get_Matrix`;
  `collada.Identity_4x4` is gone in favour of `math.Identity_4x4`.
- **L10** The `<scene>` element is read: `Document.Scene` is the id of the
  instantiated visual scene.
- **L11** An unknown input semantic yields `Unknown` instead of raising.


## 4. Style and nits (L9, L12)

- "hierachy" and "colada" are spelt; the mixed-case `the_document.asset`
  references are consistent; `ada.Text_IO` is no longer withed; the demo
  calls its document a document and destroys it.
- `Input_t` keeps its `_t`: `Input` is an enumeration literal of
  `Semantic` in the same package.


## Not changed

- `Node.add` still reallocates its arrays on every add (L6); nodes have a
  handful of children and transforms.
- `gel.Human` keeps one global document for the life of the program, as
  its "tbd: free this at app close" comment says.


## Verification

- collada, its demo and `build_all` build warning-free.
- A scratch program parses all 28 collada assets in the tree, prints the
  count and checksum of every parsed number array, and destroys each
  document. Every checksum is identical to the pre-review baseline, the
  human model parses (it failed before the hotfix) and yields its 82 joint
  names, and no destroy faults.
- The `parse_box` demo runs silently and exits cleanly.
- The gel box rig renders pixel-identical, run to run and against the
  render made before these fixes.
