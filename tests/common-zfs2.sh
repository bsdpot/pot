#!/bin/sh

. monitor.sh
# system utilities stubs

zfs()
{
	__monitor ZFS "$@"
}

date()
{
	echo "123454321"
}

# UUT
. ../share/pot/common.sh

# app specific stubs

test_fscomp_zfs_snap_001()
{
	_fscomp_zfs_snap fscomp_name
	assertEqualsMon "zfs calls" "1" ZFS_CALLS
	assertEqualsMon "zfs args" "/zroot/fscomp/fscomp_name@123454321" ZFS_CALL1_ARG2
}

test_fscomp_zfs_snap_002()
{
	# the argument "new_snap" is ignored
	_fscomp_zfs_snap fscomp_name new_snap
	assertEqualsMon "zfs calls" "1" ZFS_CALLS
	assertEqualsMon "zfs arg1" "snapshot" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "/zroot/fscomp/fscomp_name@123454321" ZFS_CALL1_ARG2
}

setUp()
{
	__mon_init
	POT_ZFS_ROOT=/zroot
}

tearDown()
{
	__mon_tearDown
}

. shunit/shunit2
