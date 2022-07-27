#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/term.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs

pot-cmd()
{
	__monitor POTCMD "$@"
	if [ "$POTCMD_SHOULD_START_POT" = "yes" ]; then
		_pname="test-pot-run"
	fi
}


_term()
{
	__monitor TERM "$@"
}

term-help()
{
	__monitor HELP "$@"
}

test_pot_term_001()
{
	pot-term
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_term calls" "0" TERM_CALLS
	assertEqualsMon "pot-cmd calls" "0" POTCMD_CALLS

	setUp
	pot-term -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "_term calls" "0" TERM_CALLS
	assertEqualsMon "pot-cmd calls" "0" POTCMD_CALLS

	setUp
	pot-term -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_term calls" "0" TERM_CALLS
	assertEqualsMon "pot-cmd calls" "0" POTCMD_CALLS
}

test_pot_term_020()
{
	pot-term test-pot-run
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "_term calls" "1" TERM_CALLS
	assertEqualsMon "pot-cmd calls" "0" POTCMD_CALLS
}

test_pot_term_030()
{
	pot-term test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "_term calls" "0" TERM_CALLS
	assertEqualsMon "pot-cmd calls" "0" POTCMD_CALLS
}

test_pot_term_031()
{
	pot-term -f test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot_running calls" "2" ISPOTRUN_CALLS
	assertEqualsMon "_term calls" "0" TERM_CALLS
	assertEqualsMon "pot-cmd calls" "1" POTCMD_CALLS
}

test_pot_term_032() {
	# In this test "pot-cmd start" is changing pot name from
	# test-pot to test-pot-run.
	POTCMD_SHOULD_START_POT=yes
	pot-term -f test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot_running calls" "2" ISPOTRUN_CALLS
	assertEqualsMon "_term calls" "1" TERM_CALLS
	assertEqualsMon "pot-cmd calls" "1" POTCMD_CALLS
}


setUp()
{
	common_setUp
	POTCMD_SHOULD_START_POT=no
}

. shunit/shunit2
