#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/ps.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
ps-help()
{
	__monitor HELP "$@"
}

_ps_pots()
{
	__monitor PSPOTS "$@"
}

_is_vnet_up()
{
	return 0 # true
}

test_pot_ps_001()
{
	pot-ps -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "ps_pots calls" "0" PSPOTS_CALLS

	setUp
	pot-ps -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "ps_pots calls" "0" PSPOTS_CALLS
}

test_pot_ps_020()
{
	pot-ps -q
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "ps_pots calls" "1" PSPOTS_CALLS
	assertEqualsMon "ps_pots arg1" "quiet" PSPOTS_CALL1_ARG1
}

test_pot_ps_021()
{
	pot-ps
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "ps_pots calls" "1" PSPOTS_CALLS
	assertEqualsMon "ps_pots arg1" "" PSPOTS_CALL1_ARG1
}

setUp()
{
	common_setUp
}

. shunit/shunit2
