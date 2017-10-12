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
	[ $? -ne 0 ] && return $?
	local _mnt_
	_mnt_=$(zfs get -H mountpoint $1 2> /dev/null | awk '{ print $3 }')
	if [ "$_mnt_" != "$2" ]; then
		return 1 ## false
	fi
	return 0 ## true
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
