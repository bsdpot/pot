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
. ../share/pot/set-hosts.sh

# common stubs
. common-stub.sh

# app specific stubs
set-hosts-help()
{
	__monitor HELP "$@"
}

rm()
{
	__monitor RM "$@"
}

mktemp()
{
	echo "/tmp/pot-set-hosts"
}

_set_hosts()
{
	__monitor SETHOSTS "$@"
}

test_pot_set_hosts_001()
{
	pot-set-hosts
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS

	setUp
	pot-set-hosts -bv
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS

	setUp
	pot-set-hosts -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS

	setUp
	pot-set-hosts -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_002()
{
	pot-set-hosts -H test-pot-2:10.1.2.3
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_003()
{
	pot-set-hosts -p test-pot -H
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_020()
{
	pot-set-hosts -p test-no-pot -H test-pot-2:10.1.2.3
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_021()
{
	pot-set-hosts -p test-pot -H test-pot-2
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "2" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_022()
{
	pot-set-hosts -p test-pot -H test-pot-2:
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_023()
{
	pot-set-hosts -p test-pot -H :10.1.2.3
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "0" SETHOSTS_CALLS
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_040()
{
	pot-set-hosts -p test-pot -H test-pot-2:10.1.2.3
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "1" SETHOSTS_CALLS
	assertEqualsMon "_set_hosts arg1" "test-pot" SETHOSTS_CALL1_ARG1
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" '10.1.2.3 test-pot-2' "$(sed '1!d' /tmp/pot-set-hosts)"
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_041()
{
	pot-set-hosts -p test-pot -H test-pot-2:10.1.2.3 -H test-pot-3:10.1.2.4
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "1" SETHOSTS_CALLS
	assertEquals "_tmpfile length" "2" "$( awk 'END {print NR}' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" '10.1.2.3 test-pot-2' "$(sed '1!d' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" '10.1.2.4 test-pot-3' "$(sed '2!d' /tmp/pot-set-hosts)"
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_042()
{
	pot-set-hosts -p test-pot -H test-pot-2:fe00::2
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "1" SETHOSTS_CALLS
	assertEqualsMon "_set_hosts arg1" "test-pot" SETHOSTS_CALL1_ARG1
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" 'fe00::2 test-pot-2' "$(sed '1!d' /tmp/pot-set-hosts)"
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_043()
{
	pot-set-hosts -p test-pot -H test-pot-2:::1
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "1" SETHOSTS_CALLS
	assertEqualsMon "_set_hosts arg1" "test-pot" SETHOSTS_CALL1_ARG1
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" '::1 test-pot-2' "$(sed '1!d' /tmp/pot-set-hosts)"
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

test_pot_set_hosts_044()
{
	pot-set-hosts -p test-pot -H test-pot-2:10.1.2.3 -H test-pot-3:10.1.2.4 -H test-pot-4:::1 -H test-pot-5:fe00::2
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_set_hosts calls" "1" SETHOSTS_CALLS
	assertEqualsMon "_set_hosts arg1" "test-pot" SETHOSTS_CALL1_ARG1
	assertEquals "_tmpfile length" "4" "$( awk 'END {print NR}' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" '10.1.2.3 test-pot-2' "$(sed '1!d' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" '10.1.2.4 test-pot-3' "$(sed '2!d' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" '::1 test-pot-4' "$(sed '3!d' /tmp/pot-set-hosts)"
	assertEquals "_tmpfile" 'fe00::2 test-pot-5' "$(sed '4!d' /tmp/pot-set-hosts)"
	assertEqualsMon "_rm calls" "1" RM_CALLS
}

setUp()
{
	common_setUp
	/bin/rm -f /tmp/pot-set-hosts
}

tearDown()
{
	common_tearDown
	/bin/rm -f /tmp/pot-set-hosts
}


. shunit/shunit2
