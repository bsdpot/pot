#!/bin/sh

# system utilities stubs

lockf()
{
	return 0
}
# UUT
. ../share/pot/stop.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs

_js_rm_resolv()
{
	return 0 # true
}

_pot_umount()
{
	return 0 # true
}

_epair_cleanup()
{
	return 0 # true
}

_js_stop()
{
	__monitor STOPPED "$@"
}

stop-help()
{
	__monitor HELP "$@"
}

test_pot_stop_001()
{
	pot-stop
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "Stop calls" "0" STOPPED_CALLS

	setUp
	pot-stop -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Stop calls" "0" STOPPED_CALLS

	setUp
	pot-stop -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Stop calls" "0" STOPPED_CALLS
}

test_pot_stop_002()
{
	pot-stop non-existent-test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "Stop calls" "0" STOPPED_CALLS
}

test_pot_stop_020()
{
	pot-stop test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Stop calls" "1" STOPPED_CALLS
	assertEqualsMon "stop args" "test-pot" STOPPED_CALL1_ARG1
	assertEqualsMon "stop args" "NO" STOPPED_CALL1_ARG2
	assertEqualsMon "stop args" "" STOPPED_CALL1_ARG3
}

test_pot_stop_021()
{
	pot-stop -p test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Stop calls" "1" STOPPED_CALLS
	assertEqualsMon "stop args" "test-pot" STOPPED_CALL1_ARG1
	assertEqualsMon "stop args" "NO" STOPPED_CALL1_ARG2
	assertEqualsMon "stop args" "" STOPPED_CALL1_ARG3
}

test_pot_stop_022()
{
	pot-stop -p test-pot -s
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Stop calls" "1" STOPPED_CALLS
	assertEqualsMon "stop args" "test-pot" STOPPED_CALL1_ARG1
	assertEqualsMon "stop args" "YES" STOPPED_CALL1_ARG2
	assertEqualsMon "stop args" "" STOPPED_CALL1_ARG3
}

test_pot_stop_023()
{
	pot-stop -p test-pot -s -i epair4a
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Stop calls" "1" STOPPED_CALLS
	assertEqualsMon "stop args" "test-pot" STOPPED_CALL1_ARG1
	assertEqualsMon "stop args" "YES" STOPPED_CALL1_ARG2
	assertEqualsMon "stop args" "epair4a" STOPPED_CALL1_ARG3
}

setUp()
{
	common_setUp
}

. shunit/shunit2
