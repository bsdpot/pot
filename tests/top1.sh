#!/bin/sh

EXIT="return"

# system utilities stubs

top()
{
	__monitor TOP "$@"
}

# UUT
. ../share/pot/top.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
top-help()
{
	__monitor HELP "$@"
}

test_pot_top_001()
{
	pot-top -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "top calls" "0" "$TOP_CALLS"

	setUp
	pot-top -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "top calls" "0" "$TOP_CALLS"
}

test_pot_top_020()
{
	pot-top -p
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "top calls" "0" "$TOP_CALLS"
	assertEquals "top arg1" "" "$TOP_CALL1_ARG1"
}

test_pot_top_021()
{
	pot-top -p ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "top calls" "0" "$TOP_CALLS"
	assertEquals "top arg1" "" "$TOP_CALL1_ARG1"
}

test_pot_top_022()
{
	pot-top -p no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "top calls" "0" "$TOP_CALLS"
	assertEquals "top arg1" "" "$TOP_CALL1_ARG1"
}

test_pot_top_023()
{
	pot-top -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "top calls" "0" "$TOP_CALLS"
	assertEquals "top arg1" "" "$TOP_CALL1_ARG1"
}

test_pot_top_040()
{
	pot-top -p test-pot-run
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "top calls" "1" "$TOP_CALLS"
	assertEquals "top arg1" "-J" "$TOP_CALL1_ARG1"
	assertEquals "top arg2" "test-pot-run" "$TOP_CALL1_ARG2"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	TOP_CALLS=0
}

. shunit/shunit2
