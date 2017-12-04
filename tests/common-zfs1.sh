#!/bin/sh

# system utilities stubs

zfs()
{
	if [ "$2" = "zfs-dataset" ]; then
		return 0 # true
	fi
	if [ "$2" = "-H" ]; then
		if [ "$5" = "zfs-dataset" ]; then
			echo "/path/to/mnt"
		fi
	fi
	return 1 # false
}

# UUT
. ../share/pot/common.sh

# app specific stubs

test_zfs_is_dataset_001()
{
	_zfs_is_dataset
	assertNotEquals "0" "$?"

	_zfs_is_dataset zfs-nodataset
	assertNotEquals "0" "$?"
}

test_zfs_is_dataset_002()
{
	_zfs_is_dataset zfs-dataset
	assertEquals "0" "$?"
}

test_ufs_exist_001()
{
	_zfs_exist
	assertNotEquals "0" "$?"

	_zfs_exist zfs-nodataset
	assertNotEquals "0" "$?"

	_zfs_exist zfs-dataset
	assertNotEquals "0" "$?"

	_zfs_exist zfs-nodataset /path/to/mnt
	assertNotEquals "0" "$?"

	_zfs_exist zfs-dataset /path/to/chaos
	assertNotEquals "0" "$?"

	_zfs_exist zfs-dataset /path/to/mnt
	assertEquals "0" "$?"
}

. shunit/shunit2
