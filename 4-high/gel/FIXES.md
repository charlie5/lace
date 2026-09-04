# GEL code review fixes — 2026-09-03

A code review of `4-high/gel/source` (the game engine layer), run after the
`1-base/lace` campaign it sits on. gel compiled cleanly against the reworked
lace, so there was no interface-level breakage; the defects below were its
own. The serious ones cluster in the DSA world-mirroring path and in
sprite/world teardown, exactly where the review was pointed.


## 1. Sprite add / rid were never propagated to mirrors

**Files:** `world/gel-world.adb`

A server world registered its clients for `new_sprite_Event` and
`rid_sprite_Event`, and clients carried the responses to create and destroy
the mirrored sprites — but **nothing ever emitted those events**, so the
responses were dead code and a client only ever logged "Received motion
updates for unknown sprite N" forever. `add_single_Sprite` now emits a
`new_sprite_Event` (carrying the sprite's model ids, transform and
visibility) and `rid_single_Sprite` emits a `rid_sprite_Event`, so a sprite
created or removed on the server after a client has registered now appears
or disappears on the mirror. This uses the same emit/respond mechanism the
model events already used successfully.


## 2. The free-set delay was an off-by-one no-op for server worlds

**Files:** `world/gel-world.adb`

`free_pending_Sprites` swapped the current free-set index *before* freeing,
then freed the set it had just switched *to* — i.e. the set that had
accumulated the current pass's destroys. For a renderer-less world (a
server) that freed a sprite at the end of the very pass that destroyed it,
so the physics space, manifolds and snapshot arrays could still hold a
dangling view. It now frees the *other* set (the previous pass's) and swaps
after, restoring the documented one-pass delay.


## 3. Server sprite map and client list raced PolyORB tasks

**Files:** `world/gel-world.ads/.adb`, `world/gel-world-server.ads/.adb`,
`world/gel-world-client.ads/.adb`, `world/gel-world-simple.ads/.adb`

The server world's `sprite_Map` (a plain hashed map whose `all_Views` array
is freed and rebuilt on every add/rid) and its `Clients` vector were read
and written concurrently by the main game loop and by PolyORB worker tasks
running remote calls (`Sprites`, `register`, `deregister`). The client world
had a protected sprite map for exactly this reason; the server did not.

The protected sprite map is now hoisted into the base `gel.World` (one
`safe_id_Map_of_sprite` serving every world), so `all_Sprites` is concrete
and every world — simple, server, client — shares the synchronised
implementation instead of three near-identical copies. The server's client
list is now a protected `safe_Clients`.


## 4. One dead client could kill the server's evolve loop

**Files:** `world/gel-world-server.adb`

The server's per-frame `motion_Updates_are` calls to each mirror had no
exception handling: a killed client partition raised
`Communication_Error` straight out of `evolve` (crashing the server), and
even a transient error skipped every client after the failing one.
`deregister` separately raised `Constraint_Error` when handed an unknown
mirror (`delete (find_Index = No_Index)`). Now each remote update is guarded;
a mirror that fails is collected and evicted after the loop, so one dead
client can neither crash the server nor stall the others, and `deregister`
tolerates an unknown mirror.


## 5. gel's `sequence_Id` was not modular

**Files:** `remote/gel-remote-world.ads`

`sequence_Id` was `range 0 .. 2**32 - 1`, so the server's `seq_Id + 1`
raised `Constraint_Error` on wrap, and — the practical failure — after a
server restart (its counter resets to 1) the client's monotonic
`seq_Id > Self.seq_Id` guard silently discarded every later update and the
mirror froze. The type is now `mod 2**32` (matching the lace fix, §10.1
there). The client's guard is rewritten to accept an id equal-or-newer
within a stale window and to *resynchronise* to an id far from its latest
(a restart or a wrap), instead of freezing.


## 6. A partial stream read corrupted motion updates

**Files:** `remote/gel-remote-world.adb`

`motion_Updates_read` issued a single `read` and asserted it filled the
whole buffer. A legal partial read (the transport may fragment a large
array) crashed the assert in debug builds and, with assertions off,
unchecked-converted a half-filled buffer — trailing uninitialised bytes
becoming sprite ids and positions, teleporting mirror sprites to garbage.
The read now loops until the buffer is full.


## 7. A client could only mirror one server world

**Files:** `world/gel-world-client.adb`

The four mirror-response objects were single package-level globals, so a
client that mirrored two server worlds had the second `is_a_Mirror`
overwrite the first's `World`/`Models` targets, silently routing the first
server's events into the wrong world. The responses are now allocated
per-world inside `is_a_Mirror`.


## 8. Sprite destroy left the solid in the space and the view in the map

**Files:** `gel-world.adb`, `gel-sprite.adb`

`Sprite.destroy` deferred the sprite for freeing but never removed it from
the world's sprite map or its solid from the physics space — that was a
separate, unenforced `World.rid` call. Two passes later `Sprite.free`
deallocated a solid the space might still hold, and `fetch_Views` kept
returning the freed view. `World.destroy (the_Sprite)` now rids the sprite
first (removing it from the map and space) before queueing it, so a destroy
is self-contained.


## 9. `World.destroy (Joint)` was a stub

**Files:** `gel-world.adb`, `gel-sprite.adb`

`gel.World.destroy (the_Joint)` was `null; -- TODO`, so `Sprite.detach`
removed a joint from its parent's list without removing the physics
constraint (the sprites stayed joined) or freeing the joint (a leak); and
`Sprite.free` then iterated a `child_Joints` vector `detach` had already
emptied, so joints were never freed there either. `World.destroy (Joint)`
now rids the constraint from the space and frees the joint, and `Sprite.free`
no longer walks the emptied vector.


## 10. World destroy leaked the models it owns

**Files:** `gel-world.adb`

Since sprite.free was made to leave models alone ("their lifetime is the
world's"), nothing freed them: `World.destroy` freed only the physics space
and event machinery. It now destroys any sprites still in the world, frees
both pending free-sets, frees every graphics and physics model (via the
renderer when present, so GL resources are released safely), and frees the
sprite map's views array.


## 11. Focus events emitted the wrong event

**Files:** `gel-window.adb`

Copy-paste: `emit_focus_in_Event` and `emit_focus_out_Event` both declared
and emitted a `window_Leave` — so focus observers received nothing while
leave observers got a spurious event on every focus change, and the
`window_Focus_In` / `window_Focus_Out` types were dead. They now emit the
correct events.


## 12. Multi-tile terrain collapsed to the origin

**Files:** `terrain/gel-terrain.adb`

`new_Terrain` computed per-tile X/Y/Z site offsets but hard-coded every
tile's site to `(0,0,0)`, stacking all tiles of a multi-tile heightmap at
the origin. The offsets are now applied: X and Z from the accumulated tile
widths/depths, Y from each tile's mid-height relative to the whole map's
mid-height (each tile model is centred on its own mid-height, so the site
restores its true elevation and seams stay continuous). A single-tile
terrain lands exactly where it did before.


## 13. `freshen` spin-waited on cull completion

**Files:** `applet/gel-applet.adb`

The per-frame wait for the cameras to finish culling looped on
`delay Duration'Small` (~1 ns), an effective spin pegging a core. It now
delays 0.1 ms per poll, yielding meaningfully.


## 14. Duplication and dead code

**Files:** `world/*`, `applet/gel-applet.adb`, plus removed backup files

The `sprite_Map` implementation and the `define`/`destroy` bodies were
duplicated across the four world packages; §3's hoist of the map into the
base plus a shared base `destroy` collapsed the derived worlds to just their
genuine differences (simple: nothing; server: client updates; client:
mirroring and interpolation), removing ~880 lines. `gel.Applet.add (sprite)`
was a dead trap that added only a sprite's child joints and never the sprite
itself; it now delegates to `World.add (..., and_Children => True)`. The
stale checked-in editor backups (`gel-camera.ad?-orig`,
`gel-human_v1.ad?-orig`, `gel-remote-physics_model.ads-old`) were deleted.


## Verification

- **Full-tree `build_all`** compiles every component and demo cleanly (only
  the pre-existing vendored-box2d warning).
- **`po_gnatdist` stub generation** for the gel DSA demo succeeds over the
  reworked cross-partition units (the modular `sequence_Id`, the protected
  server/client worlds, the new sprite-mirroring emit path) — the
  DSA-specific compile gate most likely to break from the interface changes.
- The **`chains_2d` and `mixed_shapes` GUI sprite demos** run live under X
  and close via `WM_DELETE_WINDOW`, exercising the reworked world teardown,
  the corrected free-set delay, and the sprite/joint destroy paths; both
  exit cleanly. The **server partition** runs without error.

The live end-to-end DSA sprite-mirroring run (a GUI client mirroring a
server) is environment-fragile to drive headless and was not completed in
session; the path is validated by clean compilation, successful DSA stub
generation, and its equivalence to the already-working model-event mirroring
mechanism.


---


# Round 2 — re-review fixes, 2026-09-04

A second /code-review pass over `4-high/gel/source`, run on the round-1
result, found that several of the mirror-protocol guards narrowed their
races rather than closed them, and that two converted loud failures into
silent desyncs. This round reworks the protocol around three root causes
instead of patching each symptom.


## 2.1. Registration is now atomic: `register` returns the world snapshot

`gel.remote.World.register` is now a function returning a
`mirror_Snapshot` — the graphics models, physics models, sprites and
current motion sequence id — captured by the server only *after*
subscribing the observer. A change happening around registration can
therefore arrive both in the snapshot and as an event, but never in
neither; the client applies both idempotently (the world's model `add`
already skipped known ids; the sprite paths now check before adding).
This closes the lost-sprite and ghost-sprite windows at the source, and
replaces the client's two polling fetch-tasks and three RPCs with one
call. The sequence id in the snapshot resynchronises the mirror, so a
reconnect after a server restart starts clean.

The old sequence guard's 64-id "stale window" — which froze a fresh mirror
near the wrap point and rewound on a long-delayed burst — is replaced by
serial-number acceptance: an update is applied iff its id is ahead of the
latest by less than half the id space.

## 2.2. Registration and disconnection are symmetric and idempotent

The server keeps each mirror as a (mirror, observer) pair. `register`
dedupes — a repeated registration cannot double the event subscriptions —
and one `disconnect` routine (used by both `deregister` and eviction) rids
the pair *and* deregisters the observer from all four event kinds, so an
evicted client no longer leaks observer registrations that the server then
pays a failed RPC for on every sprite event. Eviction is again limited to
`communication_Error | storage_Error` (a genuinely dead transport), logged
with `exception_Information`; any other exception propagates loudly
instead of silently cutting off a live client.

## 2.3. Teardown is ordered and drained

The client world's destroy now: deregisters itself from the mirrored
server (kept on record from `is_a_Mirror`), closes a gate inside
`safe_sequence_Id` — barring new motion updates and blocking until
in-flight ones drain — and only then destroys the base. On the server, an
update round is bracketed (`begin_Round`/`end_Round`) and `rid` waits for
the round to end, so once a disconnect returns, no update call can still
reach the departed mirror. The `seq_Id` gate is deliberately never freed:
a straggling asynchronous update off the network must find a closed gate,
not freed memory (one small allocation lives for the program; the round-1
free reintroduced exactly that dangling risk).

## 2.4. Client-local sprite ids cannot shadow server ids

A client world now allocates local sprite ids downward from
`sprite_Id'Last`, while server ids grow upward from 1 — so the duplicate
guard can no longer silently drop a server sprite whose id collides with a
locally created one.

## 2.5. A sprite with missing models recovers instead of being dropped

If a `new_sprite_Event` refers to models the client does not yet hold, the
client now re-fetches the server's model maps (adding only the missing
ones) and retries, rather than dropping the sprite forever with a warning.
The duplicate-sprite path now also emits the `sprite_added_Event`
acknowledgement, so an observer counting acks is not starved.

## 2.6. `is_Closing` removed: mirrors are told of ridded sprites at world destroy

The round-1 `is_Closing` flag suppressed sprite events for *all* observers
during world destroy — wrong across DSA partitions, where a client mirror
outlives the server's world and was left rendering ghosts. The flag (and
its unsynchronized cross-task read) is gone: teardown emits rid events as
usual, and the subject machinery is destroyed after the sprites, so the
emissions are safe.

## 2.7. Cleanups from the re-review

The model maps are probed once per arriving sprite (cursors passed to
`to_Sprite`, which now takes the model views). The demo client's redundant
second registration is gone (`is_a_Mirror` registers). The demo's
`gel_demo_Server.item.stop` — a rendezvous with the *client partition's*
local, never-started copy of the server task, which hung the client at
exit since the demo was written — is replaced by an RCI
`gel_demo_Services.stop_Server` that reaches the server partition. The DSA
builder's hard-coded gcc-15.1.1 `a-sttebu.ali` path now uses
`$(gcc -dumpversion)`.


## Round 2 verification

- Full-tree `build_all` clean; `po_gnatdist` builds both partitions.
- `chains_2d` and `mixed_shapes` run and exit cleanly.
- **The DSA demo now works end to end, for the first time**: the client
  mirrors the server's sprites via the register snapshot (motion updates
  apply with no unknown-sprite warnings), and closing the client window
  runs the whole reworked teardown — deregister, gate drain, world/applet
  destroy — prints "Client done.", stops the server through the new RCI
  call, and both partitions exit on their own.


# Second pass: the rig and the humans (2026-09-05)

A targeted review of `gel.Rig`, `gel.Human`, `gel.Human_v1`, their demos and
the world's teardown, made after the math convention change and the
physics, xml and collada fixes beneath them, found 2 HIGH, 8 MEDIUM and
9 LOW defects. All are fixed here except the one under "Not changed".

The decision that shapes the work: **`gel.Human` is now a configuration of
`gel.Rig`** and `gel.Human_v1` and both `human_Types` packages are gone.
The three copies of the keyframe machinery become one, in the rig; the
human adds a display mode (skin, bones, or both), a `Site_is`/`Spin_is`,
an `evolve` that animates and poses, and a ready-made table of MakeHuman
joint limits. A human is defined from a collada file name and adds itself
to the world. About 4 100 lines go.

Severity: **HIGH** = wrong result, crash or memory unsafety on a path a
demo exercises; **MEDIUM** = wrong result on a common path or a hazard one
call away; **LOW** = latent, edge case or API trap.


## 1. The rig

- **M1** Animation was frame-rate dependent: the keyframe cursor advanced
  by world age but the pose by a fixed increment per call. `animate` now
  interpolates directly from the elapsed time, between the keys on either
  side of it, so the pose is a function of the world's age alone; the
  per-channel cursor, delta, current-value and slerp state are gone, and
  every channel loops over its clip. (Before, matrix channels looped and
  the others stopped at their last key.)
- **M2** The rig could animate one model: `define` matched channel targets
  against a hard-coded list of the human rig's bone names and raised on
  anything else. Channels are now derived from the target,
  `<node id>/<sid>[.<member>]`: the joint is the id, the transform is the
  node's transform with that sid, and the member picks the kind (a matrix,
  a translation, one component of it, or a rotation angle). Targets that
  name nothing the rig models (materials, scale, nodes outside the
  skeleton) are ignored; a channel with the wrong number of values, or
  one that appears twice, raises `gel.Error`.
- **M3** The rig keyed its maps by node id but recognised the root by
  name. The id is used everywhere; and the skin's joint names, which are
  the nodes' sids, are mapped to node ids when the joint slots are set, so
  Blender exports whose bone ids differ from their sids and names load.
- The root bone's transform was never written to the skin program: the
  update loop walked the joint-offset map, which the root is not in. It
  walks the joint slots now, and `joint_site_Offet` answers zero for the
  root.
- **L2** The shared start time was reset whenever one channel wrapped;
  gone with M1.
- **L3** A model without a skin controller or a visual scene raises
  `gel.Error` naming the model instead of dereferencing null.
- **L4** The skeleton root the document names is found by id among the
  scene's nodes, rather than assumed to be the first child of the first
  root.
- **L1**, **L6** The dead procedures, the `to_Math` helper and the
  in-loop renaming of `Index` are gone; the rotation setters take
  `Radians`.
- `Mode` returns the rig's motion mode.
- An animated rig jittered and sank: the sprite carrying the skin was a
  dynamic body of mass 1 whatever mass the demo asked for, so gravity
  pulled the figure down every frame while the bone bodies, teleported to
  the animated pose and back to the bind pose each frame, made the joint
  solver kick it. Measured on the golfer, the base sprite sank 0.9 units
  in 150 frames, reversing direction on 63 of 98 frames; the golf swing's
  slow phases made this visible where the jump's own motion hid it.
  `define` now takes the motion mode, builds an Animation rig from
  kinematic bodies, and gives the skin sprite the requested mass; the
  demos say `Mode => Animation` at definition.
- `assume_Pose` put the root at the origin, so a rig's `Site_is` and
  `Spin_is` were undone on the next frame; it now places the bind pose at
  the rig's site and spin. That made the `-90°` spin the rig demos had
  always asked for, and never got, take effect and turn the figure over,
  so the demos no longer ask for it.
- `test_gel_render` now loads the animated one-bone Blender box, whose
  bone id and name differ, runs it as an Animation rig for a hundred
  frames, requires its base not to move, and destroys it after the world.


## 2. The humans

- **H1** `gel.Human.define` divided the shared document's keyframe times
  by five in place, so a second human animated 25 times faster. Gone with
  the rewrite: a human's rig loads and owns its own document.
- **H2** `gel.Human.destroy` freed the bone sprites' graphics models,
  which the world owns and frees again, and freed the base sprite without
  destroying it. `destroy` now destroys the rig, after the world.
- **M4** `animate` and `evolve` were split and the demo called only the
  half that does not pose the skin. `evolve (world_Age)` animates in
  Animation mode and poses the skin.
- **M5** The fixed channel table crashed on a model lacking a channel.
  Channels come from the file now.
- **M6** The skin's graphics model and texture were hard-coded regardless
  of `use_Model`, and `define`'s `Model` and `physics_Model` parameters
  were unused. `define` takes the model's file name.
- **M7** `gel.Human_v1`, `gel.human_Types` and `gel.human_Types_v1` are
  removed; the `human_model_v1` and `mh_animation` demos use `gel.Human`
  with the display mode they had.
- **M8** The per-frame prints in `Human_v1.evolve` went with it.
- **L7**, **L8**, **L9** The name-to-enumeration conversions, the global
  display mode, the no-op time loop and the unused declarations went with
  it.


## Not changed

- **L5** `guessed_bone_Length` still measures to the first child for the
  root and the last child for other joints; making it symmetric would
  change the proportions of every shipped rig.
- The rig still cancels the root joint's own motion, so a rig whose only
  bone merely translates shows no animation; the base sprite is what
  places a rig in the world.
- `mh-human-dae.dae` carries no bone animation (its one channel targets a
  shader), so the human model demo shows the model in its bind pose.


## Verification

- `build_all` builds warning-free; the three human demos compile against
  the new `gel.Human`.
- The one-bone box rig renders pixel-identical to the frame made before
  these changes, and the animated one-bone box, which the old rig refused
  ("target not handled"), now loads and runs.
- The human rig demo's model (`human-animation-jump.dae`, desk profile)
  animates; its frame at 120 frames is reproducible run to run, differs at
  60 frames, and differs from the pre-change frame only in phase and in
  the hips now following the animation.
- The new `gel.Human` builds the MakeHuman model in all three display
  modes and destroys cleanly after the world.
- To build the desk profile, export `opengl_profile=desk` and touch
  `3-mid/opengl/source/opengl.adb`: the profile is a subunit and gprbuild
  does not notice the swap on its own.
