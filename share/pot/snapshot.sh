#!/bin/sh

# supported releases
snapshot-help()
{
	echo "pot snapshot [-h][-v][-a] [-p potname|-f fscomp]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -a all components of a pot'
	echo '  -p potname : the pot target of the snapshot'
	echo '  -f fscomp : the fs component target of the snapshot'
}

pot-snapshot()
{
	local _full_pot _obj _objname
	args=$(getopt hvap:f: $*)
	if [ $? -ne 0 ]; then
		snapshot-help
		${EXIT} 1
	fi
	_full_pot="NO"
	_obj=""
	set -- $args
	while true; do
		case "$1" in
		-h)
			snapshot-help
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
				snapshot-help
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
				snapshot-help
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
		if ! _is_pot $_objname ; then
			_error "$_objname is not a pot!"
			snapshot-help
			${EXIT} 1
		fi
		if _is_pot_running $_objname ; then
			_error "The pot $_objname is still running. Snapshot is possible only for stopped pots"
			${EXIT} 1
		fi
		if [ "$_full_pot" = "YES" ]; then
			_pot_zfs_snap_full $_objname
		else
			_pot_zfs_snap $_objname
		fi
		;;
	"fscomp")
		if ! _zfs_exist ${POT_ZFS_ROOT}/fscomp/$_objname ${POT_FS_ROOT}/fscomp/$_objname ; then
			_error "$_objname is not a valid fscomp"
			snapshot-help
			${EXIT} 1
		fi
		if [ "$_full_pot" = "YES" ]; then
			_info "-a option is incompatible with -f. Ignored"
		fi
		_fscomp_zfs_snap $_objname
		;;
	esac
	return 0
}
