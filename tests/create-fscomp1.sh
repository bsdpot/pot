#!/bin/sh

# system utilities stubs
zfs()
{
	__monitor ZFS "$@"
	return 0 # true
}

# UUT
. ../share/pot/create-fscomp.sh

# common stubs
. common-stub.sh

_zfs_dataset_valid()
{
	__monitor ZDSET "$@"
	if [ "$1" = "/fscomp/test-fscomp" ]; then
		return 0 # true
	fi
	return 1 # false
}

_is_init()
{
	return 0 # true
}

# app specific stubs
create-fscomp-help()
{
	__monitor HELP "$@"
}

test_pot_create_fscomp_001()
{
	pot-create-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_zfs_dataset_valid calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-create-fscomp -vb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_dataset_valid calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-create-fscomp -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_dataset_valid calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-create-fscomp -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_dataset_valid calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
}

test_pot_create_fscomp_002()
{
	pot-create-fscomp -f test-fscomp
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_dataset_valid calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
}

test_pot_create_fscomp_020()
{
	pot-create-fscomp -f new-fscomp
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_zfs_dataset_valid calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "/fscomp/new-fscomp" "$ZFS_CALL1_ARG2"
}

setUp()
{
	common_setUp
	ZDSET_CALLS=0
	HELP_CALLS=0
	ZFS_CALLS=0
	ZFS_CALL1_ARG1=
	ZFS_CALL1_ARG2=
}

. shunit/shunit2
