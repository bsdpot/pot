#!/bin/sh

pot-init()
{
	# create the pot root
	echo zfs create -o mountpoint=${POT_FS_ROOT} -o canmount=off -o compression=lz4 -o atime=off ${POT_ZFS_ROOT}

	# create the root directory
	echo mkdir -p ${POT_FS_ROOT}

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

