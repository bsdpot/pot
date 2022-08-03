#!/bin/sh

# system utilities stubs

if [ "$(uname)" = "Linux" ]; then
	TEST=/usr/bin/[
else
	TEST=/bin/[
fi

[()
{
	if ${TEST} "$1" = "!" ]; then
		if ${TEST} "$2" = "-d" ]; then
			if ${TEST} "$3" = "test-dir" ]; then
				return 1 # false
			fi
		fi
	fi
	${TEST} "$@"
	return $?
}

realpath()
{
	__monitor REALPATH "$@"
	if [ "$2" = "test-dir" ]; then
		echo "/home/test-dir"
		return 0 # true
	fi
	return 1 # false
}

logger()
{
	:
}

# UUT
. ../share/pot/mount-out.sh

# common stubs
. common-stub.sh

# app specific stubs
mount-out-help()
{
	__monitor HELP "$@"
	return 0 # true
}

_mountpoint_validation()
{
	__monitor MPVALID "$@"
	echo "$2"
}

_umount_mnt_p()
{
	__monitor UMNT_P "$@"
}

test_pot_mount_in_001()
{
	pot-mount-out
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_umount_mnt_p calls" "0" UMNT_P_CALLS

	setUp
	pot-mount-out -vb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_umount_mnt_p calls" "0" UMNT_P_CALLS

	setUp
	pot-mount-out -b bb
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_umount_mnt_p calls" "0" UMNT_P_CALLS

	setUp
	pot-mount-out -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_umount_mnt_p calls" "0" UMNT_P_CALLS
}

test_pot_mount_in_002()
{
	pot-mount-out -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_umount_mnt_p calls" "0" UMNT_P_CALLS

	setUp
	pot-mount-out -m /test-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_umount_mnt_p calls" "0" UMNT_P_CALLS
}

test_pot_mount_in_020()
{
	pot-mount-out -p test-pot -m /test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_umount_mnt_p calls" "1" UMNT_P_CALLS
	assertEqualsMon "_umount_mnt_p arg" "test-pot" UMNT_P_CALL1_ARG1
	assertEqualsMon "_umount_mnt_p arg" "/test-mnt" UMNT_P_CALL1_ARG2
}

setUp()
{
	common_setUp
	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
