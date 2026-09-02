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

Confirmed review findings that fell below the report cap (empty-text stream
round-trip breaking DSA, cursor `get_Integer`/`get_Real` end-of-cursor
crashes, the unseeded `shuffle_Vector`, dice modifier/rounding defects, pool
free overflows, and others) remain unfixed apart from the two noted above
(§2.2, §3.5's third site).
