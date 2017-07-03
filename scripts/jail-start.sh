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


CJAIL_MOUNTPOINT=${CARTON_JAILS}/${JAIL}/m/

mount_fs() {
	while read -r line ; do
		mount_special=$( echo $line | awk '{ print $1 }')
		mount_point=$( echo $line | awk '{ print $2 }')
		mount_opt=$( echo $line | awk '{ print $3 }')
		mount_nullfs -o ${mount_opt:-rw} $mount_special $mount_point
	done < ${CARTON_JAILS}/${JAIL}/conf/fs.conf

	mount -t tmpfs tmpfs ${CJAIL_MOUNTPOINT}/tmp
}
mount_fs

# updating the resolv.conf
if [ -d ${CARTON_JAILS}/${JAIL}/etc ]; then
	cp /etc/resolv.conf ${CARTON_JAILS}/${JAIL}/etc
else
	echo "Warning: no 'etc' directory found. resolv.conf backup mode"
	cp /etc/resolv.conf ${CJAIL_MOUNTPOINT}/etc
fi

jail -c -f ${CARTON_JAILS}/${JAIL}/conf/jail.conf
