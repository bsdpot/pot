#!/bin/sh

# system utilities stubs
mkdir()
{
	__monitor MKDIR "$@"
}

# UUT
. ../share/pot/create-private-bridge.sh

# common stubs
. common-stub.sh

_is_potnet_available()
{
	return 0 # true
}

_is_bridge()
{
	if [ "$1" = "test-bridge" ]; then
		return 0 # true
	fi
	return 1
}

# app specific stubs

create-private-bridge-help()
{
	__monitor HELP "$@"
}

create-bridge()
{
	__monitor CB "$@"
}

test_create_private_bridge_001()
{
	pot-create-private-bridge
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-create-private-bridge -vL
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-create-private-bridge -L bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-create-private-bridge -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
}

test_create_private_bridge_002()
{
	pot-create-private-bridge -B test-bridge
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_create_bridge calls" "0" "$CB_CALLS"
}

test_create_private_bridge_003()
{
	pot-create-private-bridge -S 5
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_create_bridge calls" "0" "$CB_CALLS"
}

test_create_private_bridge_010()
{
	# bridge already exists
	pot-create-private-bridge -B test-bridge -S 5
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_create_bridge calls" "0" "$CB_CALLS"
}

test_create_private_bridge_020()
{
	pot-create-private-bridge -B new-test-bridge -S 5
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_create_bridge calls" "1" "$CB_CALLS"
	assertEquals "_create_bridge arg1" "new-test-bridge" "$CB_CALL1_ARG1"
	assertEquals "_create_bridge arg2" "5" "$CB_CALL1_ARG2"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	FETCHBSD_CALLS=0
	CB_CALLS=0
}

. shunit/shunit2
