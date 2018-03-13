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

# UUT
. ../share/pot/clone.sh

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
	${POT_ZFS_ROOT}/jails/test-pot/custom|\
	${POT_ZFS_ROOT}/jails/test-pot-2/custom)
		echo 4321
		;;
	esac
}

test_cj_zfs_001()
{
	_cj_zfs new-pot test-pot
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "3" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "2" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL2_ARG2"
	assertEquals "zfs arg1" "clone" "$ZFS_CALL2_ARG1"
	assertEquals "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/usr.local" "$ZFS_CALL2_ARG3"
	assertEquals "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/usr.local@4321" "$ZFS_CALL2_ARG4"
	assertEquals "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" "$ZFS_CALL2_ARG5"
	assertEquals "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" "$ZFS_CALL3_ARG3"
	assertEquals "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/custom@4321" "$ZFS_CALL3_ARG4"
	assertEquals "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" "$ZFS_CALL3_ARG5"
}

test_cj_zfs_002()
{
	_cj_zfs new-pot test-pot-2
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "2" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "2" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL2_ARG2"
	assertEquals "zfs arg1" "clone" "$ZFS_CALL2_ARG1"
	assertEquals "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" "$ZFS_CALL2_ARG3"
	assertEquals "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-2/custom@4321" "$ZFS_CALL2_ARG4"
	assertEquals "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" "$ZFS_CALL2_ARG5"
}

test_cj_zfs_003()
{
	_cj_zfs new-pot test-pot YES
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "3" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "2" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL2_ARG2"
	assertEquals "zfs arg1" "clone" "$ZFS_CALL2_ARG1"
	assertEquals "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/usr.local" "$ZFS_CALL2_ARG3"
	assertEquals "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/usr.local@4321" "$ZFS_CALL2_ARG4"
	assertEquals "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" "$ZFS_CALL2_ARG5"
	assertEquals "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" "$ZFS_CALL3_ARG3"
	assertEquals "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot/custom@4321" "$ZFS_CALL3_ARG4"
	assertEquals "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" "$ZFS_CALL3_ARG5"
}

test_cj_zfs_004()
{
	_cj_zfs new-pot test-pot-2 YES
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "2" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "2" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL2_ARG2"
	assertEquals "zfs arg1" "clone" "$ZFS_CALL2_ARG1"
	assertEquals "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" "$ZFS_CALL2_ARG3"
	assertEquals "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-2/custom@4321" "$ZFS_CALL2_ARG4"
	assertEquals "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" "$ZFS_CALL2_ARG5"
}

test_cj_zfs_005()
{
	_cj_zfs new-pot test-pot-nosnap YES
	assertEquals "return code" "0" "$?"
	assertEquals "zfs calls" "5" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "mkdir calls" "2" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/m" "$MKDIR_CALL2_ARG2"
	assertEquals "zfs arg1" "snapshot" "$ZFS_CALL2_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/test-pot-nosnap/usr.local@55555" "$ZFS_CALL2_ARG2"
	assertEquals "zfs arg1" "clone" "$ZFS_CALL3_ARG1"
	assertEquals "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/usr.local" "$ZFS_CALL3_ARG3"
	assertEquals "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-nosnap/usr.local@55555" "$ZFS_CALL3_ARG4"
	assertEquals "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/usr.local" "$ZFS_CALL3_ARG5"
	assertEquals "zfs arg1" "snapshot" "$ZFS_CALL4_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/test-pot-nosnap/custom@55555" "$ZFS_CALL4_ARG2"
	assertEquals "zfs arg1" "clone" "$ZFS_CALL5_ARG1"
	assertEquals "zfs arg3" "mountpoint=${POT_FS_ROOT}/jails/new-pot/custom" "$ZFS_CALL5_ARG3"
	assertEquals "zfs arg4" "${POT_ZFS_ROOT}/jails/test-pot-nosnap/custom@55555" "$ZFS_CALL5_ARG4"
	assertEquals "zfs arg5" "${POT_ZFS_ROOT}/jails/new-pot/custom" "$ZFS_CALL5_ARG5"
}

test_cj_zfs_20()
{
	_cj_zfs new-pot test-pot-nosnap NO
	assertNotEquals "return code" "0" "$?"
	assertEquals "zfs calls" "2" "$ZFS_CALLS"
	assertEquals "zfs arg1" "create" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL1_ARG2"
	assertEquals "zfs arg1" "destroy" "$ZFS_CALL2_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/new-pot" "$ZFS_CALL2_ARG3"
}

setUp()
{
	common_setUp
	ZFS_CALLS=0
	ECHO_CALLS=0
	MKDIR_CALLS=0
	DATE_CALLS=0
	ZFSDATASETVALID_CALLS=0
	ZFSLASTSNAP_CALLS=0

	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
	/bin/mkdir -p /tmp/jails/test-pot/conf
	echo "zpot/bases/11.1 /tmp/jails/test-pot/m ro" >> /tmp/jails/test-pot/conf/fscomp.conf
	echo "zpot/jails/test-pot/usr.local /tmp/jails/test-pot/m/usr/local zfs-remount" >> /tmp/jails/test-pot/conf/fscomp.conf
	echo "zpot/jails/test-pot/custom /tmp/jails/test-pot/m/opt/custom zfs-remount" >> /tmp/jails/test-pot/conf/fscomp.conf

	/bin/mkdir -p /tmp/jails/test-pot-2/conf
	echo "zpot/bases/11.1 /tmp/jails/test-pot-2/m ro" >> /tmp/jails/test-pot-2/conf/fscomp.conf
	echo "zpot/jails/test-pot/usr.local /tmp/jails/test-pot-2/m/usr/local ro" >> /tmp/jails/test-pot-2/conf/fscomp.conf
	echo "zpot/jails/test-pot-2/custom /tmp/jails/test-pot-2/m/opt/custom zfs-remount" >> /tmp/jails/test-pot-2/conf/fscomp.conf

	/bin/mkdir -p /tmp/jails/test-pot-nosnap/conf
	echo "zpot/bases/11.1 /tmp/jails/test-pot-nosnap/m ro" >> /tmp/jails/test-pot-nosnap/conf/fscomp.conf
	echo "zpot/jails/test-pot-nosnap/usr.local /tmp/jails/test-pot-nosnap/m/usr/local zfs-remount" >> /tmp/jails/test-pot-nosnap/conf/fscomp.conf
	echo "zpot/jails/test-pot-nosnap/custom /tmp/jails/test-pot-nosnap/m/opt/custom zfs-remount" >> /tmp/jails/test-pot-nosnap/conf/fscomp.conf
}

tearDown()
{
	rm -rf /tmp/jails
}

. shunit/shunit2
