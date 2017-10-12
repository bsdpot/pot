#!/bin/sh

# supported releases
: ${_POT_RELEASES:="10.3 10.4 11.0 11.1"}
create-base-help()
{
	echo "pot create-base [-h] [-r RELEASE]"
	echo '  -h print this help'
	echo '  -r RELEASE : supported release are:'"${_POT_RELEASES}"
}

# $1 release
_cb_fetch()
{
	local _rel
	_rel=$1
	fetch -m http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/${_rel}-RELEASE/base.txz -o /tmp/${_rel}_base.txz

	return $?
}

# $1 release
_cb_zfs()
{
	local _rel _dset _mnt
	_rel=$1
	_dset="${POT_ZFS_ROOT}/bases/${_rel}"
	_mnt="${POT_FS_ROOT}/bases/${_rel}"
	echo "Create the zfs datasets for base release $_dset"
	if ! _zfs_exist "${_dset}" "${_mnt}" ; then
		echo zfs create "$_dset"
	fi

	if ! _zfs_exist "${_dset}/usr.local" "${_mnt}/usr/local" ; then
		echo zfs create -o mountpoint "${_mnt}/usr/local" "$_dset/usr.local"
	fi

	if ! _zfs_exist "${_dset}/custom" "${_mnt}/opt/custom" ; then
		echo zfs create -o mountpoint "${_mnt}/opt/custom" "$_dset/custom"
	fi
}

pot-create-base()
{
	args=$(getopt hr: $*)

	set -- $args
	while true; do
		case "$1" in
		-h)
			create-base-help
			exit 0
			;;
		-r)
			if ! _is_in_list $2 $_POT_RELEASES ; then
				echo "$2 is not a supported release"
				exit 1
			fi
			_FBSD_RELEASE=$2
			shift 2
			;;
		--)
			shift
			break
			;;
		*)
			create-base-help
			exit 1
		esac
	done

	echo "Create a base with release "${_FBSD_RELEASE}" "
	# fetch binaries
	if ! _cb_fetch "${_FBSD_RELEASE}" ; then
		echo "fetch of ${_FBSD_RELEASE}-RELEASE failed"
		exit 1
	fi
	# create zfs dataset
	_cb_zfs "${_FBSD_RELEASE}"
	# move binaries to the dataset
	# create ??
}
