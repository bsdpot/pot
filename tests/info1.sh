#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/info.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
info-help()
{
	__monitor HELP "$@"
}

_info_pot()
{
	__monitor INFOPOT "$@"
}

_info_pot_env()
{
	__monitor INFOPOTENV "$@"
}

_info_pot_snapshots()
{
	__monitor INFOPOTSNAP "$@"
}

test_pot_info_001()
{
	pot-info
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS

	setUp
	pot-info -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS

	setUp
	pot-info -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS

	setUp
	pot-info -v
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
}

test_pot_info_002()
{
	pot-info -p test-pot -v -q
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS

	setUp
	pot-info -p test-pot -v -q -r
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS
}

test_pot_info_003()
{
	pot-info -p test-pot -B test-bridge
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS
}

test_pot_info_020()
{
	pot-info -p
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS

	setUp
	pot-info -p not-a-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS
}

test_pot_info_021()
{
	pot-info -p test-pot -q
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS
}

test_pot_info_022()
{
	pot-info -p test-pot -qr
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS
}

test_pot_info_023()
{
	pot-info -p test-pot-run -qr
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS
}

test_pot_info_040()
{
	pot-info -p test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "1" INFOPOT_CALLS
	assertEqualsMon "Info arg" "test-pot" INFOPOT_CALL1_ARG1
}

test_pot_info_041()
{
	pot-info -p test-pot -v
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "1" INFOPOT_CALLS
	assertEqualsMon "Info arg" "test-pot" INFOPOT_CALL1_ARG1
}

test_pot_info_042()
{
	pot-info -p test-pot -r
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS
}

test_pot_info_043()
{
	pot-info -p test-pot -s
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "Info calls" "0" INFOPOT_CALLS
	assertEqualsMon "InfoSnap calls" "1" INFOPOTSNAP_CALLS
}

setUp()
{
	common_setUp
}

. shunit/shunit2
