#!/bin/sh

# supported releases
revert-help()
{
	echo "pot revert [-hva] -p potname|-f fscomp"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -a all components of a pot'
	echo '  -p potname : the pot target of the revert'
	echo '  -f fscomp : the fs component target of the revert'
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

_fscomp_zfs_rollback()
{
	local _fscomp _pdir _snap
	_fscomp=$1
	_fdset=${POT_ZFS_ROOT}/fscomp/$_fscomp
	for _dset in $( zfs list -o name -H -r $_fdset | sort -r | tr '\n' ' ') ; do
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
		_dset=$( echo $line | awk '{print $1}' )
		_opt=$( echo $line | awk '{print $3}' )
		if [ "$_opt" = "ro" ]; then
			continue
		fi
		_snap="$( _zfs_last_snap $_dset)"
		if [ -z "$_snap" ]; then
			_info "$_dset has not snapshot - no possible rollback"
			continue
		fi
		zfs rollback ${_dset}@${_snap}
	done < ${_pdir}/conf/fscomp.conf
}

pot-revert()
{
	local _obj _full_pot
	args=$(getopt hvap:f: $*)
	if [ $? -ne 0 ]; then
		revert-help
		${EXIT} 1
	fi
	_full_pot="NO"
	_obj=
	set -- $args
	while true; do
		case "$1" in
		-h)
			revert-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-a)
			_full_pot="YES"
			shift
			;;
		-p)
			if [ -z "$_obj" ]; then
				_obj="pot"
				_objname="$2"
			else
				_error "-p|-f are exclusive"
				revert-help
				${EXIT} 1
			fi
			shift 2
			;;
		-f)
			if [ -z "$_obj" ]; then
				_obj="fscomp"
				_objname="$2"
			else
				_error "-p|-f are exclusive"
				revert-help
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
	if [ -z "$_obj" ]; then
		_error "one of -p|-f has to be used"
		revert-help
		$EXIT 1
	fi
	if [ -z "$_objname" ]; then
		_error "-p|-f options need an argument"
		revert-help
		${EXIT} 1
	fi
	case $_obj in
	"pot")
		if ! _is_pot $_objname ; then
			_error "$_objname is not a pot!"
			revert-help
			${EXIT} 1
		fi
		if _is_pot_running $_objname ; then
			_error "The pot $_objname is still running. Revert is possible only for stopped pots"
			${EXIT} 1
		fi
		if ! _is_uid0 ; then
			${EXIT} 1
		fi
		if [ "$_full_pot" = "YES" ]; then
			_pot_zfs_rollback_full $_objname
		else
			_pot_zfs_rollback $_objname
		fi
		;;
	"fscomp")
		if ! _zfs_exist ${POT_ZFS_ROOT}/fscomp/$_objname ${POT_FS_ROOT}/fscomp/$_objname ; then
			_error "$_objname is not a valid fscomp"
			revert-help
			${EXIT} 1
		fi
		if [ "$_full_pot" = "YES" ]; then
			_info "-a option is incompatible with -f. Ignored"
		fi
		if ! _is_uid0 ; then
			${EXIT} 1
		fi
		_fscomp_zfs_rollback $_objname
		;;
	esac
}
