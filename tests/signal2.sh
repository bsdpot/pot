#!/bin/sh

# system utilities stubs
pkill()
{
	__monitor PKILL "$@"
}

pgrep()
{
	__monitor PGREP "$@"
}

mktemp()
{
	__monitor MKTEMP "$@"
	echo /dev/null
}

rm()
{
	__monitor RM "$@"
}

# UUT
. ../share/pot/signal.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

_get_conf_var()
{
	__monitor GETCONFVAR "$@"
	if [ "$1" = "test-pot-presist" ]; then
		echo "YES"
		return
	fi
	echo "NO"
}

# app specific stubs

test_send_signal_001()
{
	_send_signal test-pot SIGINFO "" "" "NO" "NO"
	assertEqualsMon "pgrep calls" "0" PGREP_CALLS
	assertEqualsMon "pkill calls" "1" PKILL_CALLS
	assertEqualsMon "pkill arg1" "-SIGINFO" PKILL_CALL1_ARG1
	assertEqualsMon "pkill arg2" "-j" PKILL_CALL1_ARG2
	assertEqualsMon "pkill arg3" "test-pot" PKILL_CALL1_ARG3
	assertEqualsMon "pkill arg4" "-F" PKILL_CALL1_ARG4
	assertEqualsMon "pkill arg5" "/tmp/pot_main_pid_test-pot" PKILL_CALL1_ARG5
	assertEqualsMon "rm calls" "0" RM_CALLS
}

test_send_signal_002()
{
	_send_signal test-pot-presist SIGINFO "" "" "NO" "NO"
	rc=$?
	assertEquals "return code" "1" "$rc"
	assertEqualsMon "pgrep calls" "0" PGREP_CALLS
	assertEqualsMon "pkill calls" "0" PKILL_CALLS
}

test_send_signal_003()
{
	_send_signal test-pot-presist SIGINFO "" "" "YES" "NO"
	rc=$?
	assertEquals "return code" "0" "$rc"
	assertEqualsMon "pgrep calls" "0" PGREP_CALLS
	assertEqualsMon "pkill calls" "0" PKILL_CALLS
}

test_send_signal_010()
{
	_send_signal test-pot SIGINFO "" "command" "NO" "NO"
	assertEqualsMon "pgrep calls" "0" PGREP_CALLS
	assertEqualsMon "pkill calls" "1" PKILL_CALLS
	assertEqualsMon "pkill arg1" "-SIGINFO" PKILL_CALL1_ARG1
	assertEqualsMon "pkill arg2" "-j" PKILL_CALL1_ARG2
	assertEqualsMon "pkill arg3" "test-pot" PKILL_CALL1_ARG3
	assertEqualsMon "pkill arg4" "command" PKILL_CALL1_ARG4
	assertEqualsMon "rm calls" "0" RM_CALLS
}

test_send_signal_011()
{
	_send_signal test-pot SIGINFO "1234" "" "NO" "NO"
	assertEqualsMon "pgrep calls" "0" PGREP_CALLS
	assertEqualsMon "pkill calls" "1" PKILL_CALLS
	assertEqualsMon "pkill arg1" "-SIGINFO" PKILL_CALL1_ARG1
	assertEqualsMon "pkill arg2" "-j" PKILL_CALL1_ARG2
	assertEqualsMon "pkill arg3" "test-pot" PKILL_CALL1_ARG3
	assertEqualsMon "pkill arg4" "-F" PKILL_CALL1_ARG4
	assertEqualsMon "pkill arg5" "/dev/null" PKILL_CALL1_ARG5
	assertEqualsMon "rm calls" "1" RM_CALLS
}

test_send_signal_020()
{
	_send_signal test-pot SIGINFO "" "" "NO" "YES"
	assertEqualsMon "pgrep calls" "1" PGREP_CALLS
	assertEqualsMon "pkill arg1" "-j" PGREP_CALL1_ARG1
	assertEqualsMon "pkill arg2" "test-pot" PGREP_CALL1_ARG2
	assertEqualsMon "pkill arg4" "/tmp/pot_main_pid_test-pot" PGREP_CALL1_ARG4
	assertEqualsMon "pkill calls" "0" PKILL_CALLS
}

setUp()
{
	common_setUp
	PKILL_CALLS=0
	PKILL_CALL1_ARG4=
	PKILL_CALL1_ARG5=
	PGREP_CALLS=0
	MKTEMP_CALLS=0
	RM_CALLS=0
	GETCONFVAR_CALLS=0
}

. shunit/shunit2
