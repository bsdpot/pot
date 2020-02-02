#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/term.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs

_term()
{
	return 0 # true
}

term-help()
{
	__monitor HELP "$@"
}

test_pot_term_001()
{
	pot-term
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"

	setUp
	pot-term -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"

	setUp
	pot-term -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
}

. shunit/shunit2
