#!/bin/sh

init-help()
{
	echo 'pot init [-h]'
	echo '  -h -- print this help'
}


pot-init()
{
	if [ "$1" = "-h" ]; then
		init-help
		exit 0
	fi
	if ! _zfs_exist "${POT_ZFS_ROOT}" "${POT_FS_ROOT}" ; then
		if _zfs_is_dataset "${POT_ZFS_ROOT}" ; then
			echo "${POT_ZFS_ROOT} is an invalid POT root"
			return 1 # false
		fi
		# create the pot root
		zfs create -o mountpoint=${POT_FS_ROOT} -o canmount=off -o compression=lz4 -o atime=off ${POT_ZFS_ROOT}
	else
		echo "${POT_ZFS_ROOT} already present"
	fi

	set -x
	# create the root directory
	if [ ! -d ${POT_FS_ROOT} ]; then
		mkdir -p ${POT_FS_ROOT}
		if [ ! -d ${POT_FS_ROOT} ]; then
			echo "Not able to create the dir ${POT_FS_ROOT}"
			return 1 # false
		fi
	fi

	# create mandatory datasets
	if ! _zfs_is_dataset "${POT_ZFS_ROOT}/bases" ; then
		zfs create ${POT_ZFS_ROOT}/bases
	fi
	if ! _zfs_is_dataset "${POT_ZFS_ROOT}/jails" ; then
		zfs create ${POT_ZFS_ROOT}/jails
	fi
	if ! _zfs_is_dataset "${POT_ZFS_ROOT}/fscomp" ; then
		zfs create ${POT_ZFS_ROOT}/fscomp
	fi
}

