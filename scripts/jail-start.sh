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
	! -r ${CARTON_JAILS}/${JAIL}/jail.conf -o \
	! -r ${CARTON_JAILS}/${JAIL}/mount.conf ]
]; then
	echo "The jail ${JAIL} doesn't exists or some component is missing"
	exit
fi

# updating the resolv.conf

if [ -d ${CARTON_JAILS}/${JAIL}/etc ]; then
	cp /etc/resolv.conf ${CARTON_JAILS}/${JAIL}/etc
else
	echo "Warning: no 'etc' directory found. resolv.conf not updated"
fi

# TODO: this part has to be reworked
# mounting everyhing

sh ${CARTON_JAILS}/${JAIL}/mount.conf

jail -c -f ${CARTON_JAILS}/${JAIL}/conf/jail.conf
