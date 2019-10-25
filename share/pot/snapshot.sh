#!/bin/sh
:

# shellcheck disable=SC2039
snapshot-help()
{
	echo "pot snapshot [-h][-v][-a] [-p potname|-f fscomp]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -r replace the oldest available snapshot with the new one (not compatible with -a)'
	echo '  -a all components of a pot [DEPRECATED]'
	echo '  -p potname : the pot target of the snapshot'
	echo '  -f fscomp : the fs component target of the snapshot'
}

# shellcheck disable=SC2039
pot-snapshot()
{
	local _full_pot _obj _objname _snapname
	_full_pot="NO"
	_obj=""
	_objname=
	_snapname=""
	_replace=
	OPTIND=1
	while getopts "hvap:f:n:r" _o ; do
		case "$_o" in
		h)
			snapshot-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		r)
			_replace="YES"
			;;
		a)
			_full_pot="YES"
			echo "###########################"
			echo "# option -a is deprecated #"
			echo "###########################"
			;;
		p)
			if [ -z "$_obj" ]; then
				_obj="pot"
				_objname="$OPTARG"
			else
				_error "-p|-f are exclusive"
				snapshot-help
				${EXIT} 1
			fi
			;;
		f)
			if [ -z "$_obj" ]; then
				_obj="fscomp"
				_objname="$OPTARG"
			else
				_error "-p|-f are exclusive"
				snapshot-help
				${EXIT} 1
			fi
			;;
		n)
			_snapname="$OPTARG"
			echo "###########################"
			echo "# option -n is deprecated #"
			echo "###########################"
			;;
		*)
			snapshot-help
			${EXIT} 1
			;;
		esac
	done
	if [ -z "$_obj" ]; then
		_error "one of -p|-f has to be used"
		snapshot-help
		$EXIT 1
	fi
	if [ -z "$_objname" ]; then
		_error "-p|-f options need an argument"
		snapshot-help
		${EXIT} 1
	fi
	case $_obj in
	"pot")
		if [ -n "$_snapname" ]; then
			_error "Option -n usable only with fscomp"
			${EXIT} 1
		fi
		if ! _is_pot "$_objname" ; then
			_error "$_objname is not a pot!"
			snapshot-help
			${EXIT} 1
		fi
		if _is_pot_running "$_objname" ; then
			_error "The pot $_objname is still running. Snapshot is possible only for stopped pots"
			${EXIT} 1
		fi
		if ! _is_uid0 ; then
			${EXIT} 1
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
			${EXIT} 1
		fi
		if [ "$_full_pot" = "YES" ]; then
			_info "-a option is incompatible with -f. Ignored"
		fi
		if ! _is_uid0 ; then
			${EXIT} 1
		fi
		if [ "$_replace" = "YES" ]; then
			_remove_oldest_fscomp_snap "$_objname"
		fi
		_fscomp_zfs_snap "$_objname" "$_snapname"
		;;
	esac
	return 0
}
