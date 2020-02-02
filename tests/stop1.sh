#!/bin/sh

# system utilities stubs

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
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "Stop calls" "0" "$STOPPED_CALLS"

	setUp
	pot-stop -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "Stop calls" "0" "$STOPPED_CALLS"

	setUp
	pot-stop -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "Stop calls" "0" "$STOPPED_CALLS"
}

test_pot_stop_002()
{
	pot-stop non-existent-test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "Stop calls" "0" "$STOPPED_CALLS"
}

test_pot_stop_020()
{
	pot-stop test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "Stop calls" "1" "$STOPPED_CALLS"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	STOPPED_CALLS=0
}

. shunit/shunit2
