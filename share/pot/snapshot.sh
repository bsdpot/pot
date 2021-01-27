#!/bin/sh
:

# shellcheck disable=SC2039
snapshot-help()
{
	echo "pot snapshot [-h][-v][-a] [-p potname|-f fscomp]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -r replace the oldest available snapshot with the new one (not compatible with -a)'
	echo '  -p potname : the pot target of the snapshot'
	echo '  -f fscomp : the fs component target of the snapshot'
}

# shellcheck disable=SC2039
pot-snapshot()
{
	# shellcheck disable=SC2039
	local _full_pot _obj _objname
	_full_pot="NO"
	_obj=""
	_objname=
	_replace=
	OPTIND=1
	while getopts "hvp:f:r" _o ; do
		case "$_o" in
		h)
			snapshot-help
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		r)
			_replace="YES"
			;;
		p)
			if [ -z "$_obj" ]; then
				_obj="pot"
				_objname="$OPTARG"
			else
				_error "-p|-f are exclusive"
				snapshot-help
				return 1
			fi
			;;
		f)
			if [ -z "$_obj" ]; then
				_obj="fscomp"
				_objname="$OPTARG"
			else
				_error "-p|-f are exclusive"
				snapshot-help
				return 1
			fi
			;;
		*)
			snapshot-help
			return 1
			;;
		esac
	done
	if [ -z "$_obj" ]; then
		_error "one of -p|-f has to be used"
		snapshot-help
		return 1
	fi
	if [ -z "$_objname" ]; then
		_error "-p|-f options need an argument"
		snapshot-help
		return 1
	fi
	case $_obj in
	"pot")
		if ! _is_pot "$_objname" ; then
			_error "$_objname is not a pot!"
			snapshot-help
			return 1
		fi
		if _is_pot_running "$_objname" ; then
			_error "The pot $_objname is still running. Snapshot is possible only for stopped pots"
			return 1
		fi
		if ! _is_uid0 ; then
			return 1
		fi

		if [ "$_full_pot" = "YES" ]; then
			_pot_zfs_snap_full "$_objname"
		else
			if [ "$_replace" = "YES" ]; then
				_remove_oldest_pot_snap "$_objname"
			fi
			_pot_zfs_snap "$_objname"
		fi
		;;
	"fscomp")
		if ! _zfs_exist "${POT_ZFS_ROOT}/fscomp/$_objname" "${POT_FS_ROOT}/fscomp/$_objname" ; then
			_error "$_objname is not a valid fscomp"
			snapshot-help
			return 1
		fi
		if ! _is_uid0 ; then
			return 1
		fi
		if [ "$_replace" = "YES" ]; then
			_remove_oldest_fscomp_snap "$_objname"
		fi
		_fscomp_zfs_snap "$_objname"
		;;
	esac
	return 0
}
