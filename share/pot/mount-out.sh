#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

mount-out-help()
{
	cat <<-"EOH"
	pot mount-out [-hvwr] -p pot -m mnt
	  -h print this help
	  -v verbose
	  -p pot : the working pot
	  -m mnt : the mount point inside the pot
	EOH
}

# $1 pot
# $2 mount point
_is_mountpoint_used()
{
	local _pname _mnt_p _proot
	_pname="$1"
	_mnt_p="${2}"
	_conf=$POT_FS_ROOT/jails/$_pname/conf/fscomp.conf
	_proot=$POT_FS_ROOT/jails/$_pname/m
	## spaces in this sequences of grep have been introduced to detect exact matches only
	## a pattern like /mnt/test would match /mnt/test and /mnt/test2
	## with those spaces we try be more precise in detecting the exact match
	if grep -q " $_mnt_p$" "$_conf" ||
		grep -q " $_mnt_p " "$_conf" ; then
		# mount point already used
		return 0 # true
	fi
	if grep -q "$_proot/$_mnt_p " "$_conf" ; then
		# mountpoint used as source directory ?? wtf
		_error "The mountpoint is already used as source directory mount-out"
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
	if ! _is_pot_running "$_pname" ; then
		_mounted=true # true
		if ! _pot_mount "$_pname" >/dev/null ; then
			_error "Pot $_pname failed to mount"
			return 1 # false
		fi
	fi
	_real_mnt=$( chroot "$_mpdir" /bin/realpath "$_mnt_p")
	if eval $_mounted ; then
		_pot_umount "$_pname" >/dev/null
	fi
	if ! _is_mountpoint_used "$_pname" "$_real_mnt" ; then
		_error "The mount point $_mnt_p is not in use"
		return 1 # false
	fi
	echo "$_real_mnt"
	return 0 # true
}

# $1 pot
# $2 mount point
_umount_mnt_p()
{
	local _pname _mnt_p _pdir
	_pname="$1"
	# Removing the trailing /
	_mnt_p="${2#/}"
	_pdir=$POT_FS_ROOT/jails/$_pname
	# absolute pathname of the mount point with escape character
	_sed_string="$(echo "$_pdir/m/$_mnt_p" | sed 's#/#\\/#g')"
	_debug "umount_mnt_p: mnt_p:$_pdir/m/$_mnt_p"
	${SED} -E -i '' " $_sed_string$| $_sed_string /d" "$_pdir/conf/fscomp.conf"

	if _is_pot_running "$_pname" ; then
		if _umount "$_pdir/m/$_mnt_p" ; then
			_debug "Umounted $_mnt_p on $_pname"
		else
			_error "Error umounting $_mnt_p on $_pname"
		fi
	fi
}

pot-mount-out()
{
	local _pname _mnt_p _real_mnt_p
	OPTIND=1
	_pname=
	_mnt_p=
	logger -t pot -p local0.debug -- "mount-out: $*"
	while getopts "hvp:m:" _o ; do
		case "$_o" in
		h)
			mount-out-help
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		m)
			_mnt_p="$OPTARG"
			;;
		*)
			mount-out-help
			return 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		mount-out-help
		return 1
	fi
	if [ -z "$_mnt_p" ]; then
		_error "A mount point is mandatory"
		mount-out-help
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

	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		mount-out-help
		return 1
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	if ! _real_mnt_p="$(_mountpoint_validation "$_pname" "$_mnt_p" )" ; then
		echo "$_real_mnt_p"
		_error "The mountpoint is not valid!"
		return 1
	fi
	_umount_mnt_p "$_pname" "$_real_mnt_p"
	return $?
}
