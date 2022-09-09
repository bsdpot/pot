#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/signal.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
signal-help()
{
	__monitor HELP "$@"
}

_get_signal_names()
{
	__monitor GETSIGNALNAMES "$@"
}

_validate_signal_name()
{
	__monitor VALIDATESIGNALNAME "$@"
	if [ "$1" = "SIGINFO" ] || [ "$1" = "SIGHUP" ]; then
		return 0 # true
	fi
	return 1 # false
}

_validate_pid()
{
	__monitor VALIDATEPID "$@"
	if [ "$1" = "1234" ]; then
		return 0 # true
	fi
	return 1 # false
}

_send_signal()
{
	__monitor SENDSIGNAL "$@"
}

test_pot_signal_001()
{
	pot-signal
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "Send signal calls" "0" SENDSIGNAL_CALLS

	setUp
	pot-signal -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Send signal calls" "0" SENDSIGNAL_CALLS

	setUp
	pot-signal -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Send signal calls" "0" SENDSIGNAL_CALLS

	setUp
	pot-signal -v
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "Send signal calls" "0" SENDSIGNAL_CALLS
}

test_pot_signal_002()
{
	pot-signal -p test-pot -s SIGBAD
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "Validate signal calls" "1" VALIDATESIGNALNAME_CALLS
	assertEqualsMon "Validate signal arg" "SIGBAD" VALIDATESIGNALNAME_CALL1_ARG1
	assertEqualsMon "Send signal calls" "0" SENDSIGNAL_CALLS

	setUp
	pot-signal -p test-pot -P 1234 -m cmd
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "Validate pid calls" "0" VALIDATEPID_CALLS
	assertEqualsMon "Send signal calls" "0" SENDSIGNAL_CALLS

	setUp
	pot-signal -p test-pot -P cmd
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "Validate pid calls" "1" VALIDATEPID_CALLS
	assertEqualsMon "Validate pid calls" "cmd" VALIDATEPID_CALL1_ARG1
	assertEqualsMon "Send signal calls" "0" SENDSIGNAL_CALLS
}

test_pot_signal_003()
{
	pot-signal -p test-pot -P 1234
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "Validate pid calls" "1" VALIDATEPID_CALLS
	assertEqualsMon "Validate pid calls" "1234" VALIDATEPID_CALL1_ARG1
	assertEqualsMon "Validate signal calls" "1" VALIDATESIGNALNAME_CALLS
	assertEqualsMon "Validate signal arg" "SIGINFO" VALIDATESIGNALNAME_CALL1_ARG1
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "Send signal calls" "0" SENDSIGNAL_CALLS
}

test_pot_signal_020()
{
	pot-signal -p test-pot-run
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Send signal calls" "1" SENDSIGNAL_CALLS
	assertEqualsMon "Send signal arg1" "test-pot-run" SENDSIGNAL_CALL1_ARG1
	assertEqualsMon "Send signal arg2" "SIGINFO" SENDSIGNAL_CALL1_ARG2
	assertEqualsMon "Send signal arg3" "" SENDSIGNAL_CALL1_ARG3
	assertEqualsMon "Send signal arg4" "" SENDSIGNAL_CALL1_ARG4
	assertEqualsMon "Send signal arg5" "NO" SENDSIGNAL_CALL1_ARG5
	assertEqualsMon "Send signal arg6" "NO" SENDSIGNAL_CALL1_ARG6

	setUp
	pot-signal -p test-pot-run -s SIGHUP
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Send signal calls" "1" SENDSIGNAL_CALLS
	assertEqualsMon "Send signal arg1" "test-pot-run" SENDSIGNAL_CALL1_ARG1
	assertEqualsMon "Send signal arg2" "SIGHUP" SENDSIGNAL_CALL1_ARG2
	assertEqualsMon "Send signal arg3" "" SENDSIGNAL_CALL1_ARG3
	assertEqualsMon "Send signal arg4" "" SENDSIGNAL_CALL1_ARG4
	assertEqualsMon "Send signal arg5" "NO" SENDSIGNAL_CALL1_ARG5
	assertEqualsMon "Send signal arg6" "NO" SENDSIGNAL_CALL1_ARG6
}

test_pot_signal_021()
{
	pot-signal -p test-pot-run -s SIGHUP -P 1234 -f -C
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Send signal calls" "1" SENDSIGNAL_CALLS
	assertEqualsMon "Send signal arg1" "test-pot-run" SENDSIGNAL_CALL1_ARG1
	assertEqualsMon "Send signal arg2" "SIGHUP" SENDSIGNAL_CALL1_ARG2
	assertEqualsMon "Send signal arg3" "1234" SENDSIGNAL_CALL1_ARG3
	assertEqualsMon "Send signal arg4" "" SENDSIGNAL_CALL1_ARG4
	assertEqualsMon "Send signal arg5" "YES" SENDSIGNAL_CALL1_ARG5
	assertEqualsMon "Send signal arg6" "YES" SENDSIGNAL_CALL1_ARG6
}

test_pot_signal_022()
{
	pot-signal -p test-pot-run -s SIGINFO -m grep -f -C
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "Send signal calls" "1" SENDSIGNAL_CALLS
	assertEqualsMon "Send signal arg1" "test-pot-run" SENDSIGNAL_CALL1_ARG1
	assertEqualsMon "Send signal arg2" "SIGINFO" SENDSIGNAL_CALL1_ARG2
	assertEqualsMon "Send signal arg3" "" SENDSIGNAL_CALL1_ARG3
	assertEqualsMon "Send signal arg4" "grep" SENDSIGNAL_CALL1_ARG4
	assertEqualsMon "Send signal arg5" "YES" SENDSIGNAL_CALL1_ARG5
	assertEqualsMon "Send signal arg6" "YES" SENDSIGNAL_CALL1_ARG6
}

setUp()
{
	common_setUp
}

. shunit/shunit2
