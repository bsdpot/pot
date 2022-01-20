#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

mount-in-help()
{
	echo "pot mount-in [-hvwr] -p pot -m mnt -f fscomp | -d directory | -z dataset"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -f fscomp : the fs component to be mounted'
	echo '  -z zfs dataset : the zfs dataset to be mounted'
	echo '  -d directory : the directory that has to be mounted in the pot (absolute pathname)'
	echo '  -m mnt : the mount point inside the pot'
	echo '  -w : '"don't use nullfs, but change the zfs mountpoint [usable only with -z and -f](potentially DANGEROUS)"
	echo '  -r : mount in read-only'
}

# $1 pot
# $2 mount point
_is_mountpoint_used()
{
	local _pname _mnt_p _proot
	_pname="$1"
	_mnt_p="${2#/}"
	_conf=$POT_FS_ROOT/jails/$_pname/conf/fscomp.conf
	_proot=$POT_FS_ROOT/jails/$_pname/m
	if grep -q " $_proot/$_mnt_p$" "$_conf" ||
		grep -q " $_proot/$_mnt_p " "$_conf" ; then
		# mount point already used
		return 0 # true
	fi
	if grep -q "$_proot/$_mnt_p " "$_conf" ; then
		# mountpoint used as source directory ?? wtf
		_error "The mountpoint is already used as source directory mount-in"
		return 0 # true
	fi
	return 1 # false, mountpoint not used
}

# $1 pot
# $2 mount point
_mountpoint_validation()
{
	local _pname _mnt_p _mpdir _mounted _real_mnt
	_pname="$1"
	_mnt_p="$2"
	_mpdir=$POT_FS_ROOT/jails/$_pname/m
	_mounted=false # false
	if _is_mountpoint_used "$_pname" "$_mnt_p" ; then
		_error "The mount point $_mnt_p is already in use"
		return 1 # false
	fi
	if ! _is_pot_running "$_pname" ; then
		_mounted=true # true
		if ! _pot_mount "$_pname" >/dev/null ; then
			_error "Pot $_pname failed to mount"
			return 1 # false
		fi
	fi
	# if the mountpoint doesn't exist, make it
	if [ ! -d "$_mpdir/$_mnt_p" ]; then
		if ! mkdir -p "$_mpdir/$_mnt_p" ; then
			if eval $_mounted ; then
				_pot_umount "$_pname" >/dev/null
			fi
			return 1 # false
		fi
	fi
	_real_mnt=$( chroot "$_mpdir" /bin/realpath "$_mnt_p")
	if eval $_mounted ; then
		_pot_umount "$_pname" >/dev/null
	fi
	echo "$_real_mnt"
	return 0 # true
}

_directory_validation()
{
	local _pname _dir  _proot _conf
	_pname="$1"
	_dir="$2"
	_proot=$POT_FS_ROOT/jails/$_pname
	_conf=$POT_FS_ROOT/jails/$_pname/conf/fscomp.conf
	if [ "$_dir" != "${_dir%"$_proot"}" ]; then
		# dir is inside the pot
		return 1 # false
	fi
	if grep -q "$_dir " "$_conf" ; then
		# the directory is already used
		return 1 # false
	fi
	return 0 # true

}

# $1 zfs dataset
# $2 pot
# $3 mount point
# $4 mount option (zfs-remount, ro)
_mount_dataset()
{
	local _dset _pname _mnt_p _pdir _opt
	_dset="$1"
	_pname="$2"
	# Removing the trailing /
	_mnt_p="${3#/}"
	_opt="${4}"
	_pdir=$POT_FS_ROOT/jails/$_pname
	_debug "mount zfs dataset:$_dset mnt_p:$_pdir/m/$_mnt_p opt:$_opt"
	if [ -z "$_opt" ]; then
		${ECHO} "$_dset $_pdir/m/$_mnt_p" >> "$_pdir/conf/fscomp.conf"
	else
		${ECHO} "$_dset $_pdir/m/$_mnt_p $_opt" >> "$_pdir/conf/fscomp.conf"
	fi
	if _is_pot_running "$_pname" ; then
		if [ "$_opt" = "zfs-remount" ]; then
			zfs set mountpoint="$_pdir/m/$_mnt_p" "$_dset"
		else
			_node=$( _get_zfs_mountpoint "$_dset" )
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
# $4 mount option (ro)
_mount_dir()
{
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

pot-mount-in()
{
	local _pname _fscomp _mnt_p _remount _readonly _opt _dir _real_mnt_p
	OPTIND=1
	_pname=
	_mnt_p=
	_remount="NO"
	_readonly="NO"
	_opt=
	_dir=
	_fscomp=
	_dset=
	logger -t pot -p local0.debug -- "mount-in: $*"
	while getopts "hvf:d:z:p:m:wr" _o ; do
		case "$_o" in
		h)
			mount-in-help
			return 0
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
		z)
			_dset="$OPTARG"
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
			mount-in-help
			return 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		mount-in-help
		return 1
	fi
	if [ -z "$_fscomp" ] && [ -z "$_dir" ] && [ -z "$_dset" ] ; then
		_error "One of -f|-d|-z option has to be used"
		mount-in-help
		return 1
	fi
	if [ -n "$_fscomp" ] && [ -n "$_dir" ]; then
		_error "-f and -d options are mutually exclusive"
		mount-in-help
		return 1
	fi
	if [ -n "$_fscomp" ] && [ -n "$_dset" ]; then
		_error "-f and -z options are mutually exclusive"
		mount-in-help
		return 1
	fi
	if [ -n "$_dir" ] && [ -n "$_dset" ]; then
		_error "-d and -z options are mutually exclusive"
		mount-in-help
		return 1
	fi
	if [ -z "$_mnt_p" ]; then
		_error "A mount point is mandatory"
		mount-in-help
		return 1
	fi
	if _contains_spaces "$_mnt_p" ; then
		_error "The mountpoint cannot contain spaces"
		return 1
	fi
	if ! _is_absolute_path "$_mnt_p" ; then
		_error "The mount point has to be an absolute pathname"
		return 1
	fi
	if [ "${_mnt_p}" = "/" ]; then
		_error "/ is not a valid mount point"
		return 1
	fi

	if [ "$_remount" = "YES" ]; then
		if [ -n "$_dir" ]; then
			_error "Remount cannot be used with directories, but with fscomp only"
			mount-in-help
			return 1
		fi
		_opt="zfs-remount"
		# TODO: investigate
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
	if [ -n "$_fscomp" ]; then
		if ! _is_fscomp "$_fscomp" ; then
			_error "fscomp $_fscomp is not valid"
			mount-in-help
			return 1
		fi
	fi
	if [ -n "$_dset" ]; then
		if ! _zfs_dataset_valid "$_dset" ; then
			_error "dataset $_dset is not valid"
			mount-in-help
			return 1
		fi
	fi
	# TODO: check that the directory doesn't conflict with anything already mounted
	if [ -n "$_dir" ]; then
		if [ ! -d "$_dir" ]; then
			_error "$_dir is not a directory"
			mount-in-help
			return 1
		fi
		if ! _is_absolute_path "$_dir" ; then
			if ! _dir="$(realpath -q "$_dir")" > /dev/null ; then
				_error "Not able to convert $_dir as an absolute pathname"
				mount-in-help
				return 1
			fi
		fi
		if ! _directory_validation "$_pname" "$_dir" ; then
			_error "Directory $_dir not valid, already used or already part of the pot"
			return 1
		fi
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		mount-in-help
		return 1
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	if ! _real_mnt_p="$(_mountpoint_validation "$_pname" "$_mnt_p" )" ; then
		_error "The mountpoint is not valid!"
		return 1
	fi
	if [ -n "$_dir" ]; then
		_mount_dir "$_dir" "$_pname" "$_real_mnt_p" $_opt
		return $?
	fi
	if [ -n "$_dset" ]; then
		_mount_dataset "$_dset" "$_pname" "$_real_mnt_p" $_opt
		return $?
	fi
	if [ -n "$_fscomp" ]; then
		_mount_dataset "$POT_ZFS_ROOT/fscomp/$_fscomp" "$_pname" "$_real_mnt_p" $_opt
		return $?
	fi
}
