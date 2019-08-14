#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/get-rss.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
get-rss-help()
{
	__monitor HELP "$@"
}

_is_rctl_available()
{
	return 0 # true
}

print_rss()
{
	__monitor PRINT "$@"
}

test_pot_get_rss_001()
{
	pot-get-rss
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "print_rss calls" "0" "$PRINT_CALLS"

	setUp
	pot-get-rss -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "print_rss calls" "0" "$PRINT_CALLS"

	setUp
	pot-get-rss -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "print_rss calls" "0" "$PRINT_CALLS"
}

test_pot_get_rss_002()
{
	pot-get-rss -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "print_rss calls" "0" "$PRINT_CALLS"
}

test_pot_get_rss_020()
{
	pot-get-rss -p test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "print_rss calls" "1" "$PRINT_CALLS"
	assertEquals "print_rss arg1" "test-pot" "$PRINT_CALL1_ARG1"
	assertEquals "print_rss arg2" "" "$PRINT_CALL1_ARG2"
}

test_pot_get_rss_021()
{
	pot-get-rss -p test-pot-2 -J
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "print_rss calls" "1" "$PRINT_CALLS"
	assertEquals "print_rss arg1" "test-pot-2" "$PRINT_CALL1_ARG1"
	assertEquals "print_rss arg2" "YES" "$PRINT_CALL1_ARG2"
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
