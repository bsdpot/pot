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
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "print_rss calls" "0" PRINT_CALLS

	setUp
	pot-get-rss -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "print_rss calls" "0" PRINT_CALLS

	setUp
	pot-get-rss -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "print_rss calls" "0" PRINT_CALLS
}

test_pot_get_rss_002()
{
	pot-get-rss -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "print_rss calls" "0" PRINT_CALLS
}

test_pot_get_rss_020()
{
	pot-get-rss -p test-pot-run
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "print_rss calls" "1" PRINT_CALLS
	assertEqualsMon "print_rss arg1" "test-pot-run" PRINT_CALL1_ARG1
	assertEqualsMon "print_rss arg2" "" PRINT_CALL1_ARG2
}

test_pot_get_rss_021()
{
	pot-get-rss -p test-pot-run-2 -J
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "print_rss calls" "1" PRINT_CALLS
	assertEqualsMon "print_rss arg1" "test-pot-run-2" PRINT_CALL1_ARG1
	assertEqualsMon "print_rss arg2" "YES" PRINT_CALL1_ARG2
}

setUp()
{
	common_setUp
}

. shunit/shunit2
