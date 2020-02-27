#!/bin/sh
:

# shellcheck disable=SC2039
destroy-help()
{
	echo "pot destroy [-hvFr] [-p potname|-b basename|-f fscomp|-B bridge]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quiet'
	echo '  -F force the stop and destroy'
	echo '  -p potname : the pot name (mandatory)'
	echo '  -b basename : the base name (mandatory)'
	echo '  -f fscomp : the fscomp name (mandatory)'
	echo '  -B bridge-name : the name of the bridge to be deleted (mandatory)'
	echo '  -r : destroy recursively all pots based on this base/pot'
}

# $1 zfs dataset
_zfs_dataset_destroy()
{
	# shellcheck disable=SC2039
	local _dset _zopt
	_dset=$1
	_zopt=
	if _is_verbose ; then
		_zopt="-v"
	fi
	zfs destroy -f -r $_zopt "$_dset"
	return $?
}

# $1 pot name
# $2 force parameter
_pot_zfs_destroy()
{
	# shellcheck disable=SC2039
	local _pname _zopt _jdset _force
	_pname=$1
	_force=$2
	_jdset=${POT_ZFS_ROOT}/jails/$_pname
	if ! _zfs_dataset_valid "$_jdset" ; then
		## if a directory is found, just remove if
		if [ -d "${_POT_FS_ROOT}/jails/$_pname" ]; then
			_debug "Dataset of $_pname not found, but removing the directory anyway"
			rm -rf "${_POT_FS_ROOT}/jails/$_pname"
			return 0 # true
		fi
		_error "$_pname not found"
		return 1 # false
	fi
	if _is_pot_running "$_pname" ; then
		if [ "$_force" = "YES" ]; then
			pot-cmd stop "$_pname"
		else
			_error "pot $_pname is running"
			${EXIT} 1
		fi
	fi
	if ! _zfs_dataset_destroy "$_jdset" ; then
		_error "zfs failed to destroy the dataset $_jdset"
		return 1 # false
	fi
	rm -f /usr/local/etc/syslog.d/"${_pname}".conf /usr/local/etc/newsyslog.conf.d/"${_pname}".conf
	return $?
}

# $1 base name
_base_zfs_destroy()
{
	# shellcheck disable=SC2039
	local _bname _bdset
	_bname=$1
	_bdset=${POT_ZFS_ROOT}/bases/$_bname
	_zfs_dataset_destroy "$_bdset"
	return $?
}

# $1 base name
_fscomp_zfs_destroy()
{
	# shellcheck disable=SC2039
	local _fname _fdset
	_fname=$1
	_fdset=${POT_ZFS_ROOT}/fscomp/$_fname
	_zfs_dataset_destroy "$_fdset"
	return $?
}

pot-destroy()
{
	# shellcheck disable=SC2039
	local _pname _bname _fname _force _recursive _pots _depPot _bridge_name
	_pname=
	_bname=
	_fname=
	_bridge_name=
	_force=
	_recursive="NO"
	OPTIND=1
	while getopts "hvrf:p:b:FB:q" _o ; do
		case "$_o" in
		h)
			destroy-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_POT_VERBOSITY=0
			;;
		F)
			_force="YES"
			;;
		r)
			_recursive="YES"
			;;
		p)
			_pname=$OPTARG
			;;
		b)
			_bname=$OPTARG
			;;
		f)
			_fname=$OPTARG
			;;
		B)
			_bridge_name=$OPTARG
			;;
		*)
			destroy-help
			${EXIT} 1
			;;
		esac
	done

	if [ -z "$_pname" ] && [ -z "$_bname" ] && [ -z "$_fname" ] && [ -z "$_bridge_name" ]; then
		_error "-b or -p or -f or -B are missing"
		destroy-help
		${EXIT} 1
	fi
	if [ -n "$_pname" ]; then
		if [ -n "$_bname" ] || [ -n "$_fname" ] || [ -n "$_bridge_name" ] ; then
			_error "-b, -p, -f and -B cannot be used at the same time"
			destroy-help
			${EXIT} 1
		fi
	fi
	if [ -n "$_bname" ]; then
		if [ -n "$_fname" ] || [ -n "$_bridge_name" ] ; then
			_error "-b, -p, -f and -B cannot be used at the same time"
			destroy-help
			${EXIT} 1
		fi
	fi
	if [ -n "$_fname" ] && [ -n "$_bridge_name" ] ; then
		_error "-b, -p, -f and -B cannot be used at the same time"
		destroy-help
		${EXIT} 1
	fi

	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if [ -n "$_bridge_name" ]; then
		if [ "$_force" = "YES" ] || [ "$_recursive" = "YES" ] ; then
			_info "Destroy bridge will ignore force and recursive"
		fi
		if ! _is_bridge "$_bridge_name" ; then
			_error "$_bridge_name is not a valid bridge name"
			${EXIT} 1
		fi
		_pots=$( _get_pot_list )
		for _p in $_pots ; do
			_bridge="$( _get_conf_var "$_p" bridge)"
			if [ "$_bridge" = "$_bridge_name" ]; then
				_error "the bridge $_bridge_name is still used by the pot $_p - unable to delete"
				${EXIT} 1
			fi
		done
		_info "Destroying bridge $_bridge_name"
		rm -f "${POT_FS_ROOT}/bridges/$_bridge_name"
		${EXIT} $?
	fi

	if [ -n "$_fname" ]; then
		if [ "$_force" = "YES" ] || [ "$_recursive" = "YES" ] ; then
			_info "Destroy fscomps will ignore force and recursive"
		fi
		if ! _zfs_dataset_valid "${POT_ZFS_ROOT}/fscomp/$_fname" ; then
			_error "$_fname is not a fscomp"
			${EXIT} 1
		fi
		_info "Destroying fscomp $_fname"
		_fscomp_zfs_destroy "$_fname"
		${EXIT} $?
	fi

	if [ -n "$_bname" ]; then
		# check the base
		if ! _zfs_dataset_valid "${POT_ZFS_ROOT}/bases/$_bname" ; then
			_error "$_bname is not a base"
			${EXIT} 1
		fi
		if [ "$_recursive" = "YES" ]; then
			for _lvl in 2 1 0 ; do
				_pots=$( _get_pot_list )
				for _p in $_pots ; do
					if [ "$( _get_conf_var "$_p" pot.level )" = "$_lvl" ]; then
						if [ "$( _get_conf_var "$_p" pot.base )" = "$_bname" ]; then
							_info "Destroying recursively pot $_p based on $_bname"
							_pot_zfs_destroy "$_p" $_force
						fi
					fi
				done
			done
		else
			# if present, destroy the lvl 0 pot
			_pname="base-$(echo "$_bname" | sed 's/\./_/')"
			_debug "Destroying lvl 0 pot $_pname"
			_pot_zfs_destroy "$_pname" "$_force"
		fi
		_info "Destroying base $_bname"
		_base_zfs_destroy "$_bname"
		${EXIT} $?
	fi
	if [ -n "$_pname" ]; then
		if ! _is_pot "$_pname" quiet ; then
			if _zfs_dataset_valid "${POT_ZFS_ROOT}/jails/$_pname" && [ "$_force" = "YES" ] ; then
				# we can destroy forcibly
				if ! _pot_zfs_destroy "$_pname" "$_force" ; then
					_error "Failed to destroy pot $_pname"
					${EXIT} 1
				else
					_info "Forcibly destroyed pot $_pname"
					${EXIT} 0
				fi
			else
				_is_pot "$_pname"
				_error "pot $_pname not found or corrupted. Try to use the -F flag"
				${EXIT} 1 # false
			fi
		fi
		if [ "$( _get_conf_var "$_pname" pot.level )" = "0" ]; then
			# if single we can remove a level 0 pot
			if [ "$( _get_conf_var "$_pname" pot.type )" = "single" ]; then
				_pots=$( _get_pot_list )
				for _p in $_pots ; do
					if [ "$( _get_conf_var "$_p" pot.potbase )" = "$_pname" ]; then
						if [ "$_recursive" = "YES" ]; then
							_debug "Destroying recursively pot $_p based on $_pname"
							_pot_zfs_destroy "$_p" $_force
						else
							_error "$_pname is used at least by another pot ($_p) - use option -r to destroy it recursively"
							${EXIT} 1
						fi
					fi
				done
			else
				_error "The pot $_pname has level 0. Please destroy the related base insted"
				${EXIT} 1
			fi
		fi
		if [ "$( _get_conf_var "$_pname" pot.level )" = "1" ]; then
			_pots=$( _get_pot_list )
			for _p in $_pots ; do
				if [ "$( _get_conf_var "$_p" pot.potbase )" = "$_pname" ]; then
					if [ "$_recursive" = "YES" ]; then
						_debug "Destroying recursively pot $_p based on $_pname"
						_pot_zfs_destroy "$_p" $_force
					else
						_error "$_pname is used at least by one level 2 pot - use option -r to destroy it recursively"
						${EXIT} 1
					fi
				fi
			done
		fi
		if [ "$( _get_conf_var "$_pname" pot.level )" = "2" -a "$_recursive" = "YES" ]; then
			_debug "$_pname has level 2. No recursive destroy possible (ignored)"
		fi

		## dependency detection
		_pots=$( _get_pot_list )
		for _p in $_pots ; do
			_depPot="$( _get_conf_var "$_p" pot.depend )"
			if [ -z "$_depPot" ]; then
				continue
			fi
			for _d in $_depPot ; do
				if [ "$_d" = "$_pname" ]; then
					_info "pot $_p is losing his dependency $_pname"
					continue
				fi
			done
		done
		
		_info "Destroying pot $_pname"
		if ! _pot_zfs_destroy "$_pname" $_force ; then
			_error "$_pname destruction failed"
			${EXIT} 1
		fi
	fi
}
