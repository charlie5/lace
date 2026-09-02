#!/bin/bash
#
# Partition-failure test for the simple_chat DSA demo.
#
# Starts a local name server, the registrar partition and two client partitions,
# then kills one client with SIGKILL mid-conversation and checks that:
#
#   - the survivor's next broadcast completes despite the dead peer,
#   - the survivor still exits cleanly on 'q',
#   - the registrar still shuts down cleanly with the dead client registered,
#   - no partition reports an unhandled exception and nothing hangs at exit.
#
# This exercises the dead-party failure paths (communication_Error handling in
# emit/send, worker tasks and shutdown) which the happy-path tests never reach.
#
# Run after building the partitions with ../../builder.sh:
#
#   $ ./test.sh

BIN="$(cd "$(dirname "$0")/../../bin" && pwd)"
WORK=$(mktemp -d /tmp/lace_partition_failure.XXXXXX)

NAMER_PID=""
REG_PID=""
ROD_PID=""
IAN_PID=""

cleanup ()
{
   kill $NAMER_PID $REG_PID $ROD_PID $IAN_PID 2>/dev/null
   rm -fr "$WORK"
}
trap cleanup EXIT

fail ()
{
   echo "FAIL: $1"
   exit 1
}

[ -x "$BIN/registrar_partition" ] || fail "partitions not built ~ run ../../builder.sh first"

mkdir -p "$WORK/namer" "$WORK/registrar" "$WORK/rod" "$WORK/ian"

echo "Begin Test"

# Name server.
#
cd "$WORK/namer"
po_cos_naming > namer.out 2>&1 &
NAMER_PID=$!

for i in $(seq 1 50); do
   grep -q corbaloc namer.out 2>/dev/null && break
   sleep 0.2
done

NS=$(grep -o 'corbaloc:[^ ]*' namer.out | head -1)
[ -n "$NS" ] || fail "no name service reference"

for d in registrar rod ian; do
   printf '[dsa]\nname_service=%s\n' "$NS" > "$WORK/$d/polyorb.conf"
done

# Registrar.
#
cd "$WORK/registrar"
{ sleep 40; echo q; } | "$BIN/registrar_partition" > registrar.out 2>&1 &
REG_PID=$!
sleep 3

# Client 'rod' ~ the survivor.
#
cd "$WORK/rod"
{ sleep 8; echo "hello before the kill"; sleep 8; echo "hello after the kill"; sleep 4; echo q; } \
   | "$BIN/client_partition" rod > rod.out 2>&1 &
ROD_PID=$!
sleep 3

# Client 'ian' ~ the victim. Idles until killed.
#
cd "$WORK/ian"
{ sleep 60; } | "$BIN/client_partition" ian > ian.out 2>&1 &
IAN_PID=$!

sleep 8                        # Both clients are up and the first broadcast has flowed.

kill -9 $IAN_PID               # Kill the victim without any cleanup.
wait $IAN_PID 2>/dev/null
IAN_PID=""
echo "victim killed"

wait $ROD_PID
ROD_RC=$?
ROD_PID=""

wait $REG_PID
REG_RC=$?
REG_PID=""

echo "survivor exit: $ROD_RC   registrar exit: $REG_RC"
echo "== survivor output"
cat "$WORK/rod/rod.out"
echo "== registrar output"
cat "$WORK/registrar/registrar.out"

# Checks.
#
[ $ROD_RC = 0 ]                                          || fail "the survivor did not exit cleanly"
[ $REG_RC = 0 ]                                          || fail "the registrar did not exit cleanly"
grep -q "ian is here."             "$WORK/rod/rod.out"   || fail "the mesh never formed before the kill"
! grep -q "Unhandled exception"    "$WORK/rod/rod.out"   || fail "the survivor hit an unhandled exception"
! grep -q "Unhandled exception"    "$WORK/registrar/registrar.out" \
                                                         || fail "the registrar hit an unhandled exception"

echo
echo "Success"
echo "End Test"
