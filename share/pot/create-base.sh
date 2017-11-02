#!/bin/sh

# supported releases
: ${_POT_RELEASES:="10.1 10.3 10.4 11.0 11.1"}
create-base-help()
{
	echo "pot create-base [-h] [-r RELEASE]"
	echo '  -h print this help'
	echo '  -v verbose'
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
	_info "Create the zfs datasets for base release $_dset"
	if ! _zfs_exist "${_dset}" "${_mnt}" ; then
		zfs create "$_dset"
		[ $? != 0 ] && return 1
	fi

	if ! _zfs_exist "${_dset}/usr.local" "${_mnt}/usr/local" ; then
		zfs create -o mountpoint="${_mnt}/usr/local" "$_dset/usr.local"
		[ $? != 0 ] && return 1
	fi

	if ! _zfs_exist "${_dset}/custom" "${_mnt}/opt/custom" ; then
		zfs create -o mountpoint="${_mnt}/opt/custom" "$_dset/custom"
		[ $? != 0 ] && return 1
	fi
	return 0
}

_cb_tar_dir()
{
	local _rel _dset _mnt
	_rel=$1
	_mnt="${POT_FS_ROOT}/bases/${_rel}"
	(
		cd $_mnt
		tar xkf /tmp/${_rel}_base.txz
		cp -a root opt/custom/
		cp -a etc opt/custom/
		cp -a var opt/custom/
		mkdir opt/custom/usr.local.etc
		mkdir opt/custom/usr.home
		# they could be part of flavor
		mkdir usr/ports
		mkdir appdata

		# remove duplicated dirs
		chflags -R noschg var/empty
		rm -rf etc/ root/ var/

		# create links
		ln -s opt/custom/etc etc
		ln -s opt/custom/root root
		ln -s opt/custom/var var
		cd usr
		ln -s ../opt/custom/usr.home home
		cd local
		ln -s ../../opt/custom/usr.local.etc etc
	)
}

# $1 release
_cb_base_pot()
{
	local _rel
	_rel=$1
	_rel_2=$(echo $_rel | sed 's/\./_/')
	pot-cmd create -l 0 -b $_rel -p base-$_rel_2
}

pot-create-base()
{
	args=$(getopt hr:v $*)
	if [ $? -ne 0 ]; then
		create-base-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			create-base-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-r)
			if ! _is_in_list $2 $_POT_RELEASES ; then
				_error "$2 is not a supported release"
				exit 1
			fi
			_FBSD_RELEASE=$2
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done

	_info "Create a base with release "${_FBSD_RELEASE}" "
	# fetch binaries
	if ! _cb_fetch "${_FBSD_RELEASE}" ; then
		_error "fetch of ${_FBSD_RELEASE}-RELEASE failed"
		exit 1
	fi
	# create zfs dataset
	if ! _cb_zfs "${_FBSD_RELEASE}" ; then
		_error "zfs dataset of ${_FBSD_RELEASE}-RELEASE failed"
		exit 1
	fi
	# move binaries to the dataset and create linkx
	_cb_tar_dir "${_FBSD_RELEASE}"
	# create jail level 0
	_cb_base_pot ${_FBSD_RELEASE}
}
