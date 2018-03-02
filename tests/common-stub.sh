#!/bin/sh

EXIT="return"

# common stubs
. monitor.sh

_error()
{
	__monitor ERROR "$@"
	[ "$ERROR_DEBUG" = "YES" ]  && echo "_error: $*"
}

_info()
{
	__monitor INFO "$@"
	[ "$INFO_DEBUG" = "YES" ] && echo "_error: $*"
}

_debug()
{
	__monitor DEBUG "$@"
	[ "$INFO_DEBUG" = "YES" ] && echo "_error: $*"
}

_is_verbose() {
	return 1
}
_is_uid0()
{
	__monitor ISUID0 "$@"
	return 0 # true
}

_is_pot()
{
	__monitor ISPOT "$@"
	case "$1" in
		test-pot|test-pot-run|\
		test-pot-2|test-pot-run-2)
			return 0 # true
			;;
	esac
	return 1 # false
}

_is_pot_running()
{
	__monitor ISPOTRUN "$@"
	case "$1" in
		test-pot-run|test-pot-run-2)
			return 0 # true
			;;
	esac
	return 1 # false
}

_is_base()
{
	__monitor ISBASE "$@"
	case "$1" in
		test-base|11.1)
			return 0 # true
			;;
	esac
	return 1 # false
}

_get_conf_var()
{
	__monitor GETCONFVAR "$@"
	case "$2" in
	"pot.level")
		case "$1" in
		test-pot|test-pot-run)
			echo "1"
			;;
		test-pot-2|test-pot-run-2)
			echo "2"
			;;
		esac
		;;
	"pot.potbase")
		case "$1" in
		test-pot-2)
			echo "test-pot"
			;;
		test-pot-run-2)
			echo "test-pot-run"
			;;
		esac
	esac
}

_get_pot_base()
{
	__monitor GETPOTBASE "$@"
	case "$1" in
		test-pot|test-pot-run|\
		test-pot-2|test-pot-run-2)
			echo "11.1"
			;;
	esac
}

_zfs_exist()
{
	__monitor ZFSEXIST "$@"
	case "$1" in
		/fscomp/test-fscomp)
			return 0 # true
			;;
	esac
	return 1 # false
}

_pot_zfs_snap()
{
	__monitor POTZFSSNAP "$@"
}

_pot_zfs_snap_full()
{
	__monitor POTZFSSNAPFULL "$@"
}

_fscomp_zfs_snap()
{
	__monitor FSCOMPZFSSNAP "$@"
}

common_setUp()
{
	_POT_VERBOSITY=1
	ERROR_CALLS=0
	INFO_CALLS=0
	DEBUG_CALLS=0
	ISUID0_CALLS=0
	ISPOT_CALLS=0
	ISPOTRUN_CALLS=0
	ISBASE_CALLS=0
	GETCONFVAR_CALLS=0
	GETPOTBASE_CALLS=0
	ZFSEXIST_CALLS=0
	POTZFSSNAP_CALLS=0
	POTZFSSNAPFULL_CALLS=0
	FSCOMPZFSSNAP_CALLS=0
}

