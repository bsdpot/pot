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
	return 0 # true
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

	setUp
	pot-stop -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"

	setUp
	pot-stop -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	PRINT_CALLS=0
	PRINT_CALL1_ARG1=
	PRINT_CALL1_ARG2=
}

. shunit/shunit2
