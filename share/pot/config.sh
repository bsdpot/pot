#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043

: "${_config_names:="fs_root zfs_root gateway syslogd pot_prefix fscomp_prefix network_stack"}"

config-help()
{
	echo 'pot config [-h][-v][-q] [-g name ]'
	echo '  -h -- print this help'
	echo '  -v verbose'
	echo '  -q quiet'
	echo '  -g name : get name value'
	echo '    '"possible names are $_config_names"
}

# $1 quiet
# $2 name
# $3 value
_config_echo()
{
	if [ "$1" = "quiet" ]; then
		echo "$3"
	else
		echo "$2 = $3"
	fi
}

pot-config()
{
	local _quiet
	_quiet="NO"
	_get=
	OPTIND=1

	while getopts "hvqg:" _o ; do
		case "$_o" in
		h)
			config-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_quiet="quiet"
			;;
		g)
			if _is_in_list "$OPTARG" "$_config_names" ; then
				_get="$OPTARG"
			else
				_qerror $_quiet "$OPTARG is not a valid name"
				[ "quiet" != "$_quiet" ] && config-help
				${EXIT} 1
			fi
			;;
		?)
			config-help
			${EXIT} 1
			;;
		esac
	done

	if [ -z "$_get" ]; then
		_qerror $_quiet "option -g is mandatory"
		[ "quiet" != "$_quiet" ] && config-help
		${EXIT} 1
	fi
	case $_get in
		fs_root)
			_config_echo $_quiet "fs_root" "$POT_FS_ROOT"
			;;
		zfs_root)
			_config_echo $_quiet "zfs_root" "$POT_ZFS_ROOT"
			;;
		gateway)
			_config_echo $_quiet "gateway" "$POT_GATEWAY"
			;;
		syslogd)
			_config_echo $_quiet "syslogd flags" "-b 127.0.0.1 -b $POT_GATEWAY -a $POT_NETWORK"
			;;
		pot_prefix)
			_config_echo $_quiet "pot prefix" "$POT_FS_ROOT/jails"
			;;
		fscomp_prefix)
			_config_echo $_quiet "fscomp prefix" "$POT_FS_ROOT/fscomp"
			;;
		network_stack)
			_config_echo $_quiet "network stack" "$( _get_network_stack )"
			;;
	esac
}
