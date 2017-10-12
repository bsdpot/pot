#!/bin/sh

pot-init()
{
	if ! _zfs_exist "${POT_ZFS_ROOT}" "${POT_FS_ROOT}" ; then
		if _zfs_is_dataset "${POT_ZFS_ROOT}" ; then
			echo "${POT_ZFS_ROOT} is an invalid POT root"
			return 1 # false
		fi
		# create the pot root
		echo zfs create -o mountpoint=${POT_FS_ROOT} -o canmount=off -o compression=lz4 -o atime=off ${POT_ZFS_ROOT}
	else
		echo "${POT_ZFS_ROOT} already present"
	fi

	# create the root directory
	if [ ! -d ${POT_FS_ROOT} ]; then
		echo mkdir -p ${POT_FS_ROOT}
		if [ ! -d ${POT_FS_ROOT} ]; then
			echo "Not able to create the dir ${POT_FS_ROOT}"
			return 1 # false
		fi
	fi

	# create mandatory datasets

	echo zfs create ${POT_FS_ROOT}/bases
	echo fzs create ${POT_FS_ROOT}/jails
	echo zfs create ${POT_FS_ROOT}/fscomp
}
# create the pot root

#zfs create -o mountpoint=/opt/pot -o canmount=off -o compression=lz4 -o atime=off zroot/pot

# create the root directory

#mkdir -p /opt/pot

# create mandatory datasets

#zfs create zroot/pot/bases
#zfs create zroot/pot/jails
#zfs create zroot/pot/fscomp

