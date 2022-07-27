#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/set-cmd.sh

# common stubs
. common-stub.sh

# app specific stubs
set-cmd-help()
{
	__monitor HELP "$@"
}

_set_command()
{
	__monitor SETCMD "$@"
}

test_pot_set_cmd_001()
{
	pot-set-cmd
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_command calls" "0" SETCMD_CALLS

	setUp
	pot-set-cmd -bv
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_command calls" "0" SETCMD_CALLS

	setUp
	pot-set-cmd -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_command calls" "0" SETCMD_CALLS

	setUp
	pot-set-cmd -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_command calls" "0" SETCMD_CALLS
}

test_pot_set_cmd_002()
{
	pot-set-cmd -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_command calls" "0" SETCMD_CALLS

	setUp
	pot-set-cmd -c sh
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_command calls" "0" SETCMD_CALLS
}

test_pot_set_cmd_020()
{
	pot-set-cmd -p test-no-pot -c "sh /etc/rc"
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_command calls" "0" SETCMD_CALLS
}

test_pot_set_cmd_040()
{
	pot-set-cmd -p test-pot -c "/echo Hello World"
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_command calls" "1" SETCMD_CALLS
	assertEqualsMon "_set_command arg1" "test-pot" SETCMD_CALL1_ARG1
	assertEqualsMon "_set_command arg2" "/echo Hello World" SETCMD_CALL1_ARG2
}

setUp()
{
	common_setUp
}

. shunit/shunit2
