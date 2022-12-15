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
}

chmod()
{
	__monitor CHMOD "$@"
	if [ "$2" = "/tmp/jails/new-pot/m/tmp" ]; then
		return 0 # true
	fi
	if [ "$2" = "/tmp/jails/test-pot/m/tmp" ]; then
		return 0 # true
	fi
	/bin/chmod $@
}

. pipefail-stub.sh

# UUT
. ../share/pot/create.sh

# common stubs
. common-stub.sh

_zfs_dataset_valid()
{
	__monitor ZFSDATASETVALID "$@"
	case "$1" in
	${POT_ZFS_ROOT}/jails/test-pot|\
	${POT_ZFS_ROOT}/jails/test-pot/usr.local|\
	${POT_ZFS_ROOT}/jails/test-pot/custom)
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
	${POT_ZFS_ROOT}/jails/test-pot/custom)
		echo 4321
		;;
	${POT_ZFS_ROOT}/jails/test-pot/m)
		echo 9999
		;;
	esac
}

test_cj_zfs_001()
{
	# level 0
	_c_zfs_multi new-pot 0 11.1
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "1" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL1_ARG2
	assertEqualsMon "chmod calls" "0" CHMOD_CALLS
}

test_cj_zfs_002()
{
	_c_zfs_multi new-pot 1 11.1
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "9" ZFS_CALLS
	assertEqualsMon "zfs c1 arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs c1 arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "zfs c2 arg1" "send" ZFS_CALL2_ARG1
	assertEqualsMon "zfs c2 arg2" "${POT_ZFS_ROOT}/bases/11.1/usr.local@1234" ZFS_CALL2_ARG2
	assertEqualsMon "zfs c3 arg1" "get" ZFS_CALL3_ARG1
	assertEqualsMon "zfs c3 arg2" "-o" ZFS_CALL3_ARG2
	assertEqualsMon "zfs c3 arg3" "property" ZFS_CALL3_ARG3
	assertEqualsMon "zfs c3 arg4" "all" ZFS_CALL3_ARG4
	assertEqualsMon "zfs c3 arg5" "${POT_ZFS_ROOT}" ZFS_CALL3_ARG5
	assertEqualsMon "zfs c4 arg1" "receive" ZFS_CALL4_ARG1
	assertEqualsMon "zfs c4 arg2" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" ZFS_CALL4_ARG2
	assertEqualsMon "zfs c5 arg1" "destroy" ZFS_CALL5_ARG1
	assertEqualsMon "zfs c5 arg2" "${POT_ZFS_ROOT}/jails/new-pot/usr.local@1234" ZFS_CALL5_ARG2
	assertEqualsMon "zfs c6 arg1" "send" ZFS_CALL6_ARG1
	assertEqualsMon "zfs c6 arg2" "${POT_ZFS_ROOT}/bases/11.1/custom@1234" ZFS_CALL6_ARG2
	assertEqualsMon "zfs c7 arg1" "get" ZFS_CALL7_ARG1
	assertEqualsMon "zfs c7 arg2" "-o" ZFS_CALL7_ARG2
	assertEqualsMon "zfs c7 arg3" "property" ZFS_CALL7_ARG3
	assertEqualsMon "zfs c7 arg4" "all" ZFS_CALL7_ARG4
	assertEqualsMon "zfs c7 arg5" "${POT_ZFS_ROOT}" ZFS_CALL7_ARG5
	assertEqualsMon "zfs c8 arg1" "receive" ZFS_CALL8_ARG1
	assertEqualsMon "zfs c8 arg2" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL8_ARG2
	assertEqualsMon "zfs c9 arg1" "destroy" ZFS_CALL9_ARG1
	assertEqualsMon "zfs c9 arg2" "${POT_ZFS_ROOT}/jails/new-pot/custom@1234" ZFS_CALL9_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL1_ARG2
	assertEqualsMon "chmod calls" "0" CHMOD_CALLS
}

test_cj_zfs_003()
{
	_c_zfs_multi new-pot 1 11.1 test-pot
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "9" ZFS_CALLS
	assertEqualsMon "zfs c1 arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs c1 arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "zfs c2 arg1" "send" ZFS_CALL2_ARG1
	assertEqualsMon "zfs c2 arg2" "${POT_ZFS_ROOT}/jails/test-pot/usr.local@4321" ZFS_CALL2_ARG2
	assertEqualsMon "zfs c3 arg1" "get" ZFS_CALL3_ARG1
	assertEqualsMon "zfs c3 arg2" "-o" ZFS_CALL3_ARG2
	assertEqualsMon "zfs c3 arg3" "property" ZFS_CALL3_ARG3
	assertEqualsMon "zfs c3 arg4" "all" ZFS_CALL3_ARG4
	assertEqualsMon "zfs c3 arg5" "${POT_ZFS_ROOT}" ZFS_CALL3_ARG5
	assertEqualsMon "zfs c4 arg1" "receive" ZFS_CALL4_ARG1
	assertEqualsMon "zfs c4 arg2" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" ZFS_CALL4_ARG2
	assertEqualsMon "zfs c5 arg1" "destroy" ZFS_CALL5_ARG1
	assertEqualsMon "zfs c5 arg2" "${POT_ZFS_ROOT}/jails/new-pot/usr.local@4321" ZFS_CALL5_ARG2
	assertEqualsMon "zfs c6 arg1" "send" ZFS_CALL6_ARG1
	assertEqualsMon "zfs c6 arg2" "${POT_ZFS_ROOT}/jails/test-pot/custom@4321" ZFS_CALL6_ARG2
	assertEqualsMon "zfs c7 arg1" "get" ZFS_CALL7_ARG1
	assertEqualsMon "zfs c7 arg2" "-o" ZFS_CALL7_ARG2
	assertEqualsMon "zfs c7 arg3" "property" ZFS_CALL7_ARG3
	assertEqualsMon "zfs c7 arg4" "all" ZFS_CALL7_ARG4
	assertEqualsMon "zfs c7 arg5" "${POT_ZFS_ROOT}" ZFS_CALL7_ARG5
	assertEqualsMon "zfs c8 arg1" "receive" ZFS_CALL8_ARG1
	assertEqualsMon "zfs c8 arg2" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL8_ARG2
	assertEqualsMon "zfs c9 arg1" "destroy" ZFS_CALL9_ARG1
	assertEqualsMon "zfs c9 arg2" "${POT_ZFS_ROOT}/jails/new-pot/custom@4321" ZFS_CALL9_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL1_ARG2
	assertEqualsMon "chmod calls" "0" CHMOD_CALLS
}

test_cj_zfs_004()
{
	_c_zfs_multi new-pot 2 11.1 test-pot
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "5" ZFS_CALLS
	assertEqualsMon "zfs c1 arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs c1 arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "zfs c2 arg1" "send" ZFS_CALL2_ARG1
	assertEqualsMon "zfs c2 arg2" "${POT_ZFS_ROOT}/jails/test-pot/custom@4321" ZFS_CALL2_ARG2
	assertEqualsMon "zfs c3 arg1" "get" ZFS_CALL3_ARG1
	assertEqualsMon "zfs c3 arg2" "-o" ZFS_CALL3_ARG2
	assertEqualsMon "zfs c3 arg3" "property" ZFS_CALL3_ARG3
	assertEqualsMon "zfs c3 arg4" "all" ZFS_CALL3_ARG4
	assertEqualsMon "zfs c3 arg5" "${POT_ZFS_ROOT}" ZFS_CALL3_ARG5
	assertEqualsMon "zfs c4 arg1" "receive" ZFS_CALL4_ARG1
	assertEqualsMon "zfs c4 arg2" "${POT_ZFS_ROOT}/jails/new-pot/custom" ZFS_CALL4_ARG2
	assertEqualsMon "zfs c5 arg1" "destroy" ZFS_CALL5_ARG1
	assertEqualsMon "zfs c5 arg2" "${POT_ZFS_ROOT}/jails/new-pot/custom@4321" ZFS_CALL5_ARG2
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" MKDIR_CALL1_ARG2
	assertEqualsMon "chmod calls" "0" CHMOD_CALLS
}

test_cj_zfs_021()
{
	_cj_zfs test-pot multi 0 11.1
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "0" ZFS_CALLS
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/test-pot/m" MKDIR_CALL1_ARG2
	assertEqualsMon "info calls" "1" INFO_CALLS
	assertEqualsMon "chmod calls" "0" CHMOD_CALLS
}

test_cj_zfs_022()
{
	_cj_zfs test-pot multi 1 11.1
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "0" ZFS_CALLS
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/test-pot/m" MKDIR_CALL1_ARG2
	assertEqualsMon "info calls" "3" INFO_CALLS
	assertEqualsMon "chmod calls" "0" CHMOD_CALLS
}

test_cj_zfs_023()
{
	_cj_zfs test-pot multi 2 11.1 test-pot2
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "0" ZFS_CALLS
	assertEqualsMon "mkdir calls" "1" MKDIR_CALLS
	assertEqualsMon "mkdir arg2" "${POT_FS_ROOT}/jails/test-pot/m" MKDIR_CALL1_ARG2
	assertEqualsMon "info calls" "2" INFO_CALLS
	assertEqualsMon "chmod calls" "0" CHMOD_CALLS
}

test_cj_zfs_041()
{
	_cj_zfs new-pot single 0 11.1
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "2" ZFS_CALLS
	assertEqualsMon "zfs c1 arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs c1 arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "zfs c2 arg1" "create" ZFS_CALL2_ARG1
	assertEqualsMon "zfs c2 arg2" "${POT_ZFS_ROOT}/jails/new-pot/m" ZFS_CALL2_ARG2
	assertEqualsMon "mkdir calls" "2" MKDIR_CALLS
	assertEqualsMon "mkdir 1 arg2" "${POT_FS_ROOT}/jails/new-pot/m/tmp" MKDIR_CALL1_ARG2
	assertEqualsMon "mkdir 2 arg2" "${POT_FS_ROOT}/jails/new-pot/m/dev" MKDIR_CALL2_ARG2
	assertEqualsMon "chmod calls" "1" CHMOD_CALLS
	assertEqualsMon "chmod arg1" "1777" CHMOD_CALL1_ARG1
	assertEqualsMon "chmod arg2" "${POT_FS_ROOT}/jails/new-pot/m/tmp" CHMOD_CALL1_ARG2
}

test_cj_zfs_042()
{
	_cj_zfs test-pot single 0 11.1
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "1" ZFS_CALLS
	assertEqualsMon "zfs arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs arg2" "${POT_ZFS_ROOT}/jails/test-pot/m" ZFS_CALL1_ARG2
	assertEqualsMon "mkdir calls" "2" MKDIR_CALLS
	assertEqualsMon "mkdir 1 arg2" "${POT_FS_ROOT}/jails/test-pot/m/tmp" MKDIR_CALL1_ARG2
	assertEqualsMon "mkdir 2 arg2" "${POT_FS_ROOT}/jails/test-pot/m/dev" MKDIR_CALL2_ARG2
	assertEqualsMon "chmod calls" "1" CHMOD_CALLS
	assertEqualsMon "chmod arg1" "1777" CHMOD_CALL1_ARG1
	assertEqualsMon "chmod arg2" "${POT_FS_ROOT}/jails/test-pot/m/tmp" CHMOD_CALL1_ARG2
}

test_cj_zfs_043()
{
	_cj_zfs new-pot single 0 11.1 test-pot
	assertEquals "return code" "0" "$?"
	assertEqualsMon "zfs calls" "4" ZFS_CALLS
	assertEqualsMon "zfs c1 arg1" "create" ZFS_CALL1_ARG1
	assertEqualsMon "zfs c1 arg2" "${POT_ZFS_ROOT}/jails/new-pot" ZFS_CALL1_ARG2
	assertEqualsMon "zfs c2 arg1" "send" ZFS_CALL2_ARG1
	assertEqualsMon "zfs c2 arg2" "${POT_ZFS_ROOT}/jails/test-pot/m@9999" ZFS_CALL2_ARG2
	assertEqualsMon "zfs c3 arg1" "get" ZFS_CALL3_ARG1
	assertEqualsMon "zfs c3 arg2" "-o" ZFS_CALL3_ARG2
	assertEqualsMon "zfs c3 arg3" "property" ZFS_CALL3_ARG3
	assertEqualsMon "zfs c3 arg4" "all" ZFS_CALL3_ARG4
	assertEqualsMon "zfs c3 arg5" "${POT_ZFS_ROOT}" ZFS_CALL3_ARG5
	assertEqualsMon "zfs c4 arg1" "receive" ZFS_CALL4_ARG1
	assertEqualsMon "zfs c4 arg2" "${POT_ZFS_ROOT}/jails/new-pot/m" ZFS_CALL4_ARG2
	assertEqualsMon "mkdir calls" "0" MKDIR_CALLS
	assertEqualsMon "chmod calls" "0" CHMOD_CALLS
}

setUp()
{
	common_setUp
	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
