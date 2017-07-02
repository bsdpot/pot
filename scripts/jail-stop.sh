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
	! -r ${CARTON_JAILS}/${JAIL}/conf/mount.conf ]; then
	echo "The jail ${JAIL} doesn't exists or some component is missing"
	exit
fi

jail -r ${JAIL}

# TODO: this part has to be reworked
# unmounting everyhing

unmount ${CARTON_JAILS}/${JAIL}/m/dev
# sh ${CARTON_JAILS}/${JAIL}/mount.conf
