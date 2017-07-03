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

umount_fs() {
	tail -r ${CARTON_JAILS}/${JAIL}/conf/fs.conf > /tmp/fs.conf
	umount ${CARTON_JAILS}/${JAIL}/m/tmp
	while read -r line ; do
		mount_point=$( echo $line | awk '{ print $2 }')
		sleep 2
		umount $mount_point
	done < /tmp/fs.conf
}
umount_fs

umount ${CARTON_JAILS}/${JAIL}/m/dev
