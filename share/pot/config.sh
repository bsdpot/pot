#!/bin/sh

: "${_config_names:="fs_root zfs_root gateway syslogd pot_prefix fscomp_prefix"}"

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
	# shellcheck disable=SC2039
	local _quiet
	_quiet="NO"
	_get=
	if ! args=$(getopt hvqg: "$@") ; then
		config-help
		${EXIT} 1
	fi
	# shellcheck disable=SC2086
	set -- $args
	while true; do
		case "$1" in
		-h)
			config-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-q)
			_quiet="quiet"
			shift
			;;
		-g)
			if _is_in_list "$2" "$_config_names" ; then
				_get="$2"
			else
				_qerror $_quiet "$2 is not a valid name"
				[ "quiet" != "$_quiet" ] && config-help
				${EXIT} 1
			fi
			shift 2
			;;
		--)
			shift
			break
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
	esac
}

