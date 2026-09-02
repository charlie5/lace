# Code review fixes — 2026-09-01

A code review of `1-base/lace/source` confirmed a set of correctness defects.
This document records each fix applied, the defect it corrects and why the
defect mattered. All changes live under `1-base/lace/source`; nothing outside
the lace component was touched.

Verification is summarised at the end.


## 1. Core operations

### 1.1 `lace.Time.to_Duration` overflowed for `Hours >= 3`

**File:** `lace-time.adb`

**Defect.** `to_Duration` computed `From.Hours * 60 * 60` before converting to
`Duration`. `type Hours is range 0 .. 23` gets an 8-bit base type, and Ada
evaluates the multiplication in that base type, so `Hours * 60` overflows its
range (`3 * 60 = 180 > 127`) and raises `Constraint_Error` for 21 of the 24
valid hour values. The `"+"`/`"-"` operators then caught it and re-raised it,
misleadingly, as `lace.Time.Overflow`.

**Fix.** Convert each component to `Duration` first, then scale:
`Duration (From.Hours) * 60 * 60`, and likewise for minutes.

### 1.2 `lace.Time.to_Time` misrounded near unit boundaries

**File:** `lace-time.adb`

**Defect.** `to_Time` decomposed a `Duration` using 32-bit `Float`. `Float`
carries a 24-bit mantissa, so a value a few nanoseconds under an hour boundary
(for example `3599.999_999`) rounds up to `1.0` before `Float'Floor` is
applied. The hour count comes out one too high, the remaining pad goes
negative, and the following `Minutes` conversion raises `Constraint_Error`.

**Fix.** The decomposition now uses `long_Float`, whose 53-bit mantissa
exceeds `Duration`'s precision, so a floor can no longer misround at a
boundary. This also makes the microseconds component exact.

### 1.3 `lace.Text.delete` (function form) returned uninitialised data

**Files:** `text/lace-text.adb`, `text/wide/lace-wide_text.adb`

**Defect.** The function form declared
`Result : Text.item (Self.Capacity);` and ran the in-place `delete` on it —
but never copied `Self` into `Result`. The procedure therefore operated on a
`Length = 0` item with uninitialised `Data`, and every call returned garbage
(or an empty text), silently. `delete (to_Text ("abcdef"), From => 3,
Through => 4)` returned two bytes of stack noise instead of `"abef"`.

**Fix.** `Result : Text.item := Self;` — the in-place delete then operates on
a real copy. The wide mirror had the identical defect and got the identical
fix.

### 1.4 `lace.Text.utility.replace` crashed when the pattern was longer than the text

**Files:** `text/lace-text-utility.adb`, `text/wide/lace-wide_text-utility.adb`

**Defect.** The tail-match test evaluated the slice
`Self.Data (Self.Length - Pattern'Length + 1 .. Self.Length)`. When
`Pattern'Length > Self.Length` the low bound is zero or negative, producing a
non-null slice with a bound below `Positive'First` — `Constraint_Error`
instead of the correct "no match". This was reachable in production:
`environ.Paths.Relative` passes `Pattern => (+To) & "/"`, so relativising any
path shorter than the folder name crashed.

**Fix.** The tail test is now guarded:
`if Pattern'Length <= Self.Length and then ...`. Both widths fixed.

### 1.5 `lace.Job.Manager.do_Jobs` looped forever or abandoned jobs

**File:** `jobs/lace-job-manager.adb`

**Defect.** The loop walked the sorted job vector with a cursor it never
advanced. A due job whose `perform` does not push `Due` into the future — the
inherited base `lace.Job.perform` only bumps `performed_Count` — was therefore
re-performed in an infinite loop, hanging the caller. Separately,
`Self.Jobs.delete (Cursor)` (the `Due = Never` branch) sets the cursor to
`No_Element`, ending the walk and abandoning every remaining due job in that
pass.

**Fix.** The walk now uses a plain index. A performed job advances the index
(so each due job runs at most once per pass and is retried next pass if still
due); a deleted `Never` job does not advance it, since the next job shifts
down into the vacated slot.


## 2. Tokenizer

### 2.1 `lace.Text.all_Tokens` overflowed the stack on tiny inputs

**Files:** `text/lace-text-all_tokens.adb`, `text/wide/lace-wide_text-all_tokens.adb`

**Defect.** Both generic bodies (`any_Tokens_chr`, `any_Tokens_str`) declared
`the_Tokens : Array_type (1 .. max_Tokens)` — with the default
`max_Tokens = 8 * 1024` — regardless of the input's size. Each component is a
fixed-capacity `Text.item`, so the `items_1k` instantiation needs an ~8.4 MB
frame: tokenising even `"a b"` overflowed a default 8 MB stack. Worse, the
fault occurred while the frame was being allocated, so the
`storage_Error => raise stack_Error with "…ulimit -s unlimited…"` handler
never ran — callers got a raw `STORAGE_ERROR` and the advice was never
delivered.

**Fix.** Both bodies now make two passes: first count the tokens (no arrays
involved), then declare the array with exactly that count, inside a nested
`declare` block within the handled statement part. Consequences:

- Small inputs use small frames; the confirmed crash class is gone entirely.
- A genuinely enormous result can still exceed the stack, but the frame is
  now proportional to the actual data, and the `stack_Error` handler with the
  `ulimit` advice genuinely fires, because the allocation happens inside the
  handled sequence of statements.
- `max_Tokens` is now enforced as an explicit cap: exceeding it raises
  `lace.Text.Error` with a descriptive message, where before it raised a bare
  `Constraint_Error` on an index check.

### 2.2 `Tokens_512k` (character delimiter) had a capacity typo

**Files:** `text/lace-text-all_tokens.adb`, `text/wide/lace-wide_text-all_tokens.adb`

**Defect.** The character-delimiter `Tokens_512k` was instantiated with
`Text_Capacity => 512` instead of `512 * 1024` (the string-delimiter variant
had it right), so its tokens silently held 512 characters, not 512k.

**Fix.** `Text_Capacity => 512 * 1024`, in both widths. (This finding sat
below the review's reporting cap but was confirmed and lives in the same
file, so it was fixed alongside.)


## 3. Events — lifecycle and concurrency

### 3.1 Pooled emitter/sender tasks could touch a freed protected object

**Files:** `events/mixin/private/lace-event_emitter.adb`,
`events/mixin/private/lace-event_sender.adb`

**Defect.** The delegator task keeps its worker pool
(`the_Emitters : aliased safe_Emitters`) in its own stack frame and hands
workers `the_Emitters'unchecked_Access`. Workers are library-level tasks
allocated with `new`, and after delivering an event they call
`emitter_Pool.add (Myself)` to return themselves to the pool. On destroy, the
delegator drained only the *idle* workers and then exited — reclaiming the
frame that holds the pool — while a still-busy worker (one inside
`the_Observer.receive`) would later call `add` on the freed protected object:
a use-after-free with memory corruption potential.

**Fix.** The delegator now counts the workers it creates and `shutdown` waits
until every one of them has come back to the pool (freeing each as it
arrives) before the task exits. Supporting changes to make that wait safe:

- A worker's exception handler returns it to the pool *before* the failure
  logging, because the logging itself dereferences possibly-dead remote views
  (`the_Observer.Name`) and can raise — which previously meant the worker
  never returned and would have hung the new wait.
- If dispatching to a worker fails (for example `tasking_Error` from a dead
  task), the delegator returns that undispatched worker to the pool, keeping
  the count exact.

### 3.2 `destroy` returned while the delegator still used the object's queue

**Files:** same as 3.1

**Defect.** `event_Emitter.destroy` / `event_Sender.destroy` merely completed
the `stop` rendezvous and returned. The delegator kept draining
`Self.Events` / `Self.send_Details` — components of the very object being
destroyed — after `destroy` returned, so freeing or finalising the enclosing
subject raced the delegator's accesses.

**Fix.** `destroy` now waits for `Self.Delegator'Terminated` before
returning, making destruction synchronous: when it returns, nothing touches
the object any more.

### 3.3 Observer sequence-id map was mutated without synchronisation

**Files:** `events/mixin/lace-event-make_observer.ads/.adb`,
`events/mixin/lace-event-make_observer-deferred.adb`,
`events/mixin/private/lace-event-containers.ads/.adb`

**Defect.** The observer's `sequence_Id_Map` was a plain
`indefinite_hashed_Maps` map (with container tamper checks suppressed
tree-wide in `lace.Event.Containers`). Yet it was touched from several tasks
at once: multiple pooled emitter tasks run an instant observer's `receive`
(check-then-insert) concurrently, the user's task runs `add`, and `rid`
deletes entries. Two emitters could both see `not contains` and both insert
the same key — a duplicate-key `Constraint_Error` at best, corrupted map
memory across a rehash at worst. Erroneous execution under RM 9.10.

**Fix.** The subject side already had a protected wrapper,
`Containers.safe_sequence_Id_Map`. It gained two operations (`increment`,
`Element`), and the observer's record component now uses that protected type
instead of the raw map. All call sites were converted: `add`/`receive` use
its `add` (insert-zero-if-absent), `safe_Responses.rid` uses its `rid`, and
the deferred `actuate` compares via `Element` and advances via `increment`
instead of holding an unsynchronised `Reference_type` rename.

### 3.4 `safe_Responses.receive` mishandled the "no responses" case

**File:** `events/mixin/lace-event-make_observer.adb`

**Defect.** The procedure bound
`my_Responses.Element (from_Subject).all` in its *declarative part*. When the
subject had no entry, the `Constraint_Error` was raised during elaboration of
the declarations — and a frame's own handler cannot catch exceptions from its
own declarative part — so the intended `when constraint_Error` handler (which
logs "has no responses") was bypassed and the exception escaped to the
caller. Meanwhile the same handler *did* catch `Constraint_Error` raised
inside a user's `respond` callback and mislabelled it as "has no responses",
hiding real bugs in user code.

**Fix.** `receive` now tests `my_Responses.contains (from_Subject)` first and
takes the intended log-or-raise path explicitly; the response lookup moved
into a nested block entered only when the entry exists; and the misleading
catch-all `constraint_Error` handler was removed, so a failure inside a user
callback propagates honestly (the emitter task logs it and continues). The
observer's name is also now fetched lazily (an expression function) instead
of eagerly on every event.

### 3.5 Destroy/free left dangling views in maps (non-idempotent destruction)

**Files:** `events/mixin/lace-event-make_observer-deferred.adb` (`free`),
`events/mixin/lace-event-make_subject.adb` (`destruct`),
`events/mixin/lace-event-make_observer.adb` (`safe_Responses.destroy`)

**Defect.** All three teardown routines walked their map, deallocated each
element view, and left the map still holding the (now dangling) views. A late
event arriving after destroy found `contains = True` and dereferenced freed
memory; calling destroy twice deallocated every view a second time — heap
corruption either way. (Reachable precisely because of the in-flight-delivery
windows closed by 3.1/3.2, and still the correct hardening regardless.)

**Fix.** Each routine now clears its map after freeing the elements, so a
repeated destroy is a harmless no-op and post-destroy lookups find nothing.

### 3.6 A failed delivery permanently stalled deferred observers

**File:** `events/mixin/lace-event-make_subject.adb`

**Defect.** Every emit path calls `sequence_Id_Map.get_Next` — consuming a
sequence id — *before* delivering. The
`when communication_Error | storage_Error` handlers then dropped the event
without restoring the id (a `decrement` operation existed but had no
callers). The deferred observer requeues any event whose sequence is not
exactly the expected one, so a single skipped id meant every later event was
re-fetched, re-sorted and re-queued on every frame, forever — no responses
fired and the pending queue grew without bound. A deregister/re-register
cycle (server reconnect) triggered the same livelock by resetting the
subject-side counter while the observer's expectation persisted.

**Fix.** All three failure handlers (procedure `emit`, function `emit`,
procedure `send`) now call `Self.sequence_Id_Map.decrement` for the failed
observer, returning the unused id so the stream stays contiguous.

### 3.7 `lace.Event.utility.close` left dangling logger views

**File:** `events/utility/lace-event-utility.adb`

**Defect.** `close` destructed and deallocated the text logger (closing its
file) but never cleared the views previously registered with
`lace.Subject.Logger_is` / `lace.Observer.Logger_is`. Any later
subject/observer activity — for example deregistration during an applet's
shutdown-after-exception path — saw `Logger /= null` and dispatched through
the freed logger into a closed `File_type`: use-after-free and
`Status_Error` during cleanup.

**Fix.** `close` now calls `lace.Subject.Logger_is (null)` and
`lace.Observer.Logger_is (null)` before destructing and freeing the logger.

### 3.8 Event relaying removed

**Files:** `events/interface/lace-observer.ads`,
`events/mixin/lace-event-make_observer.ads/.adb`,
`events/mixin/lace-event-make_observer-deferred.adb`,
`events/utility/lace-event-logger.ads`,
`events/utility/lace-event-logger-text.ads/.adb`,
`4-high/gel/source/gel-sprite.adb`

**Defect.** Relaying of responseless events had long been disabled (the old
`notify` call no longer exists) but its scaffolding remained, and the stub's
behaviour depended on whether a logger was installed: with one, it warned and
dropped the event; without one, it raised `Program_Error` — from inside the
event machinery — and crashed the application. `gel-sprite` still called
`relay_responseless_Events` on child attach, so any responseless event on an
attached child killed a logger-less app (the chains_2d / mixed_joints_2d
demos are reachable examples). Re-enabling relay would also have needed a
sequencing design decision: a relayed event carries the *child's* per-subject
sequence id, which the relay target would check against its *own* expected
counter — mismatched from the start, livelocking the target's deferred queue
exactly as in 3.6.

**Fix.** The relay feature is removed outright: the abstract
`relay_responseless_Events` operation is gone from the `lace.Observer`
interface, along with the mixin's implementation, the `relay_Target` state
and branches in both observer variants, the `gel-sprite` call on attach, and
the now-dead `log_Relay` operation on the `lace.Event.Logger` interface and
its text-logger implementation. A responseless event now simply takes the
pre-existing "has no response" path (a logged warning, or `Program_Error`
when no logger is installed).


## 4. Environ

### 4.1 Binary `load`/`save` could never work

**File:** `environ/lace-environ-paths.adb`

**Defect.** Two independent errors made the `Data` overloads dead on arrival:

- `load return Data` opened the file with mode `out_File` and then called
  `Direct_IO.Read` — the RM (A.8.4) allows `Read` only on `in_File` /
  `inout_File`, so every call raised `Mode_Error` (which escaped, since the
  handler only caught `Name_Error`).
- `save (File; Data)` called `check (Self)` first, and `check` raises `Error`
  when the path does not exist — so the binary save could never *create* a
  file, which is a save's primary job.

The `String` overloads had neither problem, so only binary I/O was broken.

**Fix.** `load` opens `in_File`; `save` drops the `check` and simply
`create`s, mirroring its working `String` sibling.

### 4.2 `expand_GLOB` executed its argument through a world-writable /tmp script

**File:** `environ/lace-environ-paths.adb`

**Defect.** `expand_GLOB` wrote `"echo " & GLOB` into the fixed path
`/tmp/lace_environ_temporary_shell.sh`, chmod'ed it `a+rwx`, and ran it with
bash. Three problems:

- **Command injection** — shell metacharacters in the argument executed as
  commands. `copy_Files` / `move_Files` / `rid_Files` route their `Named`
  argument here whenever it contains `*`, so a value like
  `"*.txt; rm -rf $HOME"` (say, a filename typed into a GUI) ran verbatim.
- **Symlink race** — the path is fixed and predictable; a pre-planted symlink
  redirected the create/chmod to an attacker-chosen target.
- **Clobbering** — two processes expanding globs concurrently overwrote each
  other's script (no exclusive create).

**Fix.** `expand_GLOB` is reimplemented with `ada.Directories` search: the
pattern is split into containing directory and simple-name pattern, matches
are collected (skipping `.` and `..`) and returned space-separated as full
names. No shell, no temp file, nothing executes. Two behaviour notes: the
pattern applies to the final path component (`dir/*.txt` works,
`dir/*/x.txt` does not — the old bash form allowed the latter), and a
pattern with no matches now returns an empty string instead of echoing the
pattern back.

### 4.3 Paths with spaces broke every shell-backed operation

**Files:** `environ/lace-environ-os_commands.ads/.adb`,
`environ/lace-environ-paths.adb`

**Defect.** Operations like `copy_Folder` built command lines by raw
concatenation — `run_OS ("cp -fr " & (+Self) & " " & (+To))`. `run_OS` hands
the string to aShell, which does **not** run it through a shell: it splits
the string on whitespace (via `GNAT.OS_Lib.Argument_String_To_List`) and
execs the program directly. A path containing a space therefore arrived as
two separate arguments (`cp` got `my` and `folder`), and a path containing
`" | "` was even mistaken for a pipeline. The same raw concatenation existed
in `link`, `move_Folder`, `change_Mode`, `change_Owner`, `touch`, `compress`
and `decompress`.

**Fix.** A new `OS_Commands.escaped` function backslash-escapes exactly the
characters aShell's parsing treats specially — space, double quote, backslash
and pipe — and every path interpolated into a `run_OS` command line now goes
through it. Backslash-escaping (rather than double-quoting) is deliberate:
`Argument_String_To_List` strips backslash escapes but keeps quote characters
*literally* in the argument, so quoting would hand `cp` a name with actual
`"` characters in it; the backslash form also breaks up the `" | "` substring
the pipeline sniffer looks for.


## 5. Below-cap findings (second pass)

The review confirmed more defects than its report cap allowed; this second
pass fixes those as well.

### 5.1 `lace.Text.delete` (procedure form) grew the text on an inverted range

**Files:** `text/lace-text.adb`, `text/wide/lace-wide_text.adb`

`delete (Self, From => 5, Through => 2)` subtracted a negative count from
`Length`, *growing* the text over uninitialised data. An empty, inverted or
past-the-end range is now an explicit no-op.

### 5.2 Empty texts could not survive a stream round-trip

**Files:** `text/lace-text.adb`, `text/wide/lace-wide_text.adb`

`Item_input` read the capacity with `Positive'read`, so a streamed empty text
(capacity 0) raised `Constraint_Error` on arrival — breaking DSA transfers of
empty texts. Capacity is now streamed as `Natural` on both sides (same wire
representation, so existing streams are unaffected).

### 5.3 `Cursor.advance` re-found the same delimiter on repeats

**Files:** `text/lace-text-cursor.adb`, `text/wide/lace-wide_text-cursor.adb`

With `skip_Delimiter => False` and `Repeat > 0`, intermediate iterations
positioned the cursor *on* the last character of the found delimiter
(`+ Delimiter'Length - 1`), so a one-character delimiter was found again by
the next repeat and the cursor never advanced past the first hit.
Intermediate repeats now step fully past the delimiter.

### 5.4 `Cursor.get_Integer` / `get_Real` crashed at the cursor end

**Files:** same as 5.3

At the cursor end (`Current = 0`) these built the slice
`Data (0 .. Length)` — `Constraint_Error` instead of the documented
`no_data_Error`. Both now test `at_End` first and raise `no_data_Error`.

### 5.5 `utility.replace` (function form) had hidden capacity ceilings

**Files:** `text/lace-text-utility.adb`, `text/wide/lace-wide_text-utility.adb`

The function tokenised with the fixed `items_1k` instantiation: any segment
between pattern occurrences longer than 1024 characters, or more than 8192
segments, raised `Error`; an empty input crashed on a negative size
computation. Rewritten as a single scan appending to an unbounded buffer — no
tokeniser, no ceilings, and the earlier tail-match guard becomes unnecessary.
The **wide procedure form** additionally fabricated a character when applied
to an empty text (its post-check loop ran once on empty input); it now uses
the narrow variant's pre-check `while` loop.

### 5.6 String- and character-delimiter `Tokens` disagreed on a trailing delimiter

**Files:** `text/lace-text-all_tokens.adb`, `text/wide/lace-wide_text-all_tokens.adb`

The character variant deliberately yields a final empty token when the text
ends with the delimiter; the string variant silently didn't. The string
variant now matches.

### 5.7 `lace.wide_Text.forge.to_String` failed on every file

**File:** `text/wide/lace-wide_text-forge.adb`

It sized a `wide_String` by the file's *byte* count and `Direct_IO`-read it —
asking for twice the file's bytes, so every call raised `End_Error`. The file
is now read as bytes and converted character-by-character (Latin-1), with the
CR stripping retained.

### 5.8 `lace.wide_Text` had lost `pragma Pure`

**File:** `text/wide/lace-wide_text.ads`

The narrow `lace.Text` is `Pure`; the wide spec carried only a
`-- with Pure` comment, which prevents `Remote_Types`/`Pure` clients from
depending on it. The pragma is restored.

### 5.9 `lace.Dice` rolled out of range and raced its generator

**Files:** `dice/lace-dice-any.adb`, `dice/lace-dice-d6.adb`

`any.Roll` computed each die as `Integer (Random * Sides + 0.5)` — Ada's
rounding conversion means `Random = 1.0` yielded `Sides + 1`. It also
returned `the_Roll + Modifier` directly into a `Natural`, so a sufficiently
negative modifier raised `Constraint_Error` (`d6` already floored at 0). Both
packages also shared one package-global generator across every task with no
synchronisation — a data race, since `Random` mutates the generator. Each die
is now `Integer'Min (Sides, Floor (Random * Sides) + 1)`, the modified total
floors at 0, and both generators live inside a protected object.

### 5.10 `shuffle_Vector` produced one fixed permutation every run

**File:** `containers/lace-containers-shuffle_vector.adb`

Each loop iteration instantiated a *fresh, unseeded* generator, so every run
of the program produced the same deterministic (and far from uniform)
"shuffle". Now a single time-seeded generator drives a standard Fisher-Yates
pass (with the `Random = 1.0` pick clamped to the slot range).

### 5.11 `fast_Pool` / `heap_based_Pool` overflowed on surplus frees

**Files:** `lace-fast_pool.adb`, `lace-heap_based_pool.adb`

`new_Item` allocates fresh items when the pool is empty, but `free` blindly
appended — freeing more items than `pool_Size` indexed past the array and
raised `Constraint_Error` inside the protected entry. A free into a full pool
now deallocates the item instead.

### 5.12 `array_based_Pool` crashed at program exit for an unused pool

**File:** `lace-array_based_pool.adb`

The high-water-mark finaliser declared `HWM : Positive`, so a pool that was
never used (mark 0) raised `Constraint_Error` during finalisation; and
`prior_HWM` was read uninitialised when no mark file existed yet. Both are
now `Natural`, with `prior_HWM` defaulting to 0.

### 5.13 A dead connection party could hang program exit

**File:** `events/lace-event_connector.adb`

The connector task's failure handler logged
`my_Connection.Subject.Name` / `.Observer.Name` / `.Response.Name` — remote
dereferences of the very views whose failure landed it in the handler. The
re-raise skipped the pool return, the delegator's
`all_Connectors_are_idle` wait never completed, and the program hung at
exit. Connectors now return to the pool *before* logging, the detail
dereferences are wrapped in their own handler (in the delegator's handlers
too), an undispatched connector is returned to the pool on dispatch failure,
and the idle test uses `>=` so a miscount degrades gracefully instead of
hanging.

### 5.14 The text logger's file was written by many tasks unsynchronised

**Files:** `events/utility/lace-event-logger-text.ads/.adb`

Every `log_*` operation wrote the shared `File_type` directly, and the
callers include concurrent emitter/sender pool tasks — interleaved and
formally erroneous concurrent I/O. All writes (and the close) now go through
a protected `Gate`, with each message built *before* the protected call so
remote `Name` fetches never run under the lock. `ignore` also used
`insert`, so ignoring the same event kind twice raised `Constraint_Error`;
it now uses `include`.

### 5.15 Sequence ids overflowed at the type bound

**File:** `events/mixin/private/lace-event-containers.adb`

`sequence_Id` spans `0 .. 2**32 - 1`; `get_Next`/`increment` raised
`Constraint_Error` at the last id (roughly 4 billion events per observer —
distant, but a stream-killing cliff). All three counter operations now wrap,
and since subject and observer counters move through the same operations,
the deferred observer's expected-sequence check stays consistent across the
wrap.

### 5.16 `superbounded` `Overwrite` (procedure form) rejected empty insertions

**File:** `strings/lace-strings-superbounded.adb`

The procedure form declared `Endpos : Positive := Position + new_Item'Length - 1`,
so overwriting with an empty string at position 1 computed 0 and raised
`Constraint_Error` in the declarative part (the function form declares it
`Natural` and returns early). Now `Natural`, making an empty overwrite the
no-op it should be.

### 5.17 `OS_Commands.Path_to` mistyped its result

**Files:** `environ/lace-environ-os_commands.ads/.adb`

`which <command>` names an executable *file*, but `Path_to` returned it as a
`Paths.Folder`. It now returns `Paths.File` (no in-tree callers existed),
and the command name passes through `escaped` like every other interpolation.

### Reviewed and deliberately left alone

Three "plausible" findings were examined and not changed: the `Connection`
record's `item_256` event-kind capacity (a >256-character event kind name
would be needed to trigger it), `folder_Lock`'s I/O inside a protected action
(effectively dead code today), and the instant subject-and-observer combo's
destroy chain (no in-tree user constructs one).


## 6. Design pass

Three design-level issues noted during the review, addressed after the two
defect passes.

### 6.1 User responses ran inside a protected action

**Files:** `events/mixin/lace-event-make_observer.ads/.adb`

An instant observer's `receive` ran the user's `respond` callback (and the
logging around it) inside the `safe_Responses` protected action. A response
that called `add` or `rid` on its own observer deadlocked on the protected
object, and running arbitrary user code — potentially blocking I/O and
remote calls included — inside a protected action is a bounded error
besides. The protected object now only *looks up* the response (a new
`find` operation returning the response view, whether the subject is known,
and the response count in one atomic read); `receive` dispatches the
response and does all logging outside the lock. The deferred observer
already dispatched outside the lock; the instant path now matches.

### 6.2 `make_Subject.destroy` leaked its emitter and sender

**File:** `events/mixin/lace-event-make_subject.adb`

`destroy` stopped the emitter/sender delegators but never freed the
heap-allocated `event_Emitter.item` / `event_Sender.item` objects, and a
second destroy re-entered them. Since destroy became synchronous (§3.2) the
delegator tasks are terminated when it returns, so the objects are now
freed and the views nulled — a repeated destroy is harmless.

### 6.3 `observer_Count` counted an observer once per registered kind

**File:** `events/mixin/lace-event-make_subject.adb`

The body summed the per-kind vector lengths (and carried a
`TODO: This is wrong` comment), so an observer registered for three event
kinds counted three times. It now counts distinct observer views.


## 7. Re-review pass

A second full review of `1-base/lace/source` was run after all the above to
check the fixes themselves. It confirmed every earlier defect stayed fixed —
and found a batch of new ones, almost all in the DSA *failure* paths that
the happy-path tests (local and distributed) cannot reach. This pass fixes
them.

### 7.1 Failure handlers dereferenced the dead observer

**Files:** `events/mixin/lace-event-make_subject.adb`,
`events/mixin/private/lace-event_emitter.adb`,
`events/mixin/private/lace-event_sender.adb`

The emit/send failure handlers introduced in §3.6 named the observer via
`my_Observers (i).Name` — a remote call on the very observer whose death
raised the exception — so the handler re-raised, the remaining observers
never received the event, and the id was never restored. The observer's
name is now fetched once, before delivery (a failure there is handled per
observer without touching the counter), and the handlers use the saved
name. The emitter/sender worker and fatal handlers got the same dead-party
guards around their `Observer:` log lines that the connector already had,
so a failed delivery can no longer kill a pooled worker task. The emitter
delegator also now takes `next_Sequence` inside its handled region, so one
dead observer no longer brings down the whole delegator through its fatal
handler.

### 7.2 A rendezvous-body exception double-freed a pooled worker

**Files:** `events/mixin/private/lace-event_emitter.adb`,
`events/mixin/private/lace-event_sender.adb`,
`events/lace-event_connector.adb`

An exception raised inside an `accept` body propagates to *both* rendezvous
partners, so the worker's return-to-pool (§3.1) and the delegator's
return-undispatched-worker each added the same view — and the count-driven
shutdown then deallocated the same task object twice. The delegator now
returns a worker only on `Tasking_Error` (the callee never engaged); any
other exception reached the worker too, which returns itself.

### 7.3 The sequence rollback fired after successful delivery

**File:** `events/mixin/lace-event-make_subject.adb`

The §3.6 `decrement` handler also covered the logging *after* a successful
`receive`, so a failure in `log_Emit`/`log_Send` rolled back an id that had
in fact been delivered, producing a duplicate. The rollback is now scoped
to the `receive` call alone.

### 7.4 `expand_GLOB` behaviour restored

**File:** `environ/lace-environ-paths.adb`

The §4.2 rewrite changed observable behaviour: matches came back in raw
directory order (the old bash echo sorted them), bare globs gained a `./`
prefix via `full_Name` (breaking `move_Files`' self-move comparison), a
no-match glob returned an empty string (silently turning `rid_Files` of a
typo'd pattern into a no-op), and a missing folder leaked `Name_Error`.
Matches are now sorted and prefixed exactly as the pattern was written, and
an unmatched pattern (or one naming a missing folder) is echoed back
verbatim — the shell's behaviour, which downstream `check` calls turn into
the same `Error` as before.

### 7.5 String-delimiter tokens fabricated a trailing empty token

**Files:** `text/lace-text-all_tokens.adb`,
`text/wide/lace-wide_text-all_tokens.adb`, `text/lace-text-cursor.ads`,
`text/wide/lace-wide_text-cursor.ads`

The §5.6 trailing-delimiter test examined the raw text tail, so a tail that
merely *overlapped* a delimiter occurrence (splitting `"aaa"` on `"aa"`)
fabricated an extra empty token. The test now asks the cursor where the
scan actually ended (`at_End`, made public for the purpose: it is false
after a scan only when a final delimiter was consumed), which cannot
disagree with the fill pass.

### 7.6 Dropped guards restored

**Files:** `text/wide/lace-wide_text-forge.adb`,
`text/lace-text-utility.adb`, `text/wide/lace-wide_text-utility.adb`

The §5.7 wide file reader lost its narrow twin's empty-file guard (an empty
file raised `End_Error`), and the `replace` procedure never got the
empty-pattern guard the function form gained in §5.5 (an empty pattern
looped forever or overflowed capacity). Both guards are now in place, both
widths.

### 7.7 Connector hardening completed

**File:** `events/lace-event_connector.adb`

`destruct` now waits for the delegator's termination like its emitter and
sender twins (§3.2), so the `Connections` queue cannot be used after the
enclosing object is reclaimed; the delegator's pool re-add is gated on
`Tasking_Error` as in §7.2.

### 7.8 Deregistering a dead observer raised from inside the lock

**Files:** `events/mixin/lace-event-make_subject.ads/.adb`

Found not by review but by the new partition-failure test (below):
`safe_Observers.rid` called `the_Observer.Name` — a remote call, on an
observer being deregistered precisely because it died — inside the protected
action. The `communication_Error` escaped `deregister`, crossed DSA back
into the caller (in the demo: the registrar's client-checker task, killing
it, after which `shutdown`'s `halt` raised `Tasking_Error` out of the
program). `rid` now just reports whether the observer remains registered
for any other kind, and `deregister` fetches the name outside the lock,
guarded — a dead observer leaves at most a stale sequence-map entry, which
is unreachable and harmless. The `check_Client_lives` task and `shutdown`
in the chat demo's registrar were hardened for the same scenario.

### 7.9 Small leftovers

`shuffle_Vector` crashed on a vector with fewer than two elements (the
`Index_type` conversion of a zero length); it now returns at once. The text
logger's `destruct` closed an already-closed file on a second call; the
Gate now tolerates it. And six formatting-guide deviations in code added by
this series (two-blank gaps in the new protected bodies, a missing blank
before an `else`) were brought back to the guide.

### Known limitations, deliberately retained

The re-review also flagged things that are design decisions rather
than oversights; they stand, documented (the async sequence-id loss that
originally headed this list was later fixed properly — see §9):

- **Responses dispatch outside the lock** (§6.1) — restoring per-observer
  response serialisation would restore the add/rid deadlock; responses that
  mutate shared state must synchronise themselves, and response objects
  must not be freed while events are in flight.
- **`destroy` must not race `emit`/`send`** (§6.2) — destroy frees the
  emitter/sender; callers must stop emitting before destroying, as with
  any deallocation.


## 8. Logger pass

**Files:** `events/utility/lace-event-logger-text.adb`,
`events/mixin/lace-event-make_observer.ads/.adb`

The §5.14 serialisation guarded the shared log file with a protected
`Gate` whose operations performed the `Text_IO` themselves — a potentially
blocking operation inside a protected action, which is a bounded error
(RM 9.5.1): tolerated by GNAT's default runtime, rejected under
`Detect_Blocking`, and in any case blocking other tasks at ceiling
priority behind disk I/O. This pass replaces it with a seize/release lock
(a protected entry/procedure pair) held *across* the writes, which
therefore happen in plain task context. The `Ignored` set — previously
read by `log_Emit`/`log_Send`/`log_Response` unsynchronised against
`ignore` — is accessed under the same lock.

For that to be sound, no logger call may come from inside a protected
action any more (an entry call there would be the same bounded error).
The last two such calls — `log_new_Response` / `log_rid_Response` inside
`safe_Responses.add`/`rid` — moved out: the protected operations now only
mutate the maps (`rid` reports whether the subject's last response was
removed), and the enclosing plain procedures do the sequence-map upkeep
and the logging, exactly as `receive` already did after §6.1.


## 9. Reserve/commit sequence-id pass

**Files:** `events/interface/lace-subject.ads`,
`events/mixin/lace-event-make_subject.ads/.adb`,
`events/mixin/private/lace-event_emitter.adb`,
`events/mixin/private/lace-event_sender.ads/.adb`,
`1-base/lace/applet/test/regression/` (new coverage)

The one remaining *unsound* failure path: a delivery that failed inside a
pooled emitter/sender worker burned its sequence id, permanently stalling
that subject's deferred observers, and no rollback from the worker was
possible — the delegator might have issued later ids for the same observer
meanwhile, so a decrement would forge a duplicate.

The fix removes the "meanwhile". The emitter and sender delegators now
route deliveries through per-observer **channels**: each observer has a
pending queue and at most one delivery in flight; a worker reports back
when its delivery ends (success or failure), which reopens the channel for
the next dispatch. With deliveries serialised per observer, the id can be
taken *by the worker, immediately before `receive`* — the observer's name
is fetched first (a dead observer fails there, before any id is taken) —
and restored immediately on a failed delivery, soundly, because no later
id can exist for that observer. The next delivery reuses the id, so the
observer-side sequence stays contiguous and the deferred-observer livelock
class is gone. Cross-observer and cross-subject parallelism is unchanged;
per-observer serialisation only removes a concurrency the sequence-check
machinery existed to compensate for.

Supporting changes: `lace.Subject`'s `next_Sequence` now takes the observer
*name* (fetched once, guarded) instead of a view, and gained
`restore_Sequence`; the sender's queued details no longer carry a
precomputed id; a delegator that finds a worker dead at dispatch
(`Tasking_Error`) frees the corpse and retries the still-queued delivery
with a fresh worker, rather than dropping the event.

The synchronous emit/send rollback (§3.6/§7.3) keeps its documented caveat:
it is sound for a single emitting task per subject; concurrent synchronous
emits to one subject can still interleave take and rollback. Mixing
synchronous `emit` calls with an installed emitter has the same property.

Coverage: the async machinery previously had **no user in the entire tree**
— nothing called `use_event_Emitter`/`use_event_Sender`, which is how the
id-loss survived every demo and test. `test_regression` now drives the
emitter end to end: 100 events through a subject with an emitter to a
deferred observer, asserting complete, in-order delivery (the event and
response types live in the new `regression_Events` remote-types unit, since
class-wide events sent through the potentially-remote subject interface
must be transportable) and a clean synchronous destroy.


## 10. Deduplication pass

The re-review's altitude findings all pointed at one habit: the same logic
maintained in several copies, which this series repeatedly had to patch in
lockstep.

### 10.1 `sequence_Id` is now modular

**Files:** `events/lace-event.ads`,
`events/mixin/private/lace-event-containers.adb`

`lace.Event.sequence_Id` became `mod 2**32`, so wrapping is a property of
the type rather than an if-expression hand-copied into `get_Next`,
`increment` and `decrement`. This changes the id's stream representation
(the old range type had a 64-bit base), which only matters across DSA
partitions — and partitions are always rebuilt together by `po_gnatdist`.

### 10.2 The emitter and sender share their delivery machinery

**Files:** `events/mixin/private/lace-event_courier.ads/.adb` (new),
`events/mixin/private/lace-event_emitter.ads/.adb`,
`events/mixin/private/lace-event_sender.ads/.adb`

After the reserve/commit pass (§9) the two bodies were ~95% identical. The
courier tasks, pool, delivery reports, per-observer channels, dispatching
and shutdown now live once, in the generic `lace.event_Courier`
(parameterised only by the names used in its log messages). The emitter and
sender bodies keep exactly what differs: the emitter expands each event to
every observer of its kind; the sender queues each event to one named
observer.

### 10.3 `heap_based_Pool` renames `fast_Pool`

**File:** `lace-heap_based_pool.ads`

The two pool generics had become byte-identical apart from the unit name;
`lace.heap_based_Pool` is now a library-unit renaming of `lace.fast_Pool`.

### 10.4 The dice share one random source

**Files:** `dice/lace-dice-random.ads/.adb` (new), `dice/lace-dice-any.adb`,
`dice/lace-dice-d6.adb`

The verbatim-duplicated `safe_Generator` protected objects collapsed into
the private child `lace.Dice.random`, which also owns the single clamped
uniform-draw formula (`d6` previously used its own `discrete_Random`
instance). One behavioural note: `Seed_is` in either dice package now seeds
the shared source.


## 11. Remainders

**Files:** `text/lace-text.adb`, `text/wide/lace-wide_text.adb`,
`1-base/lace/alire.toml`, `4-high/gel/alire.toml`

`Item_input` trusted a stream-supplied capacity and length: a corrupt DSA
stream could request an arbitrarily large stack allocation, and a length
beyond the capacity died on a bare range check. The length is now validated
against the capacity (raising `Error` with a clear message), and the text
is built in place in the function result instead of through a stack-sized
local copy — so large texts no longer transit the primary stack twice.

The Alire crate versions were brought up to date: `lace` to 2.0.0 (this
series changes the public Observer and Subject interfaces) and `lace_gel`
to 1.0.1 (an internal change only).


## Verification

- **Full tree:** `5-all/applet/build_all` compiles every component and demo
  cleanly (the only warning is pre-existing, in the vendored box2d port).
- **Existing tests:** `test_text`, `test_job`, `test_environ_general`,
  `test_environ_paths`, `test_environ_compression` all pass; the instant and
  deferred simple-event demos run and exit cleanly (exercising the new
  worker-pool shutdown, synchronous destroy and sequence machinery).
- **Targeted checks:** a throwaway 16-check program exercised each fixed bug
  directly — all hours through `to_Duration`, `to_Time` at an hour boundary,
  the `delete` function form, `replace` with an over-long pattern, 1k-token
  tokenisation of tiny inputs, trailing-delimiter tokens, one-perform-per-pass
  and `Never`-deletion in the job manager, the binary save/load round-trip on
  a new file, `expand_GLOB`, `copy_Files` with a glob, `copy_Folder` of
  `my folder`, and `touch` of `sp ace.txt`. All pass.

The second (below-cap) pass was verified the same way: a clean full-tree
`build_all`, the existing applet tests (`test_text`, `test_job`, `test_dice`,
the three environ tests, both event demos), and the targeted check program
extended to 34 checks — inverted-range delete, the empty-text stream
round-trip, cursor repeat-advance and end-of-cursor behaviour, replace beyond
the old ceilings and on empty texts, trailing-delimiter token agreement, the
wide file reader, 10,000 bounded dice rolls with both extremes reached, the
negative-modifier floor, element-preserving randomised shuffles, and
over-freeing a two-slot pool. All pass.

That check program is now a permanent test applet,
`1-base/lace/applet/test/regression` (`test_regression`), wired into
`build_all` like the other tests.

The events overhaul was also exercised under DSA: the `simple_chat` demo was
rebuilt with `po_gnatdist` against the fixed sources and run locally
(`po_cos_naming` + registrar partition + two client partitions). Messages
crossed partitions in both directions, join/leave notifications fired,
deregistration completed cleanly, and both clients exited normally with no
hang at shutdown.

The design pass was re-verified end to end: a clean full-tree `build_all`,
all 34 regression checks, both simple event demos, the `simple_chat` DSA run
repeated (the instant observer's receive is exactly the restructured path),
and the `chains_2d` and `mixed_joints_2d` gel demos run live under X and
closed via `WM_DELETE_WINDOW`, so the full applet, world and sprite teardown
executes. Every run exits cleanly.

The re-review pass (§7) was verified the same way, with the regression suite
extended to 40 checks (overlapping-delimiter tokenisation, the empty-pattern
replace procedure, the empty wide file, and the sorted / prefix-preserving /
pattern-echoing `expand_GLOB` contract) — full-tree `build_all`, all applet
tests, both event demos and the DSA chat run all pass.

Finally, the testing gap this whole exercise exposed — every serious late
finding lived in the DSA *failure* paths — is now covered by a checked-in
test: `1-base/lace/applet/demo/event/distributed/test/partition_failure/test.sh`
starts the name server, the registrar and two chat clients, kills one client
with SIGKILL mid-conversation, and asserts that the survivor's next
broadcast completes, that survivor and registrar both exit cleanly, and that
no partition reports an unhandled exception. Its first run caught §7.8.
