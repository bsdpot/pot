#!/bin/sh

destroy-help()
{
	echo "pot destroy [-hvfr] [-p potname|-b basename]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f force the stop and destroy'
	echo '  -p potname : the pot name (mandatory)'
	echo '  -b basename : the base name (mandatory)'
	echo '  -r : destroy recursively all pots based on this base/pot'
}

# $1 zfs dataset
_zfs_dataset_destroy()
{
	local _dset _zopt
	_dset=$1
	_zopt=
	if _is_verbose ; then
		_zopt="-v"
	fi
	zfs destroy -r $_zopt $_dset
}

# $1 pot name
# $2 force parameter
_pot_zfs_destroy()
{
	local _pname _zopt _jdset _force
	_pname=$1
	_force=$2
	_jdset=${POT_ZFS_ROOT}/jails/$_pname
	if ! _zfs_is_dataset $_jdset ; then
		_error "$_pname not found"
		return 1 # false
	fi
	if _is_pot_running $_pname ; then
		if [ "$_force" = "YES" ]; then
			pot-cmd stop $_pname
		else
			_error "pot $_pname is running"
			exit 1
		fi
	fi
	_zfs_dataset_destroy $_jdset
}

# $1 base name
_base_zfs_destroy()
{
	local _bname _bdset
	_bname=$1
	_bdset=${POT_ZFS_ROOT}/bases/$_bname
	_zfs_dataset_destroy $_bdset
}

pot-destroy()
{
	local _pname _bname _force _recursive
	local _pots
	_pname=
	_bname=
	_force=
	_recursive="NO"
	args=$(getopt hvrfp:b: $*)
	if [ $? -ne 0 ]; then
		destroy-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			destroy-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-f)
			_force="YES"
			shift
			;;
		-r)
			_recursive="YES"
			shift
			;;
		-p)
			_pname=$2
			shift 2
			;;
		-b)
			_bname=$2
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done

	if [ -z "$_pname" -a -z "$_bname" ]; then
		_error "-b or -p are missing"
		destroy-help
		exit 1
	fi
	if [ -n "$_pname" -a -n "$_bname" ]; then
		_error "-b or -p cannot be used at the same time"
		destroy-help
		exit 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if [ -n "$_bname" ]; then
		# check the base
		if ! _zfs_is_dataset "${POT_ZFS_ROOT}/bases/$_bname" ; then
			_error "$_bname is not a base"
			exit 1
		fi
		if [ "$_recursive" = "YES" ]; then
			for _lvl in 2 1 0 ; do
				_pots=$( ls -d ${POT_FS_ROOT}/jails/*/ 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
				for _p in $_pots ; do
					if [ "$( _get_conf_var $_p pot.level )" = "$_lvl" ]; then
						if [ "$( _get_conf_var $_p pot.base )" = "$_bname" ]; then
							_debug "Destroying recursively pot $_p based on $_bname"
							_pot_zfs_destroy $_p $_force
						fi
					fi
				done
			done
		else
			# if present, destroy the lvl 0 pot
			_pname="base-$(echo $_bname | sed 's/\./_/')"
			_debug "Destroying lvl 0 pot $_pname"
			_pot_zfs_destroy $_pname $_force
		fi
		_debug "Destroying base $_bname"
		_base_zfs_destroy $_bname
		return 0
	fi
	if [ -n "$_pname" ]; then
		if [ "$( _get_conf_var $_pname pot.level )" = "0" ]; then
			_error "The pot $_pname has level 0. Please destroy the related base insted"
			return 1
		fi
		if [ "$_recursive" = "YES" ]; then
			if [ "$( _get_conf_var $_pname pot.level )" = "2" ]; then
				_debug "$_pname has level 2. No recursive destroy possible"
			else
				_pots=$( ls -d ${POT_FS_ROOT}/jails/*/ 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
				for _p in $_pots ; do
					if [ "$( _get_conf_var $_p pot.potbase )" = "$_pname" ]; then
						_debug "Destroying recursively pot $_p based on $_pname"
						_pot_zfs_destroy $_p $_force
					fi
				done
			fi
		fi
		_debug "Destroying pot $_pname"
		_pot_zfs_destroy $_pname $_force
	fi
}
