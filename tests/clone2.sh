#!/bin/sh

# system utilities stubs
zfs()
{
	__monitor ZFS "$@"
}

ECHO=echo_stub
echo_stub()
{
	__monitor ECHO "$@"
}

mkdir()
{
	__monitor MKDIR "$@"
	/bin/mkdir $@
}

date()
{
	__monitor DATE "$@"
	if [ "$1" = '+%s' ]; then
		echo "55555"
	fi
}

. pipefail-stub.sh

# UUT
. ../share/pot/clone.sh

# common stubs
. common-stub.sh
. conf-stub.sh

_zfs_dataset_valid()
{
	__monitor ZFSDATASETVALID "$@"
	case "$1" in
	${POT_ZFS_ROOT}/jails/test-pot|\
	${POT_ZFS_ROOT}/jails/test-pot/usr.local|\
	${POT_ZFS_ROOT}/jails/test-pot/custom|\
	${POT_ZFS_ROOT}/jails/test-pot-single)
		return 0 # true
		;;
	esac
	return 1 # false
}

_zfs_last_snap()
{
	__monitor ZFSLASTSNAP "$@"
	case $1 in
	${POT_ZFS_ROOT}/bases/11.1/usr.local|\
	${POT_ZFS_ROOT}/bases/11.1/custom)
		echo 1234
		;;
	${POT_ZFS_ROOT}/jails/test-pot/usr.local|\
	${POT_ZFS_ROOT}/jails/test-pot/custom|\
	${POT_ZFS_ROOT}/jails/test-pot-2/custom)
		echo 4321
		;;
	${POT_ZFS_ROOT}/jails/test-pot-single/m|\
	${POT_ZFS_ROOT}/jails/test-pot-single-run/m)
		echo 6688
		;;
	esac
}

_cj_undo_clone()
{
	__monitor UNDO_CLONE "$@"
}

test_cj_zfs_001()
{
	_cj_zfs new-pot test-pot NO
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "3" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "2" MKDIR_CALLS
	assertEqualsMon "mkdir c1 arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "mkdir c2 arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL2_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/usr.local" ZFS_CALL2_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/usr.local@4321" ZFS_CALL2_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" ZFS_CALL2_ARG5
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" ZFS_CALL3_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/custom@4321" ZFS_CALL3_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL3_ARG5
}

test_cj_zfs_002()
{
	_cj_zfs new-pot test-pot-2 NO
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "2" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "2" MKDIR_CALLS
	assertEqualsMon "mkdir c1 arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "mkdir c2 arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL2_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" ZFS_CALL2_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-2/custom@4321" ZFS_CALL2_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL2_ARG5
}

test_cj_zfs_003()
{
	_cj_zfs new-pot test-pot YES
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "3" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "2" MKDIR_CALLS
	assertEqualsMon "mkdir c1 arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "mkdir c2 arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL2_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/usr.local" ZFS_CALL2_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/usr.local@4321" ZFS_CALL2_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" ZFS_CALL2_ARG5
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" ZFS_CALL3_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/custom@4321" ZFS_CALL3_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL3_ARG5
}

test_cj_zfs_004()
{
	_cj_zfs new-pot test-pot-2 YES
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "2" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "2" MKDIR_CALLS
	assertEqualsMon "mkdir c1 arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "mkdir c2 arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL2_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" ZFS_CALL2_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-2/custom@4321" ZFS_CALL2_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL2_ARG5
}

test_cj_zfs_005()
{
	_cj_zfs new-pot test-pot-nosnap YES
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "5" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "2" MKDIR_CALLS
	assertEqualsMon "mkdir c1 arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "mkdir c2 arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL2_ARG2
	assertEqualsMon "zfs arg1" "snapshot" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/test-pot-nosnap/usr.local@55555" ZFS_CALL2_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL3_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/usr.local" ZFS_CALL3_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-nosnap/usr.local@55555" ZFS_CALL3_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" ZFS_CALL3_ARG5
	assertEqualsMon "zfs arg1" "snapshot" ZFS_CALL4_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/test-pot-nosnap/custom@55555" ZFS_CALL4_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL5_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" ZFS_CALL5_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-nosnap/custom@55555" ZFS_CALL5_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL5_ARG5
}

test_cj_zfs_020()
{
	_cj_zfs new-pot test-pot-nosnap NO
	assertNotEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "1" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "undo_clone calls" "1" UNDO_CLONE_CALLS
}

test_cj_zfs_040()
{
	_cj_zfs new-pot test-pot-single NO
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "2" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/m" ZFS_CALL2_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-single/m@6688" ZFS_CALL2_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/m" ZFS_CALL2_ARG5
}

test_cj_zfs_041()
{
	_cj_zfs new-pot test-pot-single-run NO
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "2" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/m" ZFS_CALL2_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-single-run/m@6688" ZFS_CALL2_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/m" ZFS_CALL2_ARG5
}

test_cj_zfs_060()
{
	_cj_zfs new-pot test-pot-single NO 12345678
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "2" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/m" ZFS_CALL2_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-single/m@12345678" ZFS_CALL2_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/m" ZFS_CALL2_ARG5
	assertEqualsMon "zfs last snap calls" "0" ZFSLASTSNAP_CALLS
}

test_cj_zfs_061()
{
	_cj_zfs new-pot test-pot NO 12345678
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "3" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "2" MKDIR_CALLS
	assertEqualsMon "mkdir c1 arg2" "${POT_FS_ROOT}/jails/new-pot/conf" MKDIR_CALL1_ARG2
	assertEqualsMon "mkdir c2 arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL2_ARG2
	assertEqualsMon "zfs arg1" "clone" ZFS_CALL2_ARG1
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/usr.local" ZFS_CALL2_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/usr.local@12345678" ZFS_CALL2_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" ZFS_CALL2_ARG5
	assertEqualsMon "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" ZFS_CALL3_ARG3
	assertEqualsMon "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/custom@12345678" ZFS_CALL3_ARG4
	assertEqualsMon "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL3_ARG5
	assertEqualsMon "zfs last snap calls" "0" ZFSLASTSNAP_CALLS
}

setUp()
{
	common_setUp
	conf_setUp
}

tearDown()
{
	common_tearDown
	conf_tearDown
}

. shunit/shunit2
