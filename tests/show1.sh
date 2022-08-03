#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/show.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
show-help()
{
	__monitor HELP "$@"
}

_show_pot()
{
	__monitor SHOWPOT "$@"
}

_show_all_pots()
{
	__monitor SHOWALLPOTS "$@"
}

_show_running_pots()
{
	__monitor SHOWRUNPOTS "$@"
}

test_pot_show_001()
{
	pot-show -k bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS

	setUp
	pot-show -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

test_pot_show_002()
{
	pot-show -a -r
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

test_pot_show_003()
{
	pot-show -a -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

test_pot_show_004()
{
	pot-show -a -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

test_pot_show_005()
{
	pot-show -r -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

test_pot_show_006()
{
	pot-show -r -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

test_pot_show_010()
{
	pot-show -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

test_pot_show_020()
{
	pot-show
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "1" SHOWRUNPOTS_CALLS
}

test_pot_show_021()
{
	pot-show -r
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "1" SHOWRUNPOTS_CALLS
}

test_pot_show_022()
{
	pot-show -a
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "show_pot calls" "0" SHOWPOT_CALLS
	assertEqualsMon "show_all_pots calls" "1" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

test_pot_show_023()
{
	pot-show -p test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "show_pot calls" "1" SHOWPOT_CALLS
	assertEqualsMon "show_pot arg" "test-pot" SHOWPOT_CALL1_ARG1
	assertEqualsMon "show_all_pots calls" "0" SHOWALLPOTS_CALLS
	assertEqualsMon "show_running_pots calls" "0" SHOWRUNPOTS_CALLS
}

setUp()
{
	common_setUp
}

. shunit/shunit2
