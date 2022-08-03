#!/bin/sh

# system utilities stubs
zfs()
{
	__monitor ZFS "$@"
}

mkdir()
{
	__monitor MKDIR "$@"
}

stat()
{
	__monitor STAT "$@"
	echo 700
}

# UUT
. ../share/pot/rename.sh

# common stubs
. common-stub.sh

_zfs_dataset_valid()
{
	__monitor ZDVALID "$@"
	case "$1" in
		${POT_ZFS_ROOT}/jails/test-pot|\
		${POT_ZFS_ROOT}/jails/test-pot/usr.local|\
		${POT_ZFS_ROOT}/jails/test-pot/custom|\
		${POT_ZFS_ROOT}/jails/test-pot-2|\
		${POT_ZFS_ROOT}/jails/test-pot-2/custom|\
		${POT_ZFS_ROOT}/jails/new-pot/usr.local|\
		${POT_ZFS_ROOT}/jails/test-pot-single|\
		${POT_ZFS_ROOT}/jails/test-pot-single/m|\
		${POT_ZFS_ROOT}/jails/new-pot-single/m)
			return 0 # true
			;;
	esac
	return 1 # false
}

# app specific stubs

test_rn_zfs_001()
{
	_rn_zfs test-pot new-pot
	assertEqualsMon "_zfs_dataset_valid calls" "4" ZDVALID_CALLS
	assertEqualsMon "zfs calls" "9" ZFS_CALLS
	assertEqualsMon "zfs c1 arg1" "umount" ZFS_CALL1_ARG1
	assertEqualsMon "zfs c1 arg2" "-f" ZFS_CALL1_ARG2
	assertEqualsMon "zfs c1 arg3" "${POT_ZFS_ROOT}/jails/test-pot/usr.local" ZFS_CALL1_ARG3
	assertEqualsMon "zfs c2 arg1" "set" ZFS_CALL2_ARG1
	assertEqualsMon "zfs c2 arg2" "mountpoint=/jails/new-pot/usr.local" ZFS_CALL2_ARG2
	assertEqualsMon "zfs c2 arg3" "${POT_ZFS_ROOT}/jails/test-pot/usr.local" ZFS_CALL2_ARG3
	assertEqualsMon "zfs c3 arg1" "umount" ZFS_CALL3_ARG1
	assertEqualsMon "zfs c3 arg2" "-f" ZFS_CALL3_ARG2
	assertEqualsMon "zfs c3 arg3" "${POT_ZFS_ROOT}/jails/test-pot/custom" ZFS_CALL3_ARG3
	assertEqualsMon "zfs c4 arg1" "set" ZFS_CALL4_ARG1
	assertEqualsMon "zfs c4 arg2" "mountpoint=/jails/new-pot/custom" ZFS_CALL4_ARG2
	assertEqualsMon "zfs c4 arg3" "${POT_ZFS_ROOT}/jails/test-pot/custom" ZFS_CALL4_ARG3
	assertEqualsMon "zfs c5 arg1" "umount" ZFS_CALL5_ARG1
	assertEqualsMon "zfs c5 arg2" "-f" ZFS_CALL5_ARG2
	assertEqualsMon "zfs c5 arg3" "${POT_ZFS_ROOT}/jails/test-pot" ZFS_CALL5_ARG3
	assertEqualsMon "zfs c6 arg1" "rename" ZFS_CALL6_ARG1
	assertEqualsMon "zfs c6 arg2" "${POT_ZFS_ROOT}/jails/test-pot" ZFS_CALL6_ARG2
	assertEqualsMon "zfs c6 arg3" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL6_ARG3
	assertEqualsMon "zfs c7 arg1" "mount" ZFS_CALL7_ARG1
	assertEqualsMon "zfs c7 arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL7_ARG2
	assertEqualsMon "zfs c8 arg1" "mount" ZFS_CALL8_ARG1
	assertEqualsMon "zfs c8 arg2" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL8_ARG2
	assertEqualsMon "zfs c9 arg1" "mount" ZFS_CALL9_ARG1
	assertEqualsMon "zfs c9 arg2" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" ZFS_CALL9_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "stat calls" "1" STAT_CALLS
	assertEqualsMon "stat arg1" "-f" STAT_CALL1_ARG1
	assertEqualsMon "stat arg2" "%Lp" STAT_CALL1_ARG2
	assertEqualsMon "stat arg3" "${POT_FS_ROOT}/jails/new-pot/m" STAT_CALL1_ARG3
}

test_rn_zfs_002()
{
	_rn_zfs test-pot-2 new-pot-2
	assertEqualsMon "_zfs_dataset_valid calls" "4" ZDVALID_CALLS
	assertEqualsMon "zfs calls" "6" ZFS_CALLS
	assertEqualsMon "zfs c1 arg1" "umount" ZFS_CALL1_ARG1
	assertEqualsMon "zfs c1 arg2" "-f" ZFS_CALL1_ARG2
	assertEqualsMon "zfs c1 arg3" "${POT_ZFS_ROOT}/jails/test-pot-2/custom" ZFS_CALL1_ARG3
	assertEqualsMon "zfs c2 arg1" "set" ZFS_CALL2_ARG1
	assertEqualsMon "zfs c2 arg2" "mountpoint=/jails/new-pot-2/custom" ZFS_CALL2_ARG2
	assertEqualsMon "zfs c2 arg3" "${POT_ZFS_ROOT}/jails/test-pot-2/custom" ZFS_CALL2_ARG3
	assertEqualsMon "zfs c3 arg1" "umount" ZFS_CALL3_ARG1
	assertEqualsMon "zfs c3 arg2" "-f" ZFS_CALL3_ARG2
	assertEqualsMon "zfs c3 arg3" "${POT_ZFS_ROOT}/jails/test-pot-2" ZFS_CALL3_ARG3
	assertEqualsMon "zfs c4 arg1" "rename" ZFS_CALL4_ARG1
	assertEqualsMon "zfs c4 arg2" "${POT_ZFS_ROOT}/jails/test-pot-2" ZFS_CALL4_ARG2
	assertEqualsMon "zfs c4 arg3" "${POT_ZFS_ROOT}/jails/new-pot-2" ZFS_CALL4_ARG3
	assertEqualsMon "zfs c5 arg1" "mount" ZFS_CALL5_ARG1
	assertEqualsMon "zfs c5 arg2" "${POT_ZFS_ROOT}/jails/new-pot-2" ZFS_CALL5_ARG2
	assertEqualsMon "zfs c6 arg1" "mount" ZFS_CALL6_ARG1
	assertEqualsMon "zfs c6 arg2" "${POT_ZFS_ROOT}/jails/new-pot-2/custom" ZFS_CALL6_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "stat calls" "1" STAT_CALLS
	assertEqualsMon "stat arg1" "-f" STAT_CALL1_ARG1
	assertEqualsMon "stat arg2" "%Lp" STAT_CALL1_ARG2
	assertEqualsMon "stat arg3" "${POT_FS_ROOT}/jails/new-pot-2/m" STAT_CALL1_ARG3
}

test_rn_zfs_003()
{
	_rn_zfs test-pot-single new-pot-single
	assertEqualsMon "_zfs_dataset_valid calls" "3" ZDVALID_CALLS
	assertEqualsMon "zfs calls" "6" ZFS_CALLS
	assertEqualsMon "zfs c1 arg1" "umount" ZFS_CALL1_ARG1
	assertEqualsMon "zfs c1 arg2" "-f" ZFS_CALL1_ARG2
	assertEqualsMon "zfs c1 arg3" "${POT_ZFS_ROOT}/jails/test-pot-single/m" ZFS_CALL1_ARG3
	assertEqualsMon "zfs c2 arg1" "set" ZFS_CALL2_ARG1
	assertEqualsMon "zfs c2 arg2" "mountpoint=/jails/new-pot-single/m" ZFS_CALL2_ARG2
	assertEqualsMon "zfs c2 arg3" "${POT_ZFS_ROOT}/jails/test-pot-single/m" ZFS_CALL2_ARG3
	assertEqualsMon "zfs c3 arg1" "umount" ZFS_CALL3_ARG1
	assertEqualsMon "zfs c3 arg2" "-f" ZFS_CALL3_ARG2
	assertEqualsMon "zfs c3 arg3" "${POT_ZFS_ROOT}/jails/test-pot-single" ZFS_CALL3_ARG3
	assertEqualsMon "zfs c4 arg1" "rename" ZFS_CALL4_ARG1
	assertEqualsMon "zfs c4 arg2" "${POT_ZFS_ROOT}/jails/test-pot-single" ZFS_CALL4_ARG2
	assertEqualsMon "zfs c4 arg3" "${POT_ZFS_ROOT}/jails/new-pot-single" ZFS_CALL4_ARG3
	assertEqualsMon "zfs c5 arg1" "mount" ZFS_CALL5_ARG1
	assertEqualsMon "zfs c5 arg2" "${POT_ZFS_ROOT}/jails/new-pot-single" ZFS_CALL5_ARG2
	assertEqualsMon "zfs c6 arg1" "mount" ZFS_CALL6_ARG1
	assertEqualsMon "zfs c6 arg2" "${POT_ZFS_ROOT}/jails/new-pot-single/m" ZFS_CALL6_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir 1 arg2" "${POT_FS_ROOT}/jails/new-pot-single/m" MKDIR_CALL1_ARG2
	assertEqualsMon "stat calls" "1" STAT_CALLS
	assertEqualsMon "stat arg1" "-f" STAT_CALL1_ARG1
	assertEqualsMon "stat arg2" "%Lp" STAT_CALL1_ARG2
	assertEqualsMon "stat arg3" "${POT_FS_ROOT}/jails/new-pot-single/m" STAT_CALL1_ARG3
}

setUp()
{
	common_setUp
	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
