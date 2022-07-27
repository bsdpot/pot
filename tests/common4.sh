#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/common.sh

# common stubs
. ./monitor.sh

_qerror()
{
	__monitor QERR $*
}

_zfs_exist()
{
	if [ "$1" = "zpot" ] && [ "$2" = "/opt" ]; then
		return 0 # true
	fi
	return 1
}

_zfs_dataset_valid()
{
	return 0
}

# app specific stubs

test_is_init_001()
{
	POT_ZFS_ROOT=
	_is_init quiet
	assertEquals "1" "$?"
}

test_is_init_002()
{
	POT_FS_ROOT=
	_is_init quiet
	assertEquals "1" "$?"
}

test_is_init_003()
{
	POT_FS_ROOT=/usr/local/pot
	_is_init quiet
	assertEquals "1" "$?"
}

test_is_init_004()
{
	POT_ZFS_ROOT=zroot
	_is_init quiet
	assertEquals "1" "$?"
}

test_is_init_020()
{
	_is_init quiet
	assertEquals "0" "$?"
}

setUp()
{
	__mon_init
	POT_ZFS_ROOT=zpot
	POT_FS_ROOT=/opt
}

tearDown()
{
	__mon_tearDown
}

. shunit/shunit2
