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
}

# $1 fscomp
# $2 pot
# $3 mount point
# $4 external
_add_f_to_p()
{
	local _fscomp _pname _mnt_p _pdir _ext
	_fscomp="$1"
	_pname="$2"
	# Removing the trailing /
	# _mnt_p="$(echo $3 | sed 's%^/%%')" # or, more efficiently
	_mnt_p="${3#/}"
	_ext="${4}"
	_pdir=$POT_FS_ROOT/jails/$_pname
	if [ "$_ext" = "external" ]; then
		# convert zfs dataset in the mountpoint
		_fscomp=$( zfs list -H -o mountpoint $_fscomp )
		_debug "add $_fscomp $_pdir/m/$_mnt_p"
		${ECHO} "$_fscomp $_pdir/m/$_mnt_p" >> $_pdir/conf/fs.conf
	else
		_debug "add $POT_FS_ROOT/fscomp/$_fscomp $_pdir/m/$_mnt_p"
		${ECHO} "$POT_FS_ROOT/fscomp/$_fscomp $_pdir/m/$_mnt_p" >> $_pdir/conf/fs.conf
	fi
}

pot-add-fscomp()
{
	local _pname _fscomp _mnt_p _ext
	args=$(getopt hvf:p:m:e $*)
	if [ $? -ne 0 ]; then
		add-fscomp-help
		${EXIT} 1
	fi
	_fscomp=
	_pname=
	_mnt_p=
	_ext=
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
	if [ "$_ext" = "external" ]; then
		if ! _zfs_is_dataset $_fscomp ; then
			_error "fscomp $_fscomp is not a valid ZFS dataset"
			add-fscomp-help
			${EXIT} 1
		fi
	else
		if ! _zfs_is_dataset $POT_ZFS_ROOT/fscomp/$_fscomp ; then
			_error "fscomp $_fscomp is not valid"
			add-fscomp-help
			${EXIT} 1
		fi
	fi
	if ! _is_pot $_pname ; then
		_error "pot $_pname is not valid"
		add-fscomp-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_add_f_to_p $_fscomp $_pname $_mnt_p $_ext
}
