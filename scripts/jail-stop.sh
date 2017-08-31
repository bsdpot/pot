#!/bin/sh

CARTON_ROOT=/opt/carton
CARTON_JAILS=${CARTON_ROOT}/jails

if [ -z "$1" ]; then
	echo "Please provide a jail name"
	exit
fi
JAIL=$1
shift
if [ ! -d ${CARTON_JAILS}/${JAIL} -o \
	! -r ${CARTON_JAILS}/${JAIL}/conf/jail.conf -o \
	! -r ${CARTON_JAILS}/${JAIL}/conf/fs.conf ]; then
	echo "The jail ${JAIL} doesn't exists or some component is missing"
	exit
fi

jail -r ${JAIL}

# removing resolv.conf
if [ -f ${CARTON_JAILS}/${JAIL}/m/etc/resolv.conf ]; then
	rm ${CARTON_JAILS}/${JAIL}/m/etc/resolv.conf
fi

_is_mounted() {
	local _mntpoint
	_mntpoint=$1
	if [ -z "$_mntpoint" ]; then
		return 1 # false
	fi
	local _mounted
	_mounted=$( mount | grep $_mntpoint | grep -v zfs | awk '{print $3}')
	for m in "$_mounted" ; do
		if [ "$_mntpoint" = "$m" ]; then
			return 0 # true
		fi
	done
	return 1 # false
}

_umount() {
	local _mntpoint
	_mntpoint=$1
	if [ -z "$_mntpoint" ]; then
		return 1 # false
	fi
	if _is_mounted $_mntpoint ; then
		umount -f $_mntpoint
	fi
}

umount_fs() {
	tail -r ${CARTON_JAILS}/${JAIL}/conf/fs.conf > /tmp/fs.conf
	_umount ${CARTON_JAILS}/${JAIL}/m/tmp
	_umount ${CARTON_JAILS}/${JAIL}/m/dev
	while read -r line ; do
		mount_point=$( echo $line | awk '{ print $2 }')
		_umount $mount_point
	done < /tmp/fs.conf
}
umount_fs

