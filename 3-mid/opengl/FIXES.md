# openGL code review fixes — 2026-09-04

A sequential review of every compiled unit under `3-mid/opengl/source` (root,
`api/`, `profile/`, `platform/egl`, `lean/**`, `desk/`, `demo/`; the `attic/`
folders are not built) found the defects below. Each is recorded with the
defect, why it mattered and the fix applied. All changes are under
`3-mid/opengl/source`; nothing outside the openGL component was touched.
The `glx` and `osmesa` platform backends are unimplemented stubs and were left
as they are; only EGL is functional.

Verification is summarised at the end.


## 1. Core package

### 1.1 `height_Map` scaling looped over the wrong dimension

**File:** `opengl.adb`

`scale` ran its inner loop over `Self'Range (1)` (the rows) while using the
loop variable as the column index. A map with more rows than columns raised
Constraint_Error; one with fewer silently left its trailing columns unscaled.
`Scaled` delegates to `scale`, so both entry points were wrong. The inner loop
now uses `Self'Range (2)`.

### 1.2 `to_Vector_3_array` assumed a 1-based source

**File:** `opengl.adb`

The result is `(1 .. Self'Length)` but was indexed with the source's own index,
so any slice not starting at 1 raised or misplaced elements. It now indexes by
offset from `Self'First`.

### 1.3 Over-long asset names raised a bare Constraint_Error

**File:** `opengl.adb`

`to_Asset` sliced a 128-character buffer without a length check, so an absolute
asset path failed deep inside a slice assignment with no hint. It now raises
`openGL.Error` naming the asset and the limit.

### 1.4 `Errors.Current` was documented as returning "" when no error exists

**File:** `opengl-errors.ads`

It returns "no error" (and "" only when not debugging), which is what `log`
tests for. The comment now says so.

### 1.5 `Server.Version` dereferenced a null `glGetString`

**File:** `opengl-server.adb`

Without a current context `glGetString` returns null and the string conversion
raised `Dereference_Error`. It now raises `openGL.Error` saying no context is
current. The `a_Version` overload also gained the `Tasks.Check` the string
overload already had.


## 2. Platform (EGL)

### 2.1 The requested red bit depth was never passed to `eglChooseConfig`

**File:** `platform/egl/opengl-surface_profile.adb`

`to_egl_Attributes` emitted blue, green, luminance, alpha, alpha-mask, depth and
stencil sizes but silently dropped `Bits_red`, so neither the default 8 bits nor
any caller's request constrained the red channel. `EGL_RED_SIZE` is now emitted
like the others.


## 3. Textures and buffers

### 3.1 `Texture.enable` set wrap parameters before binding

**File:** `lean/opengl-texture.adb`

Two `glTexParameteri (…, GL_REPEAT)` calls preceded `glBindTexture`, so they
modified whichever texture had been bound previously, not the one being
enabled. Any clamp-to-edge texture (lucid images, fonts, pool textures) flipped
to repeat the next time another texture was enabled after it. `enable` now only
binds; every constructor already sets its own wrap mode.

### 3.2 The texture pool's `free` was unimplemented

**File:** `lean/opengl-texture.adb`

`Pool.free` was `raise Program_Error with "TODO"`, and `Texture.free (Object)`
dereferenced `Self.Pool`, which is null for any non-pool texture. Together with
7.1 this made impostors fatal on their second update and on destruction. `free`
now returns the texture to its size bucket (releasing the GL name if the bucket
is full), and the object form destroys a non-pool texture instead of
dereferencing null. Both zero the caller's `Name`.

### 3.3 `Pool.destroy` deallocated each list inside its own element loop

**File:** `lean/opengl-texture.adb`

`deallocate (Each)` sat inside `for i in 1 .. Each.Last`, so a bucket with two
or more unused textures dereferenced null on the second iteration, and a bucket
with none was leaked. The list is now deallocated after its loop, and the map is
cleared.

### 3.4 `to_Texture (Dimensions)` allocated no storage

**File:** `lean/opengl-texture.adb`

It set parameters but never called `glTexImage2D`, so the sized frame-buffer
constructor attached a storage-less texture and the frame buffer could never be
complete. It now allocates RGBA storage.

### 3.5 `Texture.destroy` left the name set

**File:** `lean/opengl-texture.adb`

After `glDeleteTextures`, `is_Defined` stayed True and a second destroy could
delete a name GL had re-issued to another texture. `Name` is now zeroed.

### 3.6 `set_Image` assumed 1-based image bounds

**File:** `lean/opengl-texture.adb`

Both overloads took the address of `the_Image (1, 1)`; they now use the image's
own `'First` bounds.

### 3.7 `Frame_Buffer.Texture_is` left the frame buffer bound

**File:** `lean/opengl-frame_buffer.adb`

Unlike the constructor it never rebound frame buffer 0, so later rendering went
into the FBO. It now rebinds 0.

### 3.8 `Buffer.set` only honoured `Position` when the slice was the whole buffer

**File:** `lean/buffer/opengl-buffer-general.adb`

The sub-data path required `To'Length = Self.Length`, so a `Position` above 1
overran the buffer, and a genuine partial update fell into the reallocation
branch, replacing the buffer with the slice alone. The slice is now written in
place whenever it fits, the whole buffer is replaced only for `Position = 1`,
and anything else raises `openGL.Error`. The needless copy of the slice is gone.

### 3.9 Empty vertex arrays crashed buffer creation

**Files:** `lean/buffer/opengl-buffer.ads`, `opengl-buffer.adb`,
`opengl-buffer-general.adb`

`Length` was `Positive` and `to_Buffer` took the address of `From (From'First)`,
so a zero-length array raised Constraint_Error. `Length` is now `Natural` and an
empty array creates an empty GL buffer.


## 4. Camera, culling and support

### 4.1 The cull engine died permanently past 20 000 visuals

**Files:** `lean/opengl-camera.adb`, `lean/renderer/opengl-culler-frustum.adb`

The task copied the frame's visuals into a fixed 20 000-slot array; a larger
frame raised inside the accept, the handler terminated the task, and every later
`Camera.render` raised Tasking_Error. It also assumed the slice started at 1.
The visuals are now copied to a heap array of the right size, and each frame's
culling runs under its own handler which logs, drops the frame and carries on.
The frustum culler's result buffer is now sized by length rather than range.

### 4.2 `Camera.define` left the projection uninitialised

**File:** `lean/opengl-camera.adb`

`current_Planes` (used by the culler) read an uninitialised projection until
`Viewport_is` was called. `define` now builds the projection from the default
field of view, aspect and planes.

### 4.3 `Visual.face_Count_is` took Natural for a Positive field

**Files:** `lean/opengl-visual.ads`, `lean/renderer/opengl-impostorer.adb`

`face_Count_is (0)` raised. The field, and the impostorer's copy of it, are now
Natural.

### 4.4 Texture-coordinate generation assumed 1-based input and non-zero extents

**File:** `lean/opengl-texture-coordinates.adb`

`to_Coordinates (Vector_2_array)` indexed the result with the input's index and
divided by the half extents, so a slice not starting at 1 raised and a
degenerate extent produced infinities. It now indexes by offset and maps a zero
extent to the middle.

### 4.5 The palette's random generator was shared across tasks

**File:** `lean/opengl-palette.adb`

`discrete_Random` generators are not task safe. The generator now lives in a
protected object.

### 4.6 Terrain tiling lost the last row or column of large heightmaps

**File:** `lean/opengl-terrain.adb`

Tiles advance by `Tile - 1` samples (they share an edge) but the tile count was
`1 + (N - 1) / Tile`, so heightmaps such as 510 or 764 samples across dropped
their last row or column. The count now uses the real stride. The texture
offset of each row of tiles was also `(Row - 1) × depth of this tile`, wrong for
a short final row; it now accumulates the depths of the rows above it.


## 5. Shaders and programs

### 5.1 `attribute_Location` leaked its C string on the error path

**File:** `lean/shader/opengl-program.adb`

The `free` sat after the `raise`; it now precedes it.

### 5.2 Programs defined from files never released their shaders or caches

**Files:** `lean/shader/opengl-program.ads`, `opengl-program.adb`,
`opengl-program-lit.ads`, `opengl-program-lit.adb`

`define (files)` heap-allocated two shaders that `destroy` neither destroyed nor
freed, and the uniform caches were never freed. A program now records that it
owns its shaders, `destroy` destroys and frees them and the base cache, and
`Program.lit` overrides `destroy` to free its own cache.

### 5.3 The skinned programs looked up a sampler uniform that no shader declares

**Files:** `lean/shader/opengl-program-lit-colored_skinned.*`,
`-textured_skinned.*`, `-colored_textured_skinned.*`

Each `set_Uniforms` looked up `sTexture` (or `Texture`) by name on every draw.
The review flagged this as a per-draw cost; running the models demo showed it
was worse: no shader declares such a sampler (all texturing goes through the
texturing snippet's `Textures[16]` array set by the geometry mixin), so the first
draw of any skinned model would have raised `openGL.Error`. The lookups and the
`set_Uniforms` overrides are removed; the parent's `set_Uniforms` does the work.

### 5.4 The light array had a silent 50-light cap

**File:** `lean/shader/opengl-program-lit.adb`

`Lights_are` raised a bare Constraint_Error above 50 lights; it now raises
`openGL.Error` naming the limit.

### 5.5 `Attribute.destroy` never freed the name

**File:** `lean/shader/opengl-attribute.adb`

It now deallocates the attribute's name string.


## 6. Geometry

### 6.1 `Label_is` kept the tail of a longer previous label

**File:** `lean/geometry/opengl-geometry.adb`

It used `overwrite`, so `Label_is ("Long name")` then `Label_is ("Foo")` gave
"Foo name". It now assigns the new label.

### 6.2 Triangle-fan normals used vertex 1 as the fan centre

**File:** `lean/geometry/opengl-geometry.adb`

`any_vertex_Id_in` returned the literal vertex id 1 for the first point of a fan
facet instead of the fan's first index. It now returns `Indices (Indices'First)`.

### 6.3 Normals could not be computed for models above 65 535 vertices

**Files:** `lean/geometry/opengl-geometry.ads`, `opengl-geometry.adb`

`Normals_of` was only available for `Index_t`-indexed sites, and the facet
tables stored `Index_t` vertex ids. The facet and normal generics are now
parameterised on the site index type as well, and a third `Normals_of` takes
`long_Indices` with `many_Sites` and returns `many_Normals`. (See 7.6.)

### 6.4 The texturing mixin shared one uniform set between programs

**Files:** `lean/geometry/opengl-geometry-texturing.ads`, `.adb`, and the
textured, colored_textured, lit_textured, lit_colored_textured,
lit_textured_skinned and lit_colored_textured_skinned geometries

Each mixin instance held a single package-level set of uniform locations, filled
by whichever program was defined last. `lit_colored_textured` owns two programs
(RGBA and alpha/text), so text and textured models in one scene set their
texture uniforms at the other program's locations, working only while both
shaders happened to agree. Uniform sets are now created per program
(`texturing.new_Uniforms`) and each geometry is given its program's set
(`Mixin.Uniforms_are`). The two skinned textured geometries never created their
sets at all; they now do so when their programs are defined.

### 6.5 `texturing.enable` left the active texture unit on the last unit used

**File:** `lean/geometry/opengl-geometry-texturing.adb`

It now reselects unit 0 after binding, so code that binds without choosing a
unit is unaffected by the preceding multi-textured model.

### 6.6 Re-setting vertices leaked the previous vertex buffer

**Files:** textured, colored_textured, lit_textured and the three skinned
geometries

`Vertices_are` allocated a new buffer object over the old one. The previous
buffer is now freed first, as `colored` and `lit_colored` already did.

### 6.7 Seven geometries overrode the working `Indices_are` with a `raise`

**Files:** textured, colored_textured, lit_textured, lit_colored_textured and
the three skinned geometries

The base implementation (through `Primitive.indexed`) works; the overrides
replaced it with `raise Error with "TODO"`. They are removed.

### 6.8 The "Shine" attribute was declared as four floats

**Files:** `opengl-geometry-lit_colored_skinned.adb`,
`opengl-geometry-lit_colored_textured_skinned.adb`, `opengl-geometry-lit_colored.adb`

`Size => 4` for a single `Real` read into the following bone ids (GL used the
first component, so it worked by accident); `lit_colored` also asked for
normalisation of a float. Both are now `Size => 1`, un-normalised.

### 6.9 Non-indexed primitives ignored their line width

**File:** `lean/geometry/opengl-primitive-non_indexed.adb`

`render` skipped the base-class render which applies `line_Width`; it now calls
it like the indexed primitives.


## 7. Models

### 7.1 The textured box applied the front face's texture to five faces

**File:** `lean/model/opengl-model-box-textured.adb`

Rear, Upper, Lower, Left and Right each tested their own texture name but then
fetched `Faces (Front).texture_Name`, so every textured box and skybox showed the
front texture all round. Each face now fetches its own.

### 7.2 Hexagon columns were built flat

**Files:** `lean/model/opengl-model-hexagon_column.ads` (new body `.adb`) and
all six `opengl-model-hexagon_column-*.adb`

`hexagon.vertex_Sites` produces a hexagon in the XY plane (normal +Z), but the
column models offset those vertices along Y and computed shaft normals by
rotating about Y, i.e. they assumed an XZ hexagon. Everything ended up in the
plane z = 0. The parent package now provides `cap_Sites` (the hexagon turned
into the XZ plane, still anti-clockwise from above), `facet_Normals` and
`vertex_Normals`; the cap normal is ±Y; the six bodies use them instead of their
own rotation code. The columns now stand along Y as intended (verified visually).

### 7.3 Faceted columns ignored the `Lower` face

**Files:** `opengl-model-hexagon_column-lit_colored_faceted.adb`,
`-lit_colored_textured_faceted.adb`, `-lit_textured_faceted.adb`

The lower cap was built from `upper_Face` colours, and the lower texture was
guarded by the *upper* face's texture name (fetching `null_Asset` when only the
upper was textured, or never texturing the lower). The lower cap now uses
`lower_Face` throughout, as the rounded columns already did.

### 7.4 Hexagon caps had placeholder texture coordinates

**Files:** `opengl-model-hexagon-lit_colored_textured.adb` and the four
textured column bodies

Three corners mapped to the same texel and the centre to a corner. They now use
the proper hexagon mapping already used by `hexagon.lit_textured`.

### 7.5 `hex_grid` mis-centred the grid and never averaged shared heights

**File:** `lean/model/opengl-model-hex_grid.adb`

`max_Site` was computed with `Real'Max (min_Site …)`, and the centre was the
half extent `(max - min) / 2` rather than the midpoint. The per-vertex height
"average" added the current hex's height `shared_Count` times, so the last hex
visited won and the intended smoothing never happened. All three are fixed.

### 7.6 `Model.any` capped every model at 65 535 triangles, even on the Desk profile

**File:** `lean/model/opengl-model-any.adb`

`tri_Count` was `Index_t` and the computed normals were indexed with `Index_t`,
both raising above 2^16 and making the long-index branch (the point of the Desk
profile) unreachable; unique vertices were also capped at a hard 100 000. The
triangle count is now `long_Index_t`, normals use the new wide `Normals_of`
(6.3), and the vertex table is sized from the model's face vertex count.

### 7.7 `Model.any` forced lucid-textured models into the opaque pass

**File:** `lean/model/opengl-model-any.adb`

`is_Transparent (False)` ignored `has_lucid_Texture`; the flag is now used.

### 7.8 The colored sphere was drawn at half its radius

**File:** `lean/model/opengl-model-sphere-colored.adb`

Its vertices were scaled by `Radius` where every other sphere scales by
`Radius × 2` (the poles are at ±0.5), while its bounds claimed the full radius.

### 7.9 The textured sphere reversed its winding unconditionally

**File:** `lean/model/opengl-model-sphere-textured.adb`

The pair-swap that turns the sphere inside out ran regardless of
`is_Skysphere`, which was stored but never read. It now runs only for sky
spheres.

### 7.10 Sphere texture transparency was overwritten

**Files:** `opengl-model-sphere-lit_colored_textured.adb`,
`opengl-model-sphere-lit_textured.adb`

The texture-based transparency was set before `Vertices_are`, which resets the
flag (and `lit_colored_textured` then forced it to False). The texture is now
applied after the vertices and combined with the colour-based result.

### 7.11 A two-point segment line rendered nothing

**File:** `lean/model/opengl-model-segment_line.adb`

`to_GL_Geometries` returned nothing for two points or fewer, so the first segment
was invisible until a third point arrived. The test is now `< 2`.
`Angle_in_xz_plane` also used the one-argument arctangent (losing the quadrant
and dividing by zero for vertical segments); it now uses the two-argument form.

### 7.12 The xz-plane billboard ignored its height

**File:** `lean/model/opengl-model-billboard.adb`

Its z extents were the literals ±1.0; they are now ±half the height.

### 7.13 Rebuilding freed geometries the models still referenced

**Files:** `opengl-model-grid.adb`, `opengl-model-line-colored.adb`,
`opengl-model-arrow-colored.adb`, and the `modify` procedures of the arrow and
the two colored billboards

`Model.create_GL_Geometries` frees the previous geometry list after
`to_GL_Geometries`. Grid and line returned the geometry they already held (a
use after free on rebuild), and the arrow freed its geometry itself first (a
double free). They now create a fresh geometry per build. `modify` and
`line.Site_is` also guard against a geometry that does not exist yet.

### 7.14 `Text_is` leaked the previous string

**File:** `lean/model/opengl-model-text-lit_colored.adb`

The old text is now freed before the new one is allocated.

### 7.15 The textured billboard leaked a GL texture per rebuild

**Files:** `lean/model/opengl-model-billboard-textured.ads`, `.adb`

Every rebuild loaded a new texture from the asset name without releasing the
previous one. The model now records whether it owns its texture, releases it
before reloading, and destroys it with the model; a texture supplied through
`Texture_is` (as the impostors do) is left to its owner.

### 7.16 Circles, lit-textured hexagons and polygons were always lucid

**Files:** `opengl-model-circle-colored.adb`, `opengl-model-circle-lit_textured.adb`,
`opengl-model-hexagon-lit_textured.adb`, `opengl-model-polygon-lit_textured.adb`

A forced `is_Transparent (True)` ("TODO: do transparency properly") overrode the
value just computed from the colours or texture. The forced line is removed.

### 7.17 The textured polygon generated a centroid vertex it never used

**File:** `lean/model/opengl-model-polygon-lit_textured.adb`

The fan now uses the centroid (with its 0.5/0.5 texture coordinate) as its
centre instead of the first rim vertex.

### 7.18 A default texture set held uninitialised details

**File:** `lean/opengl-texture_set.ads`

Found while running the boxes demo: `box.lit_colored_textured` (and others)
never set their texture details, and `Detail` had no component defaults, so
`texturing.enable` read whatever the heap held as a fade level — a validity
failure once allocation patterns changed. The components now default to no
texture, no fade, unit tiling and not applied.


## 8. Renderer and impostors

### 8.1 Impostors could not survive a second update

**File:** `lean/renderer/opengl-renderer-lean.adb` (with 3.2)

The "texture needs resizing" test compared the raw pixel size with the texture
size, but textures are allocated at the power-of-two ceiling, so the test was
true on nearly every update and each one called the unimplemented pool `free`.
The test now compares against the power-of-two size. Impostors are not enabled
by any shipped program (the one call is commented out in a demo), so this was
latent.

### 8.2 Transparent geometry was sorted by world Z, not camera depth

**Files:** `lean/renderer/opengl-renderer-lean.ads`, `.adb`

The lucid sort key was the visual's world translation z (the comment claimed
camera space), correct only for an unrotated camera looking down −Z. Each
couple now carries the visual's camera-space depth, computed once when it is
collected, and the sort uses that.

### 8.3 The viewport was one pixel short in each dimension

**File:** `lean/renderer/opengl-renderer-lean.adb`

`Camera.Viewport_is` stores `Max := Width - 1` (an inclusive coordinate) but the
renderer passed `Max` as the extent. It now passes `Max - Min + 1`.

### 8.4 The engine left `is_Busy` set after an exception, and a repeated font killed it

**File:** `lean/renderer/opengl-renderer-lean.adb`

A client polling `is_Busy` after an engine failure spun forever; the handler
now clears it. Adding a font that was already present raised Constraint_Error
inside the engine; it is now skipped.

### 8.5 Unguarded 20 000-slot update queues

**File:** `lean/renderer/opengl-renderer-lean.adb`

Overflowing the per-camera visual or impostor queue raised a bare
Constraint_Error inside a protected operation; it now raises
`buffer_Overflow` with a message (and the cull engine survives it, see 4.1).

### 8.6 The impostorer kept a 20 000-element update array on the cull task's stack

**File:** `lean/renderer/opengl-impostorer.adb`

About 1.6 MB per frame on a default task stack. The array is now heap
allocated, sized to the frame's visuals, and freed after queuing.


## 9. Text

### 9.1 `Advance` and `render` skipped the last character

**File:** `lean/text/private/opengl-fontimpl.adb`

Both required `nextChar /= NUL` before checking the glyph, so the last
character of a string was neither measured nor loaded (the C++ original checks
unconditionally). `render` also rendered every glyph at the initial position
rather than the running pen, and both assumed `Text'First = 1`. All three are
fixed.

### 9.2 The font texture was cleared with an RGB image uploaded as alpha

**File:** `lean/text/private/opengl-fontimpl-texture.adb`

`CreateTexture` built a three-byte-per-texel `Image` on the stack (up to 3 MB)
and passed it as `GL_ALPHA` data. It now uses a one-byte `grey_Image` on the
heap.

### 9.3 Null-glyph dereferences

**Files:** `lean/text/private/opengl-fontimpl.adb`,
`opengl-fontimpl-texture.adb`, `lean/text/opengl-glyph-container.adb`

The in-memory font constructor did not raise on failure (leaving the glyph list
null), `Quad` dereferenced a glyph that failed to load, and
`Container.Advance` dereferenced an unloaded glyph. Each now raises
`openGL.Error` with the character or cause.


## 10. IO

### 10.1 `current_Frame` had transposed bounds and misaligned rows

**File:** `lean/io/opengl-io.adb`

The image was declared `(Width, Height)` where every other image is
`(Height, Width)`, and `glReadPixels` ran with the default 4-byte pack
alignment, so rows were padded unless the width was a multiple of 4. The bounds
are corrected and the pack alignment set to 1.

### 10.2 Collada polygons with more than four vertices added a garbage face

**File:** `lean/io/opengl-io-collada.adb`

The unhandled case logged a warning but still appended the uninitialised
`the_Face`. It now stores a proper `Polygon` face (which `Model.any` skips).

### 10.3 AVI frame size ignored row padding

**File:** `lean/io/opengl-io.adb`

`bmp_size` was `width × height × 3` while `write_raw_Frame` writes rows padded to
four bytes, corrupting captures whose row size is not a multiple of four. The
size now includes the padding.

### 10.4 Wavefront element limits raised a bare Constraint_Error

**File:** `lean/io/opengl-io-wavefront.adb`

Exceeding the fixed face, site, coordinate or normal tables now raises
`Model_too_complex` naming the file and the limit.


## 11. Demo support

### 11.1 `Demo.layout` placed a fixed 21 visuals

**File:** `demo/opengl-demo.adb`

`Models` returns 24, so the last three sat at the origin, and fewer than 21
raised. It now lays out any number, five per row.


## Verification

- `gprbuild -P 3-mid/opengl/library/opengl.gpr` (lean/EGL), the same with
  `-Xopengl_profile=desk`, and `opengl_demo.gpr` all build. A forced rebuild
  before and after the changes shows no new warnings (one removed:
  `openGL.API` was unreferenced in the colored-skinned program).
- The whole stack (`5-all/applet/build_all`) builds against the changed API.
- Demos run without exceptions for their full timeout: `render_models`,
  `render_boxes`, `render_hex_grid`, `render_billboards`, `render_capsules`,
  `render_text`, `render_screenshot`. Running them is what surfaced 5.3 and
  7.18.
- A screenshot of every demo model (via `openGL.Demo.Models`) shows the
  textured box textured on all faces, the colored sphere at its true radius,
  and both hexagon columns standing along Y.
