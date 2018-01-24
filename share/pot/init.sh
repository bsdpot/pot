#!/bin/sh

init-help()
{
	echo 'pot init [-h][-v]'
	echo '  -h -- print this help'
	echo '  -v verbose'
}


pot-init()
{
	args=$(getopt hv $*)
	if [ $? -ne 0 ]; then
		init-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			init-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done

	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	if ! _zfs_exist "${POT_ZFS_ROOT}" "${POT_FS_ROOT}" ; then
		if _zfs_is_dataset "${POT_ZFS_ROOT}" ; then
			_error "${POT_ZFS_ROOT} is an invalid POT root"
			return 1 # false
		fi
		# create the pot root
		zfs create -o mountpoint=${POT_FS_ROOT} -o canmount=off -o compression=lz4 -o atime=off ${POT_ZFS_ROOT}
	else
		_info "${POT_ZFS_ROOT} already present"
	fi

	# create the root directory
	if [ ! -d ${POT_FS_ROOT} ]; then
		mkdir -p ${POT_FS_ROOT}
		if [ ! -d ${POT_FS_ROOT} ]; then
			_error "Not able to create the dir ${POT_FS_ROOT}"
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

