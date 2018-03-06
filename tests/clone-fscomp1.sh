#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/clone-fscomp.sh

# common stubs
. common-stub.sh

_zfs_is_dataset()
{
	__monitor ZDSET "$@"
	if [ "$1" = "/fscomp/test-fscomp" ]; then
		return 0 # true
	fi
	if [ "$1" = "/fscomp/test-fscomp2" ]; then
		return 0 # true
	fi
	return 1 # false
}

# app specific stubs
clone-fscomp-help()
{
	__monitor HELP "$@"
}

_cf_zfs()
{
	__monitor CFZFS "$@"
	return 0 # true
}

test_pot_add_fscomp_001()
{
	pot-clone-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-clone-fscomp -vb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-clone-fscomp -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-clone-fscomp -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
}

test_pot_add_fscomp_002()
{
	pot-clone-fscomp -f new-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cf_zfs calls" "0" "$CFZFS_CALLS"

	setUp
	pot-clone-fscomp -F test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cf_zfs calls" "0" "$CFZFS_CALLS"
}

test_pot_add_fscomp_003()
{
	pot-clone-fscomp -f new-fscomp -F test-no-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "2" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cf_zfs calls" "0" "$CFZFS_CALLS"

	setUp
	pot-clone-fscomp -f test-fscomp2 -F test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cf_zfs calls" "0" "$CFZFS_CALLS"
}

test_pot_add_fscomp_020()
{
	pot-clone-fscomp -f new-fscomp -F test-fscomp
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_is_dataset calls" "2" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cf_zfs calls" "1" "$CFZFS_CALLS"
	assertEquals "_cf_zfs arg1" "new-fscomp" "$CFZFS_CALL1_ARG1"
	assertEquals "_cf_zfs arg2" "test-fscomp" "$CFZFS_CALL1_ARG2"
}

setUp()
{
	common_setUp
	ZDSET_CALLS=0
	HELP_CALLS=0
	CFZFS_CALLS=0
}

. shunit/shunit2
