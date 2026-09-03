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
