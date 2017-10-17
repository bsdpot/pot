#!/bin/sh

# check if the dataset $1 exists
# $1 the dataset NAME
_zfs_is_dataset()
{
	[ -z "$1" ] && return 1 ## return false
	zfs list "$1" 2> /dev/null > /dev/null
	return $?
}

# check if the dataset $1 with the mountpoint $2 exists
# $1 the dataset NAME
# $2 the mountpoint
_zfs_exist()
{
	[ -z "$1" -o -z "$2" ] && return 1 ## return false
	zfs list "$1" 2> /dev/null > /dev/null
	[ $? -ne 0 ] && return 1 ## false
	local _mnt_
	_mnt_=$(zfs get -H mountpoint $1 2> /dev/null | awk '{ print $3 }')
	if [ "$_mnt_" != "$2" ]; then
		return 1 ## false
	fi
	return 0 ## true
}

# take a zfs recursive snapshot of a pot
# $1 pot name
_pot_zfs_snap()
{
	local _pname _snaptag _dset
	_pname=$1
	_snaptag="$(date +%s)"
	echo "Take snapshot of $_pname"
	zfs snapshot -r ${POT_ZFS_ROOT}/jails/${_pname}@${_snaptag}
}

# take a zfs snapshot of all rw dataset found in the fs.conf of a pot
# $1 jail name
_pot_zfs_snap_full()
{
	local _pname _node _opt _snaptag _dset
	_pname=$1
	_snaptag="$(date +%s)"
	echo "Take snapshot of the full $_pname"
	while read -r line ; do
		_node=$( echo $line | awk '{print $1}' )
		_opt=$( echo $line | awk '{print $3}' )
		if [ "$_opt" = "ro" ]; then
			continue
		fi
		_dset=$( zfs list -H $_node | awk '{print $1}' )
		if [ -n "$_dset" ]; then
			echo "==> snapshot of $_dset"
			zfs snapshot ${_dset}@${_snaptag}
		fi
	done < ${POT_FS_ROOT}/jails/$_pname/conf/fs.conf
}

# $1 the dataset name
_zfs_last_snap()
{
	local _dset _output
	_dset="$1"
	if [ -z "$_dset" ]; then
		return 1 # false
	fi
	_output="$(zfs list -d 1 -H -t snapshot $_dataset | sort -r | cut -d'@' -f2 | cut -f1)"
	if [ -z "$d_set" ]; then
		return 1 # false
	fi
	echo "${_output}"
	return 0 # true
}

# $1 the element to search
# $2.. the list
_is_in_list()
{
	local _e
	if [ $# -lt 2 ]; then
		return 1 # false
	fi
	_e="$1"
	shift
	for e in $@ ; do
		if [ "$_e" = "$e" ]; then
			return 0 # true
		fi
	done
	return 1 # false
}

# $1 mountpoint
_is_mounted()
{
	local _mnt_p _mounted
	_mnt_p=$1
	if [ -z "$_mnt_p" ]; then
		return 1 # false
	fi
	_mounted=$( mount | grep -F $_mnt_p | awk '{print $3}')
	for m in $_mounted ; do
		if [ "$m" = "$_mounted" ]; then
			return 0 # true
		fi
	done
	return 1 # false
}

# $1 mountpoint
_umount()
{
	local _mnt_p
	_mnt_p=$1
	if _is_mounted "$_mnt_p" ; then
		umount -f $_mnt_p
	fi
}

pot-cmd()
{
	local _cmd _func
	_cmd=$1
	shift
	if [ ! -r "${_POT_INCLUDE}/${_cmd}.sh" ]; then
		echo "Fatal error! $_cmd implementation not found!"
		exit 1
	fi
	. ${_POT_INCLUDE}/${_cmd}.sh
	_func=pot-${_cmd}
	$_func $@
}
