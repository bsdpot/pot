#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/add-rss.sh

# common stubs
. common-stub.sh

# app specific stubs
add-rss-help()
{
	__monitor HELP "$@"
}

_cpuset_validation()
{
	__monitor CPUSETVAL "$@"
	case $1 in
	0)
		return 0 # true
	esac
	return 1 # false
}

_add_rss()
{
	__monitor ADDRSS "$@"
}

test_pot_add_rss_001()
{
	pot-add-rss
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"

	setUp
	pot-add-rss -bv
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"

	setUp
	pot-add-rss -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"

	setUp
	pot-add-rss -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"
}

test_pot_add_rss_002()
{
	pot-add-rss -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"

	setUp
	pot-add-rss -C 0
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"

	setUp
	pot-add-rss -M 200M
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"

	setUp
	pot-add-rss -M 200M -C 0
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"
}

test_pot_add_rss_020()
{
	pot-add-rss -p test-no-pot -C 0
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"

	setUp
	pot-add-rss -p test-no-pot -M 200M
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"

	setUp
	pot-add-rss -p test-pot -M 200M -C 44
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "0" "$ADDRSS_CALLS"
	assertEquals "_cpuset_validation calls" "1" "$CPUSETVAL_CALLS"
}

test_pot_add_rss_021()
{
	pot-add-rss -p test-pot -M 200M
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "1" "$ADDRSS_CALLS"
	assertEquals "_cpuset_validation calls" "0" "$CPUSETVAL_CALLS"

	setUp
	pot-add-rss -p test-pot -C 0
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "1" "$ADDRSS_CALLS"
	assertEquals "_cpuset_validation calls" "1" "$CPUSETVAL_CALLS"

	setUp
	pot-add-rss -p test-pot -C 0 -M 200M
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_add_rss calls" "2" "$ADDRSS_CALLS"
	assertEquals "_cpuset_validation calls" "1" "$CPUSETVAL_CALLS"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	CPUSETVAL_CALLS=0
	ADDRSS_CALLS=0
}

. shunit/shunit2
