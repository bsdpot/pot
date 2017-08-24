#!/bin/sh

JOCKER_ZFS_ROOT=zroot/carton
JOCKER_FS_ROOT=/opt/carton

# derived entries
JOCKER_ZFS_BASE=${JOCKER_ZFS_ROOT}/bases
JOCKER_ZFS_JAIL=${JOCKER_ZFS_ROOT}/jails
JOCKER_FS_JAIL=${JOCKER_FS_ROOT}/jails

# It check if the root zfs datasets are present
is_zfs_ready()
{
	local _output
	for _dataset in ${JOCKER_ZFS_ROOT} ${JOCKER_ZFS_BASE} ${JOCKER_ZFS_JAIL} ; do
		_output="$(zfs get -H mountpoint ${_dataset} 2>/dev/null)"
		if [ "$?" -ne 0 ]; then
			echo ${_dataset} not existing \[ $_output \]
			return 1 # false
		fi
	done
	_output="$(zfs get -H mountpoint ${JOCKER_ZFS_JAIL} 2>/dev/null)"
	if [ "$( echo $_output | awk '{print $3}')" != "none" ]; then
		echo ${_dataset} has the wrong mountpoint
		return 1 # false
	fi
}

_is_zfs_dataset()
{
	local _dataset _output
	_dataset=$1
	if [ -z "${_dataset}" ]; then
		return 1 # false
	fi
	_output="$(zfs get -H mountpoint ${_dataset} 2>/dev/null)"
	return $?
}

_get_last_zfs_snap()
{
	local _dataset _output
	_dataset=$1
	if [ -z "$_dataset" ]; then
		return
	fi
	_output="$( zfs list -d 1 -H -t snapshot $_dataset | sort -r | cut -d'@' -f2 | cut -f1)"
	if [ -z "$_output" ]; then
		return 1 # false
	else
		echo ${_output}
		return 0 # true
	fi
}

# $1 the jailname
# $2 the FreeBSD base version
create_jail_fs()
{
	local _jailname _jaildir _basever _snap
	_jailname=$1
	_basever=$2
	if [ -z "${_jailname}" ]; then
		return 1 # false
	fi
	if ! is_zfs_ready ; then
		return 1 # false
	fi
	if ! _is_zfs_dataset ${JOCKER_ZFS_JAIL}/${_jailname} ; then
		echo "Creating zfs dataset: ${JOCKER_ZFS_JAIL}/${_jailname}"
		zfs create ${JOCKER_ZFS_JAIL}/${_jailname}
	fi
	_jaildir=${JOCKER_FS_JAIL}/${_jailname}
	if [ ! -d ${_jaildir} ]; then
		mkdir -p ${_jaildir}/m
	fi
	if ! _is_zfs_dataset ${JOCKER_ZFS_JAIL}/${_jailname}/usr.local ; then
		# check if the specific base exists
		if ! _is_zfs_dataset ${JOCKER_ZFS_BASE}/${_basever} ; then
			return 1 # false
		fi
		# looking for the last snapshot
		_snap=$( _get_last_zfs_snap ${JOCKER_ZFS_BASE}/${_basever}/usr.local )
		if [ -z "$_snap" ]; then
			return 1 # false
		fi
		echo "Cloning zfs snapshot: ${JOCKER_ZFS_BASE}/${_basever}/usr.local@${_snap}"
		zfs clone -o mountpoint=${_jaildir}/usr.local ${JOCKER_ZFS_BASE}/${_basever}/usr.local@${_snap} ${JOCKER_ZFS_JAIL}/${_jailname}/usr.local
	fi
	if ! _is_zfs_dataset ${JOCKER_ZFS_JAIL}/${_jailname}/custom ; then
		# check if the specific base exists
		if ! _is_zfs_dataset ${JOCKER_ZFS_BASE}/${_basever} ; then
			return 1 # false
		fi
		# looking for the last snapshot
		_snap=$( _get_last_zfs_snap ${JOCKER_ZFS_BASE}/${_basever}/custom )
		if [ -z "$_snap" ]; then
			return 1 # false
		fi
		echo "Cloning zfs snapshot: ${JOCKER_ZFS_BASE}/${_basever}/custom@${_snap}"
		zfs clone -o mountpoint=${_jaildir}/custom ${JOCKER_ZFS_BASE}/${_basever}/custom@${_snap} ${JOCKER_ZFS_JAIL}/${_jailname}/custom
	fi
}

main()
{
if ! is_zfs_ready ; then
	echo "The zfs infra is not ready"
else
	echo "The zfs infra is fine"
fi

if create_jail_fs $1 "11.1" ; then
	echo created jail $1
fi
}
