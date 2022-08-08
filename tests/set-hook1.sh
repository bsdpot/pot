#!/bin/sh

# system utilities stubs
potnet()
{
	case "$4" in
		"10.1.2.3"|"10.1.2.4"|\
		"fe00::2"|"::1")
		return 0 # true
	esac
}

# UUT
. ../share/pot/set-hook.sh

# common stubs
. common-stub.sh

# app specific stubs
set-hook-help()
{
	__monitor HELP "$@"
}

_set_hook()
{
	__monitor SETHOOK "$@"
}

_is_valid_hook()
{
	__monitor VALIDHOOK "$@"
	if [ "$1" != "valid_script" ]; then
		return 1 # false
	fi
	return 0 # true
}

test_pot_set_hook_001()
{
	pot-set-hook
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS

	setUp
	pot-set-hook -bv
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS

	setUp
	pot-set-hook -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS

	setUp
	pot-set-hook -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS
}

test_pot_set_hook_002()
{
	pot-set-hook -s valid_script
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS
}

test_pot_set_hook_003()
{
	pot-set-hook -p test-pot -s
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS
}

test_pot_set_hook_020()
{
	pot-set-hook -p test-no-pot -s valid_script
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS
}

test_pot_set_hook_021()
{
	pot-set-hook -p test-pot -s not_valid_script
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS
}

test_pot_set_hook_022()
{
	pot-set-hook -p test-pot -S not_valid_script
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS
}

test_pot_set_hook_023()
{
	pot-set-hook -p test-pot -t not_valid_script
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS
}

test_pot_set_hook_024()
{
	pot-set-hook -p test-pot -T not_valid_script
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_set_hook calls" "0" SETHOOK_CALLS
}

test_pot_set_hook_040()
{
	pot-set-hook -p test-pot -s valid_script
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "1" SETHOOK_CALLS
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL1_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL1_ARG2
	assertEqualsMon "_set_hook arg3" "prestart" SETHOOK_CALL1_ARG3
}

test_pot_set_hook_041()
{
	pot-set-hook -p test-pot -s valid_script -S valid_script
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "2" SETHOOK_CALLS
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL1_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL1_ARG2
	assertEqualsMon "_set_hook arg3" "prestart" SETHOOK_CALL1_ARG3
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL2_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL2_ARG2
	assertEqualsMon "_set_hook arg3" "poststart" SETHOOK_CALL2_ARG3
}

test_pot_set_hook_042()
{
	pot-set-hook -p test-pot -t valid_script -T valid_script
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "2" SETHOOK_CALLS
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL1_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL1_ARG2
	assertEqualsMon "_set_hook arg3" "prestop" SETHOOK_CALL1_ARG3
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL2_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL2_ARG2
	assertEqualsMon "_set_hook arg3" "poststop" SETHOOK_CALL2_ARG3
}

test_pot_set_hook_043()
{
	pot-set-hook -p test-pot -t valid_script -T valid_script -s valid_script -S valid_script
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hook calls" "4" SETHOOK_CALLS
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL1_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL1_ARG2
	assertEqualsMon "_set_hook arg3" "prestart" SETHOOK_CALL1_ARG3
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL2_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL2_ARG2
	assertEqualsMon "_set_hook arg3" "poststart" SETHOOK_CALL2_ARG3
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL3_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL3_ARG2
	assertEqualsMon "_set_hook arg3" "prestop" SETHOOK_CALL3_ARG3
	assertEqualsMon "_set_hook arg1" "test-pot" SETHOOK_CALL4_ARG1
	assertEqualsMon "_set_hook arg2" "valid_script" SETHOOK_CALL4_ARG2
	assertEqualsMon "_set_hook arg3" "poststop" SETHOOK_CALL4_ARG3
}

setUp()
{
	common_setUp
}

. shunit/shunit2
