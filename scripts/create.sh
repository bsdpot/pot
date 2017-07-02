#!/bin/sh

CARTON_ROOT=/opt/carton

CARTON_JAILS=${CARTON_ROOT}/jails

if [ -z "$1" ]; then
	echo "Please provide a jail name"
	exit
fi
NEW_JAIL=$1
shift
if [ -d ${CARTON_JAILS}/${NEW_JAIL} ]; then
	echo "The jail ${NEW_JAIL} already exists"
	echo "[ remove the ${CARTON_JAILS}/${NEW_JAIL} directory ]"
	exit
fi

if [ -z "$1" ]; then
	echo "Please provide a FreeBSD version"
	exit
fi
REL=$1
shift
if [ ! -d ${CARTON_ROOT}/bases/${REL} ]; then
	echo "The release $1 doesn't exists"
	exit
fi


mkdir -p ${CARTON_JAILS}/${NEW_JAIL}

for subd in conf et local m var ; do
	mkdir -p ${CARTON_JAILS}/${NEW_JAIL}/$subd
done


