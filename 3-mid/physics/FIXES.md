# physics: review findings and fixes

A sequential review of the physics interface, its bullet and box2d
implementations and their hand-written C++ thin layers (2026-09-04) found
7 HIGH, 22 MEDIUM and 24 LOW defects. Vendored upstream code (`contrib`,
`libbullet`) was not reviewed. All findings are fixed here except the ones
listed under "Not changed"; `physics.Engine`, its `test_engine` demo and the
dead `motor` units were removed separately.

Two decisions were taken across the board:

- An operation a backend cannot perform raises `physics.unsupported_Error`
  with a message naming the backend and the operation, instead of a bare
  `Error "TODO"` or a C function that prints "TODO" and returns 0.
- The interface's names are the contract for both backends: `apply_Force`
  applies a force, `Mass` is a mass, `Extent` is a distance or angle, and
  degrees of freedom are numbered 1..3 for the translations along X, Y, Z and
  4..6 for the rotations about them (a hinge has the single degree 1).

Severity: **HIGH** = wrong result, crash or memory unsafety on a path gel or
a demo exercises; **MEDIUM** = wrong result on a common path or a hazard one
call away; **LOW** = latent, edge case or API trap.


## 1. Bullet: joints (H1, H5, H7; M1, M2, M5, M13, M14; L1, L11)

- **H1** Nothing could remove or destroy a bullet joint: `Space.rid (Joint)`
  and every joint kind's `destruct` raised, and the C layer had no
  remove/delete entry. Every jointed bullet applet therefore raised at
  teardown (seen in this session with the rig demos). `bullet-space.cpp`
  gains `b3d_Space_rid_Joint`, `bullet-joint.cpp` gains `b3d_free_Joint`,
  and the Ada `rid`, `destruct` and `free` use them.
- **H5** The 6-DoF limit functions indexed bullet's rotational motors with
  `DoF - 4` for every degree, so the translational degrees 1..3 wrote
  through a negative index. `bullet-joint.cpp` now dispatches on the
  constraint type and the degree: translations go to the translational limit
  motor, rotations to the rotational one, a hinge's degree 1 to `setLimit`,
  a slider's degrees 1 and 4 to its linear and angular limits, and a cone
  twist's 4..6 to its twist and swing spans.
- **H7** Cone-twist joints were built as hinges by the C layer and as 6-DoF
  joints by the Ada. Both build a `btConeTwistConstraint`.
- **M1** `Velocity_is` passed its degree and velocity swapped for the ball,
  slider and cone-twist joints. **M2** `is_Limited` passed a 0-based degree
  while everything else passed 1-based. Both now go through one
  `bullet_Physics.Joint.Item` implementation with 1-based degrees.
- **M5** `Extent` returned a C `bool`; it now returns the hinge angle, the
  6-DoF relative pivot position or angle, the slider's linear or angular
  position or the cone twist's twist angle.
- **M13** `collide_Connected` was dropped: constraints were always added
  with collisions between the connected bodies disabled and the getter
  returned a constant. The joint remembers the flag, `b3d_Space_add_Joint`
  takes it, and the getter returns it.
- **M14** `setOverrideNumSolverIterations (2000)` ran on every lower-limit
  call; it is set once when a 6-DoF joint is built.
- **L1** The joint stubs are implemented: `Frame_A/B` and their setters for
  every kind, `Velocity_is` (motors), `desired_Extent_is` (hinge motor
  target), `lower/upper_Limit` and setters, `reaction_Torque` (bullet's
  applied impulse per unit time; `reaction_Force` raises
  `unsupported_Error`, bullet does not report it), the hinge's `Angle`,
  limits, `limit_Enabled`, `local_Anchor_on_A/B`, motor attributes and
  `reference_Angle` (zero: bullet measures from the frames), and the
  `new_hinge_Joint` with anchors and axis through a new
  `b3d_new_hinge_Joint_with_anchors`.
- **L11** A joint given a null object raises `unsupported_Error` instead of
  letting the C layer dereference it.
- Joint user data uses bullet's `setUserConstraintPtr`, so the space's
  joint cursor (also a stub before) can walk `getNumConstraints` and hand
  back the Ada joints.

The five joint kinds in `bullet_physics-joint.ads` no longer duplicate every
operation: the common ones live on the base `Item`, and only the hinge
adds its own.


## 2. Bullet: objects, shapes and the space (H2, H6; M6, M9..M12, M15, M16; L9, L10)

- **H2** `cast_Point` raised `Program_Error`, and gel's mouse picking calls
  it after every click. `b3d_Space_cast_Point` tests a 1 mm sphere against
  the world with `contactTest`.
- **H6** `is_Kinematic` was discarded, so kinematic sprites became dynamic
  or static bodies. The interface's `Object.define` now takes
  `is_Kinematic`, both backends honour it, and bullet's
  `KinematicMotionState` path is live again.
- **M6** Bullet bodies, shapes, constraints, motion states and the
  `btTriangleMesh` behind a mesh shape were never deleted. `b3d_free_Object`,
  `b3d_free_Shape` (which also frees the mesh interface) and
  `b3d_free_Joint` exist and the Ada `destruct`s call them.
- **M9** `Space.add` never registered the object in `object_Map`, so
  `evolve` refreshed nobody's `Dynamics` and `get_Dynamics` returned the
  identity forever. `add` inserts, `rid` excludes, and `object_Count` (a
  stub) is the map's length.
- **M10** `Object.Shape` read a user pointer nothing set and returned null;
  the object now keeps the shape it was defined with.
- **M11** The heightfield's width and depth were transposed: bullet reads
  the heights with the second index varying fastest, so the Ada array's
  second dimension is its width. Invisible on the one square field in use.
- **M12** Every dynamic body was created with `DISABLE_DEACTIVATION`, so
  nothing ever slept, while `is_Active` returned True and `activate` did
  nothing. Only kinematic bodies keep the flag; `is_Active` and `activate`
  map to bullet's. The mixed-shapes scene renders pixel-identically.
- **M15** The capsule used only the first radius; it uses the average of
  the two (bullet capsules have one radius). It lies along Z, which is what
  the openGL capsule model does, so that part of the finding was withdrawn.
- **M16** `Site_is` woke the body but `Spin_is` and `Transform_is` did not,
  and `Transform_is` bypassed the motion state. All three go through one
  `set_Transform` which updates a kinematic body's motion state or a dynamic
  body's centre-of-mass transform, and wakes it. Speed, gyre, forces and
  torques wake the body too.
- `apply_Force` applied a central *impulse*; it applies a force (M3 below).
- `Scale`/`Scale_is` and `Shape.Scale_is` (stubs) use bullet's local
  scaling and recompute the inertia; `update_Bounds` (stub) calls
  `updateSingleAabb`. `Gravity`, `manifold_Count`/`Manifold` (from the
  dispatcher's manifolds), `set_Joint_local_Anchor`, `new_Shape (Model)`
  and `xy_Spin`/`xy_Spin_is` (the rotation about Z) are implemented.
- **L9** `new_mesh_Shape` passed `point_Count => 0`; `new_convex_hull_Shape`
  and `new_multisphere_Shape` reject an empty array instead of taking the
  address of element 1.
- **L10** `cast_Ray` returns a fully initialised record when nothing is hit.
- `b3d_new_multiSphere` no longer uses a variable-length array.


## 3. Box2d (H3, H4; M4, M17..M21; L14..L18)

- **H3** DoF6, ball, slider and cone-twist joints were null objects
  (`new_Dof6_Joint` returned null, the C constructors returned 0). In two
  dimensions they are now real joints: DoF6, ball and cone twist are
  revolute joints (the cone twist with limits enabled), the slider a
  prismatic joint along the X axis of frame A, and `b2d_Space_add_Joint`
  creates any joint kind. The 2D mixed-joints demo runs.
- **H4** `b2d_new_Polygon` ignored its vertices and called `SetAsBox` with
  the third one. It passes the vertices to box2d's convex hull, at most
  `b2_maxPolygonVertices` of them, in a fixed-size array.
- **M4** `Mass` was stored as the fixture's density, so a body's mass was
  its area. The fixture is created with unit density and the body's mass
  data is then set to the mass asked for, with the inertia scaled to match.
- **M17** `Transform_is` read the angle from `m10` (column convention);
  it reads `m01` like `Spin_is`.
- **M18** `Scale_is` set a circle's radius to half the scale and scaled a
  polygon's y by the old x scale; both rescale from the current scale. The
  shape-level `Scale_is` was a dead `return`; it is a documented no-op,
  since scaling is applied through the object which knows the current
  scale, and its C function is gone.
- **M19** `cast_Ray` reported the object but zero for the fraction, normal
  and site; the callback keeps all three.
- **M20** `b2d_Space_rid_Object` and every force, torque and velocity
  setter check for a body before touching it.
- **M21** The 3D shape constructors raise `unsupported_Error` on the Ada
  side before the C returns 0; the base `define` message says so.
- Joint attributes work on the definition until the joint is in a space and
  on the live joint afterwards: `Object_A/B`, `Frame_A/B` and setters,
  `is_Limited`, `Extent`, `Velocity_is` (motors), the limits, collide
  flag and the hinge attributes. A live joint's user data is the Ada joint
  (`b2d_Joint_user_Data_is`, set when the space adds it), so the joint
  cursor's `Element` no longer returns null.
- **L14** The dead `rebuild_Shape` is gone; `new_Shape (Model)` dispatches
  on the model's shape kind in both backends.
- **L16** `b2d_space_Contact` checks the index.
- **L17** `b2d_new_space_hinge_Joint` takes its anchor from `Frame_A`, and
  `b2d_Space_rid_Joint` destroys the ground body it created.
- `b2d_new_Object` takes `is_Kinematic` (`b2_kinematicBody`), `is_Active`
  and `activate` map to `IsAwake`/`SetAwake`, `Gravity` is readable, and
  `b2d_Object_Transform_is` records the z site like `Site_is`.


## 4. Cross-backend contracts (M3, M4)

- **M3** `apply_Force` was a central impulse in bullet and a force in
  box2d. It is a force in both. No caller in lace relied on the impulse.
- **M4** `Mass` is a mass in both (see box2d above).


## 5. Interface, bindings and c_math (M7, M8, M22; L2..L4, L8, L13, L20)

- **M7/L22** `physics.Engine` and `test_engine` were removed earlier
  (commit 14c078c). **M8** The `motor` units, which referenced packages that
  do not exist and compiled only because the project omitted their
  directory, are removed.
- **M22** `c_math_c-conversion.adb` assigned `Result.x` in the overflow
  handlers for y and z.
- **L2** `of_Obect` is `of_Object`. **L3** The duplicate `physics.Forge.Real_view`
  is gone. **L4** `physics.Model.Item.Shape` (never set) and `Space.Contacts`
  (never used) are gone.
- The generated bindings `bullet_c-binding.ads` and `box2d_c-binding.ads`
  are extended by hand, since the bullet generator (`swig_gnat`) is no
  longer installed; the C headers remain the source of truth and the
  files say so. The SWIG wrapper files lost the wrappers whose C
  signatures changed; the Ada imports those functions directly. Two small
  record packages, `bullet_c.point_Collision` and `bullet_c.b3d_Contact`,
  mirror the new C structs.
- **L13** bullet's `is_Kinematic` helper is static.


## 6. gel

`gel.any_Joint`, `gel.ball_Joint`, `gel.cone_twist_Joint` and
`gel.slider_Joint` had `destroy` raising `Error "TODO"` (the hinge's was
implemented), which was the next thing to raise at teardown once the space
could rid a joint. They now destruct and free their physics joint like the
hinge does.

`gel.Applet.destroy` freed the worlds, and with them every visual, straight
after the last frame request, while the renderer task could still be
drawing that frame: closing a demo window ended in a segfault in the
renderer (reported as Storage_Error) and then Tasking_Error when the
applet stopped the dead task. Found while verifying this branch and
reproducible on master. The applet now waits for the renderer to finish
the frame in flight before the worlds go.


## 7. Not changed

- **L5** `bullet_physics-joint.adb`'s `put_Line` before raising went with
  the stub. Other debug output was in the removed engine.
- **L12** `stepSimulation (By, 10)` still returns the last sub-step's
  transform rather than an interpolated one; the motion states are
  deliberately no-ops. Cosmetic.
- **L18** Box2d's reaction force and torque still assume a 60 Hz step,
  which is what gel uses.
- **L19** `swig.bool` for a C++ `bool` is the SWIG convention throughout the
  bindings and left as is.
- **L20** `physics.gpr` still lists both backends as sources, so a program
  links both; `physics.Forge` needs both.
- **L21** The `LIBRARY_PATH` include workaround in `bullet_thin_c.gpr`.
- **L23** The hello demos do not free their space or objects; they exit.
- **L24** Tabs, `;;` and commented-out blocks in the C++ were tidied where
  a file was rewritten and left elsewhere.


## Verification

- `build_all` builds every component and demo with no new warnings.
- The hello demos run on both backends: bullet's ball comes to rest at
  0.0 (and now sleeps), box2d's bounces to rest on the box.
- gel `mixed_shapes` (bullet) and the one-bone box rig render
  pixel-identically to the master baselines, and the rig applet now exits
  cleanly instead of raising in `Space.rid`.
- gel `mixed_joints` (bullet: hinge, slider, cone twist, ball and DoF6),
  `mixed_joints_2d` (box2d DoF6, which could not be created before),
  `hinged_box`, `chains_2d` and `pong` (box2d polygons and forces) each
  run 240 frames and exit without an exception.
- There is still no physics test suite; the joint attribute paths that no
  demo exercises (limits, motors, extents, cursors, contacts) compile and
  run against real bullet and box2d objects but were not measured.
