#!/bin/sh
. ../share/pot/common.sh
EXIT="return"

# common stubs
. monitor.sh

##### recognized pots
# name						running	type	level	ip			vnet	network_type
# test-pot					no		multi	1		inherit		undef	inherit
# test-pot-2				no		multi	2		10.1.2.3	yes		public-bridge
# test-pot-run				yes		multi	1		undef		undef	undef
# test-pot-run-2			yes		multi	2		undef		undef	undef
# test-pot-0				no		multi	0		inherit		undef	inherit
# test-pot-nosnap			no		multi	1		inherit		undef	inherit
# test-pot-single			no		single	0		10.1.2.3	yes		public-bridge
# test-pot-single-run		yes		single	0		undef		yes		public-bridge
# test-pot-single-2			no		single	0		10.1.2.3	yes		public-bridge
# test-pot-single-0			no		single	0		10.1.2.3	yes		public-bridge
# test-pot-3				no		multi	1		10.1.2.3	no		alias

# test-pot-multi-inherit	no		multi	1					no		inherit
# test-pot-multi-private	no		multi	1		10.1.3.3	yes		private-bridge

##### recognized bridges
# name						net				gateway
# test-bridge				10.1.3.0/28		10.1.3.1

_error()
{
	__monitor ERROR "$@"
	[ "$ERROR_DEBUG" = "YES" ]  && echo "_error: $*"
}

_info()
{
	__monitor INFO "$@"
	[ "$INFO_DEBUG" = "YES" ] && echo "_info: $*"
}

_debug()
{
	__monitor DEBUG "$@"
	[ "$DEBUG_DEBUG" = "YES" ] && echo "_debug: $*"
}

_is_verbose() {
	if [ $_POT_VERBOSITY -gt 1 ]; then
		return 0
	else
		return 1
	fi
}

_is_uid0()
{
	__monitor ISUID0 "$@"
	return 0 # true
}

_is_flavourdir()
{
	__monitor ISFLVDIR "$@"
	return 0 # true
}

_is_pot()
{
	__monitor ISPOT "$@"
	case "$1" in
		test-pot|test-pot-run|\
		test-pot-2|test-pot-run-2|\
		test-pot-0|test-pot-nosnap|test-pot-3|\
		test-pot-single|test-pot-single-run|test-pot-single-2|test-pot-single-0|\
		test-pot-multi-inherit|test-pot-multi-private|\
		${POT_DNS_NAME})
			return 0 # true
			;;
	esac
	return 1 # false
}

_is_pot_running()
{
	__monitor ISPOTRUN "$@"
	case "$1" in
		test-pot-run|test-pot-run-2|\
		test-pot-single-run)
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

_is_fscomp()
{
	__monitor ISFSCOMP "$@"
	case "$1" in
		test-fscomp)
			return 0 # true
			;;
	esac
	return 1 # false
}

_is_flavour()
{
	case $1 in
		default|flap|flap2)
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
		test-pot|test-pot-run|test-pot-3|\
		test-pot-nosnap|test-pot-multi-inherit|\
		test-pot-multi-private)
			echo "1"
			;;
		test-pot-2|test-pot-run-2)
			echo "2"
			;;
		test-pot-0|test-pot-single|test-pot-single-run|\
		test-pot-single-2|test-pot-single-0)
			echo "0"
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
		;;
	"ip")
		case $1 in
		test-pot|test-pot-0)
			echo ""
			;;
		test-pot-2|test-pot-3|\
		test-pot-single|test-pot-single-2|test-pot-single-0)
			echo "10.1.2.3"
			;;
		test-pot-multi-private)
			echo "10.1.3.3"
			;;
		esac
		;;
	"network_type")
		case $1 in
		test-pot|test-pot-0|\
		test-pot-multi-inherit)
			echo "inherit"
			;;
		test-pot-3)
			echo "alias"
			;;
		test-pot-2|test-pot-single-run|\
		test-pot-single|test-pot-single-2|test-pot-single-0)
			echo "public-bridge"
			;;
		test-pot-multi-private)
			echo "private-bridge"
			;;
		esac
		;;
	"pot.type")
		case $1 in
		test-pot|test-pot-0|test-pot-3|\
		test-pot-run|test-pot-nosnap|\
		test-pot-2|test-pot-run-2|\
		test-pot-multi-inherit|test-pot-multi-private)
			echo "multi"
			;;
		test-pot-single|test-pot-single-run|test-pot-single-2|test-pot-single-0)
			echo "single"
		esac
		;;
	"vnet")
		case $1 in
		test-pot-2|test-pot-single|test-pot-single-run|\
		test-pot-multi-private|test-pot-single-2|test-pot-single-0)
			echo "true"
			;;
		test-pot-3|test-pot-multi-inherit)
			echo "false"
			;;
		esac
		;;
	"bridge")
		case $1 in
		test-pot-multi-private)
			echo "test-bridge"
			;;
		esac
		;;
	"host.hostname")
		echo "$1.test-domain"
		;;
	esac
}

_get_pot_base()
{
	__monitor GETPOTBASE "$@"
	case "$1" in
		test-pot|test-pot-run|\
		test-pot-2|test-pot-run-2|\
		test-pot-single|test-pot-single-run)
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

_remove_oldest_pot_snap()
{
	__monitor RMVPOTSNAP "$@"
}

_pot_zfs_snap_full()
{
	__monitor POTZFSSNAPFULL "$@"
}

_fscomp_zfs_snap()
{
	__monitor FSCOMPZFSSNAP "$@"
}

_remove_oldest_fscomp_snap()
{
	__monitor RMVFSCOMPSNAP "$@"
}

_is_valid_release()
{
	case "$1" in
		10.1|10.4|11.0|11.1)
		   return 0 # true
		   ;;
	   *)
		   return 1 # false
		   ;;
   esac
}

_is_bridge()
{
	case "$1" in
		test-bridge)
			return 0 # return true
			;;
	esac
	return 1 # false
}
_get_bridge_var()
{
	__monitor GETBRIDGEVAR "$@"
	case "$2" in
		name)
			case "$1" in
				test-bridge)
					echo "test-bridge"
					;;
			esac
			;;
		net)
			case "$1" in
				test-bridge)
					echo "10.1.3.0/28"
					;;
			esac
			;;
		gateway)
			case "$1" in
				test-bridge)
					echo "10.1.3.1"
					;;
			esac
			;;
	esac
}

common_setUp()
{
	_POT_VERBOSITY=1
	POT_DNS_NAME=dns
	ERROR_CALLS=0
	INFO_CALLS=0
	DEBUG_CALLS=0
	ISUID0_CALLS=0
	ISPOT_CALLS=0
	ISPOTRUN_CALLS=0
	ISBASE_CALLS=0
	ISFSCOMP_CALLS=0
	GETCONFVAR_CALLS=0
	GETPOTBASE_CALLS=0
	ZFSEXIST_CALLS=0
	POTZFSSNAP_CALLS=0
	RMVPOTSNAP_CALLS=0
	POTZFSSNAPFULL_CALLS=0
	FSCOMPZFSSNAP_CALLS=0
	RMVFSCOMPSNAP_CALLS=0
	GETBRIDGEVAR_CALLS=0
}

