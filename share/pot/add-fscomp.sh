#!/bin/sh

# supported releases
add-fscomp-help()
{
	echo "pot add-fscomp [-h][-v] -f fscomp -p pot -m mnt"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f fscomp : the fs component to be added'
	echo '  -p pot : the working pot'
	echo '  -m mnt : the mount point inside the pot'
}

# $1 fscomp
# $2 pot
# $2 mount point
_add_f_to_p()
{
	local _fscomp _pname _mnt_p _pdir
	_fscomp="$1"
	_pname="$2"
	# Removing the trailing /
	# _mnt_p="$(echo $3 | sed 's%^/%%')" # or, more efficiently
	_mnt_p="${3#/}"
	_pdir=$POT_FS_ROOT/jails/$_pname
	echo "$POT_FS_ROOT/fscomp/$_fscomp $_pdir/m/$_mnt_p" >> $_pdir/conf/fs.conf
}

pot-add-fscomp()
{
	local _pname _fscomp _mnt_p
	args=$(getopt hvf:p:m: $*)
	if [ $? -ne 0 ]; then
		add-fscomp-help
		exit 1
	fi
	_fscomp=
	_pname=
	_mnt_p=
	set -- $args
	while true; do
		case "$1" in
		-h)
			add-fscomp-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-f)
			_fscomp="$2"
			shift 2
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
		_error "A jail name is mandatory"
		add-fscomp-help
		exit 1
	fi
	if [ -z "$_fscomp" ]; then
		_error "A fs component is mandatory"
		add-fscomp-help
		exit 1
	fi
	if ! _zfs_is_dataset $POT_ZFS_ROOT/fscomp/$_fscomp ; then
		_error "fscomp $_fscomp is not valid"
		add-fscomp-help
		exit 1
	fi
	if ! _is_pot $_pname ; then
		_error "pot $_pname is not valid"
		add-fscomp-help
		exit 1
	fi
	_add_f_to_p $_fscomp $_pname $_mnt_p
}
