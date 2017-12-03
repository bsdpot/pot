#!/bin/sh

EXIT="return"

# common stubs

_error()
{
	ERROR_CALLS=$(( ERROR_CALLS + 1 ))
	[ "$ERROR_DEBUG" = "YES" ]  && echo "_error: $*"
}

_info()
{
	INFO_CALLS=$(( INFO_CALLS + 1 ))
	[ "$INFO_DEBUG" = "YES" ] && echo "_error: $*"
}

_is_pot()
{
	ISPOT_CALLS=$(( ISPOT_CALLS + 1 ))
	if [ "$1" = "test-pot" -o "$1" = "test-pot-run" ]; then
		return 0 # true
	fi
	return 1 # false
}

_is_pot_running()
{
	ISPOTRUN_CALLS=$(( ISPOTRUN_CALLS + 1 ))
	if [ "$1" = "test-pot-run" ]; then
		return 0 # true
	fi
	return 1 # false
}

_zfs_exist()
{
	ZFSEXIST_CALLS=$(( ZFSEXIST_CALLS + 1 ))
	if [ "$1" = "/fscomp/test-fscomp" ]; then
		return 0 # true
	fi
	return 1 # false
}

_pot_zfs_snap()
{
	POTZFSSNAP_CALLS=$(( POTZFSSNAP_CALLS + 1 ))
	POTZFSSNAP_CALL1_ARG1=$1
}

_pot_zfs_snap_full()
{
	POTZFSSNAPFULL_CALLS=$(( POTZFSSNAPFULL_CALLS + 1 ))
	POTZFSSNAPFULL_CALL1_ARG1=$1
}

_fscomp_zfs_snap()
{
	FSCOMPZFSSNAP_CALLS=$(( FSCOMPZFSSNAP_CALLS + 1 ))
	FSCOMPZFSSNAP_CALL1_ARG1=$1
}

common_setUp()
{
	_POT_VERBOSITY=1
	ERROR_CALLS=0
	INFO_CALLS=0
	ISPOT_CALLS=0
	ISPOTRUN_CALLS=0
	ZFSEXIST_CALLS=0
	POTZFSSNAP_CALLS=0
	POTZFSSNAPFULL_CALLS=0
	FSCOMPZFSSNAP_CALLS=0
}

