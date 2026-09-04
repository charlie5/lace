# math: review findings and fixes

A sequential review of every unit under `1-base/math/source` (2026-09-04)
found no HIGH, 9 MEDIUM and 19 LOW defects plus two design questions. All
are fixed here. The design decision, made by Rod, was to keep the row-vector
convention which the 4×4 transforms and openGL already use, and to make the
3×3 rotation constructors match it. Sections 1 and 2 cover that change and
its consequences elsewhere in lace; the rest are ordinary fixes.

Severity: **MEDIUM** = wrong result on a common path or a hazard one call
away; **LOW** = latent, edge case or API trap.


## 1. One rotation convention (DESIGN, and MEDIUM M6, M7, M9; LOW L10, L12)

Before: `d2.to_rotation_Matrix` produced a row-vector matrix (`Site * M`
turns counter-clockwise) while every 3D constructor (`x/y/z_Rotation_from`,
`to_Rotation`, `to_Matrix (Quaternion)`, `to_Quaternion (Matrix)`, the
`z_Up_to_y_Up` constants and the cached `fast_Rotation`) produced a
column-vector matrix, so `Site * M` turned *clockwise*. Both `Site * M` and
`M * Site` are exported, callers chose by habit, and the test suite asserted
both senses. Four review findings were symptoms of this.

Now every rotation is row-vector convention: a site is rotated with
`Site * Rotation`, and `A * B` applies A first. Changed in
`any_math-any_algebra-any_linear-any_d3.adb/.ads`:

- `x_Rotation_from`, `y_Rotation_from`, `z_Rotation_from` transposed.
- `to_Matrix (Quaternion)` transposed; `to_Quaternion (Matrix)` (in
  `any_linear.adb`) reads the transposed elements, so matrix ↔ quaternion
  round trips and quaternion ↔ axis/angle stay consistent.
- `to_Rotation (Euler)` is now `xyz_Rotation (Angles)`, which is what its
  comment always said: X first, then Y, then Z (L10).
- `z_Up_to_y_Up` / `y_Up_to_z_Up` swapped so `Site * z_Up_to_y_Up` converts.
- `Look_at` returns a real view matrix: axes as columns and translation
  `-Eye * Rotation`, so `Site * Look_at (...)` maps world to camera (L8: the
  translation row was the raw `-Eye`). The camera's orientation is
  `inverse_Rotation (get_Rotation (Look_at (...)))`.
- `Transform_3d` operators are row convention (M7): `Site * Transform`
  rotates then translates exactly like `Site * to_transform_Matrix
  (Transform)`; `Transform_1 * Transform_2` applies the first first;
  `Invert` and `inverse_Transform` match. The column-form
  `"*" (Transform_3d, Vector_3)` is gone.
- 2D `Invert` and `inverse_Transform` (M6, `any_d2.adb`) now invert the 2D
  `"*"`: `(Site - T) * Transpose (R)`. Before they applied the transpose with
  the column product, which rotates the wrong way for the row-convention 2D
  matrix, so `inverse_Transform (T, Site * T)` gave the site rotated by 2θ.
- `any_fast_Rotation.to_Matrix_2x2` transposes the cache's column-form
  matrices (L12), so `Site * fast_Rotation.to_Rotation (θ).all` agrees with
  `Site * d2.to_rotation_Matrix (θ)`.
- Duplicates removed (DESIGN D2, M9): `any_d3.to_Quaternion (Matrix)` and the
  d3 quaternion product `"*"` were copies of the parent `any_linear`
  operations, and `set_from_Matrix_3x3` was a third copy with the opposite
  sign convention (it produced the conjugate). `set_from_Matrix_3x3` now
  calls `to_Quaternion`; the parent's operations are the only ones. Clients
  which `use`d only `...linear.D3` need `use ...linear` as well (done in gel:
  `gel-rig.adb`, `gel-human_v1.adb`, `gel-world-client.adb`,
  `gel-world-server.adb`; `gel-rig.ads` now spells its identity quaternion
  as a literal).

The `Rotations` section of the d3 spec documents the convention.

Tests: `rotation_Matrix_Test` (3D) expectations flipped to counter-clockwise;
new `rotation_Convention_Test` (each constructor, Euler order, matrix ↔
quaternion round trip, `set_from_Matrix_3x3`, zero axis, up-axis constants),
`transform_Consistency_Test` (record vs 4×4, inverse, composition),
`look_at_Test`, 2D `inverse_transform_Test` and `fast_rotation_Test`.


## 2. Consequences for openGL, physics and gel

Every consumer of the transposed constructors was found by grep and dealt
with so that the visible behaviour of the stack is unchanged.

- **physics boundary** (`bullet-object.cpp`, `box2d-object.cpp`): bullet
  rotates column vectors and its 3×3 basis was copied row-for-row, while the
  4×4 `Transform` already crossed via `getOpenGLMatrix` in row convention,
  so a sprite's `Spin` was the transpose of `get_Rotation (Transform)`.
  `Spin`/`Spin_is` now transpose at the boundary, and box2d's `Spin_is`
  reads the angle from `m01` (the rotated x axis is row 1). A `Spin` is now
  a lace-convention matrix on both sides.
- **gel** (`gel-sprite.adb`): `interpolate` no longer transposes
  `to_Matrix (Quaternion)` before `Spin_is` (it was compensating for the old
  matrix, and then handing bullet the inverse); `rotate` composes its spin
  delta in row order (`Inverse (old) * new`, children `Spin * delta`,
  offsets `offset * delta`). `gel-any_joint.adb` expresses pivots and axes
  in row order, `gel-rig.adb` composes a bone's rotation with the base spin
  in row order, and `gel-dolly-following.adb` moves along the camera's axes
  with `Vector * Spin` (it used `Spin * Vector`, i.e. the inverse rotation).
- **openGL**: `opengl-model-hexagon.adb` uses `Site * Rotation`; the four
  sphere generators walk their meridian and rings with the negated angles,
  which yields exactly the vertices they produced before (with the new
  constructors and the old angles the ring traversal reversed and every
  strip became inside-out, visible as dark spheres); the simple impostor
  takes `inverse_Rotation (get_Rotation (look_at (...)))` for the camera
  spin; `opengl-dolly.adb` and `gel-dolly-simple.adb` negate their orbit
  angles so every key turns the way it did.
- **demos**: the two rig demos set their camera with
  `x_Rotation_from (-90°)`, tuned to the old inverted sense, so they now use
  `+90°`. The rig's own spin goes through physics and is unchanged. Demos
  which rotate a purely graphical visual by a non-zero angle
  (`diffuse_light`, `render_arrows`) now turn the other way; that is the
  corrected sense and was left alone.
- **collada** `visual_scenes.to_Matrix` already transposed `to_Rotation`
  "from math row vectors to collada column vectors"; that comment is now
  true and the node rotations are no longer inverted.


## 3. Angle, quaternion and vector fixes

- **M1** `any_d3.Angle (P1, P2, P3)` returned π for parallel directions
  (cosine ≥ 1) and let a cosine just below −1 reach `arcCos`. It now clamps
  and returns `arcCos`. Used by the openGL impostors. Test `angle_Test`.
- **M3** `"*" (Quaternion, Vector_3)` wrote its result in (x, y, z, w) order,
  putting the scalar part into `V (3)`. Fixed; `quaternion_Vector_product_Test`
  checks it against the quaternion product with `(0, v)`.
- **M8** `to_Quaternion (axis, angle)` (both overloads, `any_linear.adb`)
  returned the zero quaternion for a zero axis; it returns the identity.
- **L5** `normalise`/`Normalised` (all five overloads) returned Inf/NaN for a
  zero vector; a zero vector is now returned unchanged. **L7** `Versor` and
  **L19** `normalise (Plane)` guard a zero norm likewise (`Versor` raises
  Constraint_Error with a message, the plane is left unchanged).
- **L6** `Angle (Quaternion)` handled `R > 1` but not `R < -1`; it now
  normalises a non-unit scalar and clamps.
- **L9** `unProject` divided the window offset by `Viewport.Max` instead of
  `Max - Min`.
- **L11** `max_Axis` started from a −1e30 sentinel and could return −1.
- **L2** `Average`, `Max`, `Min` of an empty vector raise Constraint_Error
  with a message instead of dividing by zero or indexing past the end.
- **L3** the exception handler in Vector_3 `"-"`, which could never trigger,
  is removed.


## 4. Images (M5, L1, L17, L18)

`Image (Vector)` and `any_linear.Image (Matrix)` declared a 1 MB string on
the stack for every call (every Vector_2/3 and quaternion image went through
the first); the core `Image (Matrix)` used a 1 024-byte buffer with no bound
check. All three now build the string by concatenation, which is Pure-safe
and sized exactly. `Image (Triangles)` appends its " ..." ellipsis when the
next triangle would not fit instead of losing it, `Model.Image` reports
"(no triangles)" for a null access rather than dereferencing it, and
`Image (Polygon)` lists the vertices instead of returning "TODO".


## 5. Random (M4)

`random_Real`'s defaults `Real'First .. Real'Last` overflowed to infinity;
they are now `0.0 .. 1.0`. `random_Integer` computed `Upper - Lower + 1`,
which raised with its defaults, and rounded through Float; it now uses
`discrete_Random.Random (Gen, Lower, Upper)`, exact over the whole of
Integer. The three generators live in a protected object, so the package is
task safe. Test package `math_Tests.Random`.


## 6. 2D geometry (M2, L13, L14, L15)

- **M2** `is_Clockwise` sampled `Vertices (1)` three times and always
  returned False. It now uses the signed area of the whole polygon.
- **L13/L14** `Line` was a variant record and each accessor worked for only
  one variant (`X_of`/`Y_of` raised for a two-point line, `Gradient` for an
  anchored one), and `to_Line (Anchor, Angle)` stored `Tan (Angle)`. A line
  is now always two points, so every accessor works for every line and a
  vertical line is representable (its gradient reports `Real'Last`).
- **L15** `Angle (Triangle, at_Vertex)` divided by zero for a degenerate
  triangle; it returns 0 and clamps the cosine.

Tests `polygon_is_clockwise_Test`, `line_Test`,
`degenerate_triangle_Angle_Test`.


## 7. Modeller and forge (L20 .. L24)

- **L20** `bounding_Sphere_Radius` cached its first answer forever;
  `add_Triangle` and `clear` now invalidate it.
- **L21** `Model` of an empty modeller raises Constraint_Error with a
  message instead of failing on a Positive discriminant.
- **L22** `to_Box_Model` ignored `half_Extents` and built one face; it builds
  the six faces, outward facing, at the given half extents.
- **L23** `mesh_Model_from` re-added the 0→5 longitude strip after the loop
  had already wrapped 355→0, so 70 of its triangles were duplicates and the
  triangle count was hard-coded to 73 strips; the strip is gone and the
  counts are derived from the 5° spacing.
- **L24** `polar_Model_from` left every site absent from the file
  uninitialised and called `Real'Value ("")` on trailing white space; the
  model starts at the origin with `no_Id`, the loop stops when no token
  remains, and a file which ends mid-vertex raises Data_Error naming it.

Tests `box_Model_Test`, `bounding_Sphere_Test` (package
`math_Tests.Geometry_3d`).


## 8. Not changed

- **L4** `almost_Zero`/`almost_Equals` default tolerance is
  `'Base'Model_Small`, i.e. effectively exact. Documented behaviour; callers
  in openGL rely on it as "near zero". Left as is.
- **L16** `Centroid (Polygon)` is the vertex average, not the area centroid.
  Correct for the regular shapes it is used on; left as is.
- The cached trigonometry `if Index < 0` branches after `mod` are dead but
  harmless.


## Verification

- `applet/test/suite`: 32 tests pass (18 before; the 3D rotation test's
  expectations were flipped to the row-vector sense).
- `5-all/applet/build_all` builds every component and demo with no new
  warnings.
- openGL `Demo.Models` screenshot (every model type, including the four
  spheres, hexagon, hexagon column and a skinned human) is pixel-identical to
  the one taken before this branch.
- gel `mixed_shapes` (bullet: boxes, balls, capsules and cones falling on a
  height field) and the one-bone box rig were run for a fixed number of
  frames on this branch and on a `master` worktree; the screenshots are
  pixel-identical, so the physics ↔ graphics spin path, the joint frames and
  the rig composition behave exactly as before.
