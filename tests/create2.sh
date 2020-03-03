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
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL1_ARG2"
	assertEquals "chmod calls" "0" "$CHMOD_CALLS"
}

test_cj_zfs_002()
{
	_c_zfs_multi new-pot 1 11.1
	assertEquals "return code" "0" "$?"
	# unfortunately, all the other zfs command are executed in subshell
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL1_ARG2"
	assertEquals "chmod calls" "0" "$CHMOD_CALLS"
}

test_cj_zfs_003()
{
	_c_zfs_multi new-pot 1 11.1 test-pot
	assertEquals "return code" "0" "$?"
	# unfortunately, all the other zfs command are executed in subshell
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL1_ARG2"
	assertEquals "chmod calls" "0" "$CHMOD_CALLS"
}

test_cj_zfs_004()
{
	_c_zfs_multi new-pot 2 11.1 test-pot
	assertEquals "return code" "0" "$?"
	# unfortunately, all the other zfs command are executed in subshell
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL1_ARG2"
	assertEquals "chmod calls" "0" "$CHMOD_CALLS"
}

test_cj_zfs_021()
{
	_cj_zfs test-pot multi 0 11.1
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/test-pot/m" "$MKDIR_CALL1_ARG2"
	assertEquals "info calls" "1" "$INFO_CALLS"
	assertEquals "chmod calls" "0" "$CHMOD_CALLS"
}

test_cj_zfs_022()
{
	_cj_zfs test-pot multi 1 11.1
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/test-pot/m" "$MKDIR_CALL1_ARG2"
	assertEquals "info calls" "3" "$INFO_CALLS"
	assertEquals "chmod calls" "0" "$CHMOD_CALLS"
}

test_cj_zfs_023()
{
	_cj_zfs test-pot multi 2 11.1 test-pot2
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/test-pot/m" "$MKDIR_CALL1_ARG2"
	assertEquals "info calls" "2" "$INFO_CALLS"
	assertEquals "chmod calls" "0" "$CHMOD_CALLS"
}

test_cj_zfs_041()
{
	_cj_zfs new-pot single 0 11.1
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "2" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "zfs arg1" "create" "$ZFS_CALL2_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot/m" "$ZFS_CALL2_ARG2"
	assertEquals "mkdir calls" "2" "$MKDIR_CALLS"
	assertEquals "mkdir 1 arg2" "${POT_FS_ROOT}/jails/new-pot/m/tmp" "$MKDIR_CALL1_ARG2"
	assertEquals "mkdir 2 arg2" "${POT_FS_ROOT}/jails/new-pot/m/dev" "$MKDIR_CALL2_ARG2"
	assertEquals "chmod calls" "1" "$CHMOD_CALLS"
	assertEquals "chmod arg1" "1777" "$CHMOD_CALL1_ARG1"
	assertEquals "chmod arg2" "${POT_FS_ROOT}/jails/new-pot/m/tmp" "$CHMOD_CALL1_ARG2"
}

test_cj_zfs_042()
{
	_cj_zfs test-pot single 0 11.1
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/test-pot/m" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "2" "$MKDIR_CALLS"
	assertEquals "mkdir 1 arg2" "${POT_FS_ROOT}/jails/test-pot/m/tmp" "$MKDIR_CALL1_ARG2"
	assertEquals "mkdir 2 arg2" "${POT_FS_ROOT}/jails/test-pot/m/dev" "$MKDIR_CALL2_ARG2"
	assertEquals "chmod calls" "1" "$CHMOD_CALLS"
	assertEquals "chmod arg1" "1777" "$CHMOD_CALL1_ARG1"
	assertEquals "chmod arg2" "${POT_FS_ROOT}/jails/test-pot/m/tmp" "$CHMOD_CALL1_ARG2"
}

test_cj_zfs_043()
{
	_cj_zfs new-pot single 0 11.1 test-pot
	assertEquals "return code" "0" "$?"
	# unfortunately, all the other zfs command are executed in subshell
	assertEquals "zfs calls" "1" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "0" "$MKDIR_CALLS"
	assertEquals "chmod calls" "0" "$CHMOD_CALLS"
}

setUp()
{
	common_setUp
	ZFS_CALLS=0
	ECHO_CALLS=0
	MKDIR_CALLS=0
	CHMOD_CALLS=0
	ZFSDATASETVALID_CALLS=0
	ZFSLASTSNAP_CALLS=0

	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
