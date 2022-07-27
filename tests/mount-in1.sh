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
. ../share/pot/mount-in.sh

# common stubs
. common-stub.sh

_zfs_dataset_valid()
{
	__monitor ZDVALID "$@"
	if [ "$1" = "zroot/test-dataset" ]; then
		return 0 # true
	fi
	return 1 # false
}

# app specific stubs
mount-in-help()
{
	__monitor HELP "$@"
	return 0 # true
}


_directory_validation()
{
	__monitor DIRVALID "$@"
}

_mountpoint_validation()
{
	__monitor MPVALID "$@"
	echo "$2"
}

_mount_dir()
{
	__monitor MOUNTDIR "$@"
}

_mount_dataset()
{
	__monitor MOUNTDSET "$@"
}

test_pot_mount_in_001()
{
	pot-mount-in
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -vb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -b bb
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_002()
{
	pot-mount-in -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -m /test-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -d /test-dir
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -z zroot/test-dataset
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_003()
{
	pot-mount-in -p test-pot -f test-fscomp
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -m /test-mnt -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -m /test-mnt -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_004()
{
	pot-mount-in -p test-pot -d /test-dir
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -m /test-mnt -d /test-dir
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -m /test-mnt -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_005()
{
	pot-mount-in -p test-pot -z zroot/test-dataset
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -m /test-mnt -z zroot/test-dataset
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -m /test-mnt -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_006()
{
	pot-mount-in -p test-pot -m /test-mnt -z zroot/test-dataset -d /test-dir
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-pot -m /test-mnt -z zroot/test-dataset -f test-fscomp
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-pot -m /test-mnt -f test-fscomp -d /test-dir
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_zfs_dataset_valid calls" "0" ZDVALID_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_007()
{
	pot-mount-in -p test-no-pot -m /test-no-mnt -f zroot/test-no-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-no-pot -m /test-no-mnt -z test-no-dataset
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-no-pot -m /test-no-mnt -d test-no-dir
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_008()
{
	pot-mount-in -p test-no-pot -m /test-no-mnt -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-no-pot -m /test-no-mnt -z zroot/test-dataset
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-no-pot -m /test-no-mnt -d test-dir
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_009()
{
	pot-mount-in -p test-pot -f test-fscomp -m test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-pot -d test-dir -m test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-pot -z zroot/test-dataset -m test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_010()
{
	pot-mount-in -p test-pot -f test-fscomp -m /
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-pot -d test-dir -m /
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-pot -z zroot/test-dataset -m /
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_011()
{
	pot-mount-in -p test-pot -f test-fscomp -m "/mnt/with space"
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-pot -d test-dir -m "/mnt/with space"
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	setUp
	pot-mount-in -p test-pot -z zroot/test-dataset -m "/mnt/with space"
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS

	pot-mount-in -p test-pot -f test-fscomp -m "/mnt/space  "
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
}

test_pot_mount_in_020()
{
	pot-mount-in -p test-pot -f test-fscomp -m /test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "1" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dataset arg" "zpot/fscomp/test-fscomp" MOUNTDSET_CALL1_ARG1
	assertEqualsMon "_mount_dataset arg" "test-pot" MOUNTDSET_CALL1_ARG2
	assertEqualsMon "_mount_dataset arg" "/test-mnt" MOUNTDSET_CALL1_ARG3
	assertEqualsMon "_mount_dataset arg" "" MOUNTDSET_CALL1_ARG4
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
}

test_pot_mount_in_021()
{
	pot-mount-in -p test-pot -f test-fscomp -m /test-mnt -r
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "1" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dataset arg" "zpot/fscomp/test-fscomp" MOUNTDSET_CALL1_ARG1
	assertEqualsMon "_mount_dataset arg" "test-pot" MOUNTDSET_CALL1_ARG2
	assertEqualsMon "_mount_dataset arg" "/test-mnt" MOUNTDSET_CALL1_ARG3
	assertEqualsMon "_mount_dataset arg" "ro" MOUNTDSET_CALL1_ARG4
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
}

test_pot_mount_in_022()
{
	pot-mount-in -p test-pot -f test-fscomp -m /test-mnt -w
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "1" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dataset arg" "zpot/fscomp/test-fscomp" MOUNTDSET_CALL1_ARG1
	assertEqualsMon "_mount_dataset arg" "test-pot" MOUNTDSET_CALL1_ARG2
	assertEqualsMon "_mount_dataset arg" "/test-mnt" MOUNTDSET_CALL1_ARG3
	assertEqualsMon "_mount_dataset arg" "zfs-remount" MOUNTDSET_CALL1_ARG4
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
}
test_pot_mount_in_040()
{
	pot-mount-in -p test-pot -z zroot/test-dataset -m /test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "1" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dataset arg" "zroot/test-dataset" MOUNTDSET_CALL1_ARG1
	assertEqualsMon "_mount_dataset arg" "test-pot" MOUNTDSET_CALL1_ARG2
	assertEqualsMon "_mount_dataset arg" "/test-mnt" MOUNTDSET_CALL1_ARG3
	assertEqualsMon "_mount_dataset arg" "" MOUNTDSET_CALL1_ARG4
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
}

test_pot_mount_in_041()
{
	pot-mount-in -p test-pot -z zroot/test-dataset -m /test-mnt -r
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "1" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dataset arg" "zroot/test-dataset" MOUNTDSET_CALL1_ARG1
	assertEqualsMon "_mount_dataset arg" "test-pot" MOUNTDSET_CALL1_ARG2
	assertEqualsMon "_mount_dataset arg" "/test-mnt" MOUNTDSET_CALL1_ARG3
	assertEqualsMon "_mount_dataset arg" "ro" MOUNTDSET_CALL1_ARG4
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
}

test_pot_mount_in_042()
{
	pot-mount-in -p test-pot -z zroot/test-dataset -m /test-mnt -w
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "1" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dataset arg" "zroot/test-dataset" MOUNTDSET_CALL1_ARG1
	assertEqualsMon "_mount_dataset arg" "test-pot" MOUNTDSET_CALL1_ARG2
	assertEqualsMon "_mount_dataset arg" "/test-mnt" MOUNTDSET_CALL1_ARG3
	assertEqualsMon "_mount_dataset arg" "zfs-remount" MOUNTDSET_CALL1_ARG4
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
}

test_pot_mount_in_060()
{
	pot-mount-in -p test-pot -d test-dir -m /test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dir calls" "1" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dir arg" "/home/test-dir" MOUNTDIR_CALL1_ARG1
	assertEqualsMon "_mount_dir arg" "test-pot" MOUNTDIR_CALL1_ARG2
	assertEqualsMon "_mount_dir arg" "/test-mnt" MOUNTDIR_CALL1_ARG3
	assertEqualsMon "_mount_dir arg" "" MOUNTDIR_CALL1_ARG4
}

test_pot_mount_in_061()
{
	pot-mount-in -p test-pot -d test-dir -m /test-mnt -r
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dir calls" "1" MOUNTDIR_CALLS
	assertEqualsMon "_mount_dir arg" "/home/test-dir" MOUNTDIR_CALL1_ARG1
	assertEqualsMon "_mount_dir arg" "test-pot" MOUNTDIR_CALL1_ARG2
	assertEqualsMon "_mount_dir arg" "/test-mnt" MOUNTDIR_CALL1_ARG3
	assertEqualsMon "_mount_dir arg" "ro" MOUNTDIR_CALL1_ARG4
}

test_pot_mount_in_062()
{
	pot-mount-in -p test-pot -d test-dir -m /test-mnt -w
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_mount_dataset calls" "0" MOUNTDSET_CALLS
	assertEqualsMon "_mount_dir calls" "0" MOUNTDIR_CALLS
}

setUp()
{
	common_setUp
	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
