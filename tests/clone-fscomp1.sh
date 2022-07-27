#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/clone-fscomp.sh

# common stubs
. common-stub.sh

_zfs_dataset_valid()
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
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS

	setUp
	pot-clone-fscomp -vb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS

	setUp
	pot-clone-fscomp -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS

	setUp
	pot-clone-fscomp -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_add_fscomp_002()
{
	pot-clone-fscomp -f new-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cf_zfs calls" "0" CFZFS_CALLS

	setUp
	pot-clone-fscomp -F test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cf_zfs calls" "0" CFZFS_CALLS
}

test_pot_add_fscomp_003()
{
	pot-clone-fscomp -f new-fscomp -F test-no-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "2" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cf_zfs calls" "0" CFZFS_CALLS

	setUp
	pot-clone-fscomp -f test-fscomp2 -F test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "1" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cf_zfs calls" "0" CFZFS_CALLS
}

test_pot_add_fscomp_020()
{
	pot-clone-fscomp -f new-fscomp -F test-fscomp
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "2" ZDSET_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cf_zfs calls" "1" CFZFS_CALLS
	assertEqualsMon "_cf_zfs arg1" "new-fscomp" CFZFS_CALL1_ARG1
	assertEqualsMon "_cf_zfs arg2" "test-fscomp" CFZFS_CALL1_ARG2
}

setUp()
{
	common_setUp
}

. shunit/shunit2
