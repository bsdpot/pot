#!/bin/sh
:

# shellcheck disable=SC2039
add-fscomp-help()
{
	echo "pot add-fscomp [-h][-v] -p pot -m mnt -f fscomp | -d directory"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f fscomp : the fs component to be added'
	echo '  -e : the fscomp is an external dataset'
	echo '  -d directory : the directory that has to be mounted in the pot (absolute pathname)'
	echo '  -p pot : the working pot'
	echo '  -m mnt : the mount point inside the pot'
	echo '  -w : '"don't use nullfs, but change the zfs mountpoint (potentially DANGEROUS)"
	echo '  -r : mount the fscomp in read-only'
}

# $1 pot
# $2 fscomp
# $3 mount point
# $4 extern dataset
# $5 option
_fscomp_validation()
{
	# shellcheck disable=SC2039
	local _pname _fscomp _mnt_p _ext _opt
	_pname="$1"
	_fscomp="$2"
	_mnt_p="${3#/}"
	_ext="$4"
	_opt="$5"
	_conf="${POT_FS_ROOT}/jails/${_pname}/conf/fscomp.conf"
	# Here I should check the existing configuration, to see if the new fscomp is not colliding
	## check if the mount_point is already used
	if [ $(grep -c " $POT_FS_ROOT/jails/$_pname/m/$_mnt_p$" "$_conf") -ne 0 ]; then
		_error "the mount point $_mnt_p is already in use"
		return 1
	fi
	return 0
}

# $1 pot
# $2 mount point
_mountpoint_validation()
{
	# shellcheck disable=SC2039
	local _pname _mnt_p _mpdir _mounted
	_pname="$1"
	_mnt_p="$2"
	_mpdir=$POT_FS_ROOT/jails/$_pname/m
	_mounted=false # false
	if ! _is_pot_running "$_pname" ; then
		_mounted=true # true
		if ! _pot_mount "$_pname" ; then
			_error "Pot $_pname failed to mount"
			return 1 # false
		fi
	fi
	# if the mountpoint doesn't exist, make it
	if [ ! -d "$_mpdir/$_mnt_p" ]; then
		if ! mkdir -p "$_mpdir/$_mnt_p" ; then
			if eval $_mounted ; then
				_pot_umount "$_pname"
			fi
			return 1 # false
		fi
	fi
	if eval $_mounted ; then
		_pot_umount "$_pname"
	fi
	return 0 # true
}

# $1 fscomp
# $2 pot
# $3 mount point
# $4 external/NO
# $5 mount option (zfs-remount, ro)
_add_f_to_p()
{
	# shellcheck disable=SC2039
	local _fscomp _pname _mnt_p _pdir _ext _opt _zfscomp _node
	_fscomp="$1"
	_pname="$2"
	# Removing the trailing /
	_mnt_p="${3#/}"
	_ext="${4}"
	_opt="${5}"
	_pdir=$POT_FS_ROOT/jails/$_pname
	if [ "$_ext" = "external" ]; then
		_zfscomp="$_fscomp"
	else
		_zfscomp="$POT_ZFS_ROOT/fscomp/$_fscomp"
	fi
	_debug "add fscomp:$_zfscomp mnt_p:$_pdir/m/$_mnt_p opt:$_opt"
	if [ -z "$_opt" ]; then
		${ECHO} "$_zfscomp $_pdir/m/$_mnt_p" >> "$_pdir/conf/fscomp.conf"
	else
		${ECHO} "$_zfscomp $_pdir/m/$_mnt_p $_opt" >> "$_pdir/conf/fscomp.conf"
	fi
	if _is_pot_running "$_pname" ; then
		if [ "$_opt" = "zfs-remount" ]; then
			zfs set mountpoint="$_pdir/m/$_mnt_p" "$_zfscomp"
		else
			_node=$( _get_zfs_mountpoint "$_zfscomp" )
			if ! mount_nullfs -o "${_opt:-rw}" "$_node" "$_pdir/m/$_mnt_p" ; then
				_error "Error mounting $_node on $_pname"
			else
				_debug "Mounted $_node on $_pname"
			fi
		fi
	fi
}

# $1 directory
# $2 pot
# $3 mount point
# $4 mount option (zfs-remount, ro)
_add_d_to_p()
{
	# shellcheck disable=SC2039
	local _dir _pname _mnt_p _pdir _opt
	_dir="$1"
	_pname="$2"
	# Removing the trailing /
	_mnt_p="${3#/}"
	_opt="${4}"
	_pdir=$POT_FS_ROOT/jails/$_pname
	_debug "add directory:$_dir mnt_p:$_pdir/m/$_mnt_p opt:$_opt"
	if [ -z "$_opt" ]; then
		${ECHO} "$_dir $_pdir/m/$_mnt_p" >> "$_pdir/conf/fscomp.conf"
	else
		${ECHO} "$_dir $_pdir/m/$_mnt_p $_opt" >> "$_pdir/conf/fscomp.conf"
	fi
	if _is_pot_running "$_pname" ; then
		if ! mount_nullfs -o "${_opt:-rw}" "$_dir" "$_pdir/m/$_mnt_p" ; then
			_error "Error mounting $_dir on $_pname"
		else
			_debug "Mounted $_dir on $_pname"
		fi
	fi
}

# shellcheck disable=SC2039
pot-add-fscomp()
{
	local _pname _fscomp _mnt_p _ext _remount _readonly _opt _dir
	OPTIND=1
	_fscomp=
	_pname=
	_mnt_p=
	_ext="NO"
	_remount="NO"
	_readonly="NO"
	_opt=
	_dir=
	while getopts "hvf:p:m:ewrd:" _o ; do
		case "$_o" in
		h)
			add-fscomp-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		f)
			_fscomp="$OPTARG"
			;;
		d)
			_dir="$OPTARG"
			;;
		e)
			_ext="external"
			;;
		p)
			_pname="$OPTARG"
			;;
		m)
			_mnt_p="$OPTARG"
			;;
		w)
			_remount="YES"
			;;
		r)
			_readonly="YES"
			;;
		*)
			add-fscomp-help
			${EXIT} 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		add-fscomp-help
		${EXIT} 1
	fi
	if [ -z "$_fscomp" ] && [ -z "$_dir" ]; then
		_error "A fs component or a directory are mandatory"
		add-fscomp-help
		${EXIT} 1
	fi
	if [ -n "$_fscomp" ] && [ -n "$_dir" ]; then
		_error "-f and -d options are mutually exclusive"
		add-fscomp-help
		${EXIT} 1
	fi
	if [ -z "$_mnt_p" ]; then
		_error "A mount point is mandatory"
		add-fscomp-help
		${EXIT} 1
	fi
	if ! _is_absolute_path "$_mnt_p" ; then
		_error "The mount point has to be an absolute pathname"
		${EXIT} 1
	fi
	if [ "${_mnt_p}" = "/" ]; then
		_error "/ is not a valid mount point"
		${EXIT} 1
	fi

	if [ "$_remount" = "YES" ]; then
		if [ -n "$_dir" ]; then
			_error "Remount cannot be used with directories, but with fscomp only"
			add-fscomp-help
			${EXIT} 1
		fi
		_opt="zfs-remount"
		if [ "$_ext" = "external" ]; then
			_error "External fscomp cannot be remounted: -e and -w option are mututally exclusive"
			add-fscomp-help
			${EXIT} 1
		fi
		if [ "$_readonly" = "YES" ]; then
			_info "Readonly and remount are mutually exclusive: readonly considered, remount ignored"
			_remount="NO"
			_opt="ro"
		fi
	else
		if [ "$_readonly" = "YES" ]; then
			_opt="ro"
		fi
	fi
	# TODO: chech that the external fscomp is not already part of the pot
	if [ -n "$_fscomp" ]; then
		if [ "$_ext" = "external" ]; then
			if ! _zfs_dataset_valid "$_fscomp" ; then
				_error "fscomp $_fscomp is not valid"
				add-fscomp-help
				${EXIT} 1
			fi
		else
			if ! _zfs_dataset_valid "$POT_ZFS_ROOT/fscomp/$_fscomp" ; then
				_error "fscomp $_fscomp is not valid"
				add-fscomp-help
				${EXIT} 1
			fi
		fi
	fi
	# TODO: check that the directory is not in the pot
	# TODO: check that the directory doesn't conflict with anything already mounted
	if [ -n "$_dir" ]; then
		if [ ! -d "$_dir" ]; then
			_error "$_dir is not a directory"
			add-fscomp-help
			${EXIT} 1
		fi
		if ! _is_absolute_path "$_dir" ; then
			_error "$_fscomp has to be an absolute pathname (start with /)"
			add-fscomp-help
			${EXIT} 1
		fi
		if [ "$_ext" = "external" ]; then
			_info "-e option is ignored with -d"
		fi
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		add-fscomp-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if [ -n "$_fscomp" ] && ! _fscomp_validation "$_pname" "$_fscomp" "$_mnt_p" $_ext $_opt ; then
		${EXIT} 1
	fi
	if ! _mountpoint_validation "$_pname" "$_mnt_p" ; then
		_error "The mountpoint is not valid!"
		${EXIT} 1
	fi
	if [ -n "$_fscomp" ]; then
		_add_f_to_p "$_fscomp" "$_pname" "$_mnt_p" $_ext $_opt
	else
		_add_d_to_p "$_dir" "$_pname" "$_mnt_p" $_opt
	fi
}
