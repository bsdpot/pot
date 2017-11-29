#!/bin/sh

# supported releases
revert-help()
{
	echo "pot revert [-h][-v][-f] [potname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f full'
	echo '  potname : the pot target of the revert'
}

# $1 pot name
_pot_zfs_rollback()
{
	local _pname _pdir _snap
	_pname=$1
	_pdset=${POT_ZFS_ROOT}/jails/$_pname
	for _dset in $( zfs list -o name -H -r $_pdset | sort -r | tr '\n' ' ') ; do
		_snap="$( _zfs_last_snap $_dset)"
		if [ -z "$_snap" ]; then
			_info "$_dset has not snapshot - no possible rollback"
			continue
		fi
		zfs rollback $_dset@$_snap
	done
}

_pot_zfs_rollback_full()
{
	local _pname _pdir _snap _node _opt _dset
	_pname=$1
	_pdir=${POT_FS_ROOT}/jails/$_pname
	while read -r line ; do
		_node=$( echo $line | awk '{print $1}' )
		_opt=$( echo $line | awk '{print $3}' )
		if [ "$_opt" = "ro" ]; then
			continue
		fi
		_dset=$( zfs list -o name -H $_node )
		_snap="$( _zfs_last_snap $_dset)"
		if [ -z "$_snap" ]; then
			_info "$_dset has not snapshot - no possible rollback"
			continue
		fi
		zfs rollback ${_dset}@${_snap}
	done < ${_pdir}/conf/fs.conf
}

pot-revert()
{
	local _pname _full
	args=$(getopt hvf $*)
	if [ $? -ne 0 ]; then
		revert-help
		exit 1
	fi
	_full="NO"
	set -- $args
	while true; do
		case "$1" in
		-h)
			revert-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-f)
			_full="YES"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done
	_pname=$1
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		revert-help
		exit 1
	fi
	if ! _is_pot $_pname ; then
		_error "The pot $_pname is not a valid pot"
		exit 1
	fi
	if _is_pot_running $_pname ; then
		_error "The pot $_pname is still running. Revert is possible only for stopped pots"
		exit 1
	fi
	if [ "$_full" = "YES" ]; then
		_pot_zfs_rollback_full $_pname
	else
		_pot_zfs_rollback $_pname
	fi
}
