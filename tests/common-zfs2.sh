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
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs args" "/zroot/fscomp/fscomp_name@123454321" "$ZFS_CALL1_ARG2"
}

test_fscomp_zfs_snap_002()
{
	_fscomp_zfs_snap fscomp_name new_snap
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs args" "/zroot/fscomp/fscomp_name@new_snap" "$ZFS_CALL1_ARG2"
}

setUp()
{
	ZFS_CALLS=0
	POT_ZFS_ROOT=/zroot
}
. shunit/shunit2
