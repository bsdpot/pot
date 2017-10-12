#!/bin/sh

# $1 the dataset NAME
_zfs_is_dataset()
{
	[ -z "$1" ] && return 1 ## return false
	zfs list "$1" 2> /dev/null > /dev/null
	return $?
}

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
	if [ $# -lt 3 ]; then
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
