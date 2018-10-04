#!/bin/sh

# supported releases
add-fscomp-help()
{
	echo "pot add-fscomp [-h][-v] -f fscomp -p pot -m mnt"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f fscomp : the fs component to be added'
	echo '  -e : the fscomp is an external zfs dataset'
	echo '  -p pot : the working pot'
	echo '  -m mnt : the mount point inside the pot'
	echo '  -w : '"don't use nullfs, but change the zfs mountpoint (DANGEROUS)"
	echo '  -r : mount the fscomp in read-only'
}

# $1 pot
# $2 mount point
_mountpoint_validation()
{
	local _pname _mnt_p _mpdir _startflag
	_pname="$1"
	_mnt_p="$2"
	_mpdir=$POT_FS_ROOT/jails/$_pname/m
	_started=false # false
	if ! _is_pot_running ; then
		_started=true # true
		if ! pot-cmd start "$_pname" ; then
			_error "Pot $_pname failed to start"
			return 1 # false
		fi
	fi
	# if the mountpoint doesn't exist, make it
	if [ ! -d "$_mpdir/$_mnt_p" ]; then
		if ! mkdir -p "$_mpdir/$_mnt_p" ; then
			if eval $_started ; then
				pot-cmd stop "$_pname"
			fi
			return 1 # false
		fi
	fi
	if eval $_started ; then
		pot-cmd stop "$_pname"
	else
		# TODO mount it directly?
		_info "You have to restart your pot $_pname to make new modification effective"
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
	local _fscomp _pname _mnt_p _pdir _ext _opt
	_fscomp="$1"
	_pname="$2"
	# Removing the trailing /
	_mnt_p="${3#/}"
	_ext="${4}"
	_opt="${5}"
	_pdir=$POT_FS_ROOT/jails/$_pname
	if [ "$_ext" = "external" ]; then
		_debug "add $_fscomp $_pdir/m/$_mnt_p $_opt"
		if [ -z "$_opt" ]; then
			${ECHO} "$_fscomp $_pdir/m/$_mnt_p" >> "$_pdir/conf/fscomp.conf"
		else
			${ECHO} "$_fscomp $_pdir/m/$_mnt_p $_opt" >> "$_pdir/conf/fscomp.conf"
		fi
	else
		_debug "add $POT_ZFS_ROOT/fscomp/$_fscomp $_pdir/m/$_mnt_p $_opt"
		if [ -z "$_opt" ]; then
			${ECHO} "$POT_ZFS_ROOT/fscomp/$_fscomp $_pdir/m/$_mnt_p" >> "$_pdir/conf/fscomp.conf"
		else
			${ECHO} "$POT_ZFS_ROOT/fscomp/$_fscomp $_pdir/m/$_mnt_p $_opt" >> "$_pdir/conf/fscomp.conf"
		fi
	fi
}

pot-add-fscomp()
{
	local _pname _fscomp _mnt_p _ext _remount _readonly _opt
	if ! args=$(getopt hvf:p:m:ewr "$@") ; then
		add-fscomp-help
		${EXIT} 1
	fi
	_fscomp=
	_pname=
	_mnt_p=
	_ext="NO"
	_remount="NO"
	_readonly="NO"
	_opt=
	set -- $args
	while true; do
		case "$1" in
		-h)
			add-fscomp-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-f)
			_fscomp="$2"
			shift 2
			;;
		-e)
			_ext="external"
			shift
			;;
		-p)
			_pname="$2"
			shift 2
			;;
		-m)
			_mnt_p="$2"
			shift 2
			;;
		-w)
			_remount="YES"
			shift
			;;
		-r)
			_readonly="YES"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		add-fscomp-help
		${EXIT} 1
	fi
	if [ -z "$_fscomp" ]; then
		_error "A fs component is mandatory"
		add-fscomp-help
		${EXIT} 1
	fi
	if [ -z "$_mnt_p" ]; then
		_error "A mount point is mandatory"
		add-fscomp-help
		${EXIT} 1
	fi
	if [ "$_remount" = "YES" ]; then
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
	if [ "$_ext" = "external" ]; then
		if ! _zfs_dataset_valid "$_fscomp" ; then
			_error "fscomp $_fscomp is not a valid ZFS dataset"
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
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		add-fscomp-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if ! _mountpoint_validation "$_pname" "$_mnt_p" ; then
		_error "The mountpoint is not valid!"
		${EXIT} 1
	fi
	_add_f_to_p "$_fscomp" "$_pname" "$_mnt_p" $_ext $_opt
}
