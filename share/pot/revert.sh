#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

revert-help()
{
	echo "pot revert [-hva] -p potname|-f fscomp"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p potname : the pot target of the revert'
	echo '  -f fscomp : the fs component target of the revert'
}

# $1 pot name
_pot_zfs_rollback()
{
	local _pname _pdset _snap
	_pname=$1
	_pdset=${POT_ZFS_ROOT}/jails/$_pname
	for _dset in $( zfs list -o name -H -r "$_pdset" | sort -r | tr '\n' ' ') ; do
		_snap="$( _zfs_last_snap "$_dset")"
		if [ -z "$_snap" ]; then
			_info "$_dset has not snapshot - no possible rollback"
			continue
		fi
		zfs rollback "$_dset"@"$_snap"
	done
}

_fscomp_zfs_rollback()
{
	local _fscomp _fdset _snap
	_fscomp=$1
	_fdset=${POT_ZFS_ROOT}/fscomp/$_fscomp
	for _dset in $( zfs list -o name -H -r "$_fdset" | sort -r | tr '\n' ' ') ; do
		_snap="$( _zfs_last_snap "$_dset")"
		if [ -z "$_snap" ]; then
			_info "$_dset has not snapshot - no possible rollback"
			continue
		fi
		zfs rollback "$_dset@$_snap"
	done
}

pot-revert()
{
	local _obj
	_obj=
	OPTIND=1
	while getopts "hvp:f:" _o ; do
		case "$_o" in
		h)
			revert-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			if [ -z "$_obj" ]; then
				_obj="pot"
				_objname="$OPTARG"
			else
				_error "-p|-f are exclusive"
				revert-help
				${EXIT} 1
			fi
			;;
		f)
			if [ -z "$_obj" ]; then
				_obj="fscomp"
				_objname="$OPTARG"
			else
				_error "-p|-f are exclusive"
				revert-help
				${EXIT} 1
			fi
			;;
		?)
			revert-help
			${EXIT} 1
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
		if ! _is_pot "$_objname" ; then
			_error "$_objname is not a pot!"
			revert-help
			${EXIT} 1
		fi
		if _is_pot_running "$_objname" ; then
			_error "The pot $_objname is still running. Revert is possible only for stopped pots"
			${EXIT} 1
		fi
		if ! _is_uid0 ; then
			${EXIT} 1
		fi
		_pot_zfs_rollback "$_objname"
		;;
	"fscomp")
		if ! _zfs_exist "${POT_ZFS_ROOT}/fscomp/$_objname" "${POT_FS_ROOT}/fscomp/$_objname" ; then
			_error "$_objname is not a valid fscomp"
			revert-help
			${EXIT} 1
		fi
		if ! _is_uid0 ; then
			${EXIT} 1
		fi
		_fscomp_zfs_rollback "$_objname"
		;;
	esac
}
