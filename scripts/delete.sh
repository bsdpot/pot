#!/bin/sh

JOCKER_ZFS_ROOT=zroot/carton
JOCKER_FS_ROOT=/opt/carton

# derived entries
JOCKER_ZFS_BASE=${JOCKER_ZFS_ROOT}/bases
JOCKER_ZFS_JAIL=${JOCKER_ZFS_ROOT}/jails
JOCKER_FS_BASE=${JOCKER_FS_ROOT}/bases
JOCKER_FS_JAIL=${JOCKER_FS_ROOT}/jails

_is_zfs_dataset()
{
	local _dataset _output
	_dataset=$1
	if [ -z "${_dataset}" ]; then
		return 1 # false
	fi
	zfs list -H "${_dataset}" >/dev/null 2>/dev/null
	return $?
}

_get_snapshots()
{
	local _dataset _output
	_dataset=$1
	if [ -z "$_dataset" ]; then
		return 1 # false
	fi
	if _is_zfs_dataset "$_dataset" ; then
		return 1 # false
	fi
	_output="$( zfs list -H -r -t snapshot $_dataset | sort -r | cut -f1)"
	if [ -z "$_output" ]; then
		return 1 # false
	else
		echo ${_output}
		return 0 # true
	fi
}

destroy_zfs_datasets()
{
	local _jailname
	_jailname=$1
	if [ -z "$_jailname" ]; then
		return
	fi
	# removing all snapshot 
	for snap in $(_get_snapshots ${JOCKER_ZFS_JAIL}/$_jailname)
	do
		zfs destroy -d $snap
	done
	if [ -n "$(_get_snapshots ${JOCKER_ZFS_JAIL}/$_jailname)" ]; then
		echo "There is still some snapshot left: $(_get_snapshots ${JOCKER_ZFS_JAIL}/$_jailname)"
		return 1 # false
	fi
	if _is_zfs_dataset ${JOCKER_ZFS_JAIL}/$_jailname ; then
		zfs destroy -vrf ${JOCKER_ZFS_JAIL}/$_jailname
	fi
}

main()
{
	# remove all zfs datasets
	destroy_zfs_datasets $1

	# remove all directories
	rm -rf ${JOCKER_FS_JAIL}/$1
}

main $1
