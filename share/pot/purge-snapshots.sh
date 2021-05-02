#!/bin/sh
:

# shellcheck disable=SC3033
purge-snapshots-help()
{
	echo "pot purge-snapshots [-h][-v][-a] [-p potname|-f fscomp]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p potname : the pot target of the purge-snapshots'
	echo '  -f fscomp : the fs component target of the purge-snapshots'
	echo '  -a : remove all snapshot, the last one included'
}

# $1 zfs dataset
_zfs_old_snapshots()
{
	# shellcheck disable=SC2039
	local _dset
	_output="$(zfs list -d 1 -H -t snap "$_dset" | sort -r | sed '1d' | sort | cut -d'@' -f2 | cut -f1 )"
	echo "$_output"
}

# $1 zfs dataset
_zfs_all_snapshots()
{
	# shellcheck disable=SC2039
	local _dset
	_output="$(zfs list -d 1 -H -t snap "$_dset" | sort | cut -d'@' -f2 | cut -f1 )"
	echo "$_output"
}

_purge_dset()
{
	# shellcheck disable=SC2039
	local _dset _snaps _all_snap
	_dset=$1
	_all_snap=${2:-"NO"}
	if [ "$_all_snap" = "YES" ]; then
		_snaps="$(_zfs_all_snapshots "$_dset")"
	else
		_snaps="$(_zfs_old_snapshots "$_dset")"
	fi
	if [ -z "$_snaps" ]; then
		return
	fi
	for _s in $_snaps ; do
		zfs destroy -r "${_dset}@${_s}"
	done
}

# shellcheck disable=SC3033
pot-purge-snapshots()
{
	local _obj _objname _all_snap
	_all_snap="NO"
	_obj=""
	OPTIND=1
	while getopts "hvp:f:a" _o ; do
		case "$_o" in
		h)
			purge-snapshots-help
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
				purge-snapshots-help
				${EXIT} 1
			fi
			;;
		f)
			if [ -z "$_obj" ]; then
				_obj="fscomp"
				_objname="$OPTARG"
			else
				_error "-p|-f are exclusive"
				purge-snapshots-help
				${EXIT} 1
			fi
			;;
		a)
			_all_snap="YES"
			;;
		*)
			purge-snapshots-help
			${EXIT} 1
			;;
		esac
	done
	if [ -z "$_obj" ]; then
		_error "one of -p|-f has to be used"
		purge-snapshots-help
		return 1
	fi
	if [ -z "$_objname" ]; then
		_error "-p|-f options need an argument"
		purge-snapshots-help
		return 1
	fi
	case $_obj in
	"pot")
		if ! _is_pot "$_objname" ; then
			_error "$_objname is not a pot!"
			purge-snapshots-help
			return 1
		fi
		_purge_dset "${POT_ZFS_ROOT}/jails/$_objname" "$_all_snap"
		;;
	"fscomp")
		if ! _zfs_exist "${POT_ZFS_ROOT}/fscomp/$_objname" "${POT_FS_ROOT}/fscomp/$_objname" ; then
			_error "$_objname is not a valid fscomp"
			purge-snapshots-help
			return 1
		fi
		if ! _is_uid0 ; then
			return 1
		fi
		_purge_dset "${POT_ZFS_ROOT}/fscomp/$_objname" "$_all_snap"
		;;
	esac
	return 0
}
