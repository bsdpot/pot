#!/bin/sh

# supported releases
: ${_POT_RELEASES:="10.1 10.3 10.4 11.0 11.1 11.2"}
create-base-help()
{
	echo "pot create-base [-h] [-r RELEASE]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -r RELEASE : supported release are:'"${_POT_RELEASES}"
	echo '  -b base name : optional, (default: the release)'
}

# $1 release
_cb_fetch()
{
	local _rel _sha _sha_m
	_rel=$1
	fetch -m http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/"${_rel}"-RELEASE/base.txz -o /tmp/"${_rel}"_base.txz
	if [ ! -r /tmp/"${_rel}"_base.txz ]; then
		return 1 # false
	fi
	if [ -r /usr/local/share/freebsd/MANIFESTS/amd64-amd64-"${_rel}"-RELEASE ]; then
		_sha=$( sha256 -q /tmp/"${_rel}"_base.txz )
#		_sha_m=$( awk '/^base.txz/ { print $2 }' < /usr/local/share/freebsd/MANIFESTS/amd64-amd64-${_rel}-RELEASE)
		_sha_m=$( cat /usr/local/share/freebsd/MANIFESTS/amd64-amd64-"${_rel}"-RELEASE | awk '/^base.txz/ { print $2 }' )
		if [ "$_sha" != "$_sha_m" ]; then
			_error "sha256 doesn't match! Aborting"
			return 1 # false
		fi
	else
		_error "No manifests found - please install the package freebsd-release-manifests"
		return 1 # false
	fi
	return 0 # true
}

# $1 base name
_cb_zfs()
{
	local _bname _dset _mnt
	_bname=$1
	_dset="${POT_ZFS_ROOT}/bases/${_bname}"
	_mnt="${POT_FS_ROOT}/bases/${_bname}"
	_info "Create the zfs datasets for base release $_dset"
	if ! _zfs_exist "${_dset}" "${_mnt}" ; then
		if ! zfs create "$_dset" ; then
			return 1
		fi
	fi

	if ! _zfs_exist "${_dset}/usr.local" "${_mnt}/usr/local" ; then
		if ! zfs create -o mountpoint="${_mnt}/usr/local" "$_dset/usr.local" ; then
			return 1
		fi
	fi

	if ! _zfs_exist "${_dset}/custom" "${_mnt}/opt/custom" ; then
		if ! zfs create -o mountpoint="${_mnt}/opt/custom" "$_dset/custom" ; then
			return 1
		fi
	fi
	return 0
}

# $1 release
# $2 base name
_cb_tar_dir()
{
	local _rel _bname _mnt
	_rel=$1
	_bname=$2
	_mnt="${POT_FS_ROOT}/bases/${_bname}"
	(
		cd "$_mnt"
		tar xkf /tmp/"${_rel}"_base.txz
		# add release information
		echo "$_rel" > .osrelease
		cp -a root opt/custom/
		cp -a etc opt/custom/
		cp -a var opt/custom/
		mkdir -p opt/custom/usr.local.etc
		mkdir -p opt/custom/usr.home
		# they could be part of flavor
		mkdir -p usr/ports

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
		mkdir -p var.db.pkg
		cd ../../opt/custom/var/db
		rm -rf pkg
		ln -s ../../../../usr/local/var.db.pkg pkg
	)
}

# $1 base name
_cb_base_pot()
{
	local _bname _pname _tmp
	_bname=$1
	_tmp=$(echo "$_bname" | sed 's/\./_/')
	_pname="base-$_tmp"
	_info "Create the related pot [$_pname]"
	if ! _is_pot "$_pname" quiet ; then
		if [ -x "${_POT_FLAVOUR_DIR}/default-base.sh" ]; then
			pot-cmd create -F -f default-base -l 0 -b "$_bname" -p "$_pname"
		else
			pot-cmd create -F -l 0 -b "$_bname" -p "$_pname"
		fi
	fi
	pot-cmd snapshot -a -p "$_pname"
}

pot-create-base()
{
	local _rel _bname
	if ! args=$(getopt hr:b:v "$@") ; then
		create-base-help
		${EXIT} 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			create-base-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-r)
			if ! _is_in_list "$2" $_POT_RELEASES ; then
				_error "$2 is not a supported release"
				create-base-help
				${EXIT} 1
			fi
			_rel=$2
			shift 2
			;;
		-b)
			if _is_base "$2" quiet ; then
				_error "$2 is already a base"
				${EXIT} 1
			fi
			_bname="$2"
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done

	if [ -z "$_rel" ]; then
		_error "option -r is mandatory"
		create-base-help
		${EXIT} 1
	fi
	if [ -z "$_bname" ]; then 
		_bname=$_rel
		_info "Automatically use $_rel as base name"
	fi
	if [ "$_bname" != "$_rel" ] && _is_in_list "$_bname" $_POT_RELEASES ; then
		_error "$_bname has the name of another valid release and that's forbidden"
		create-base-help
		${EXIT} 1
	fi
	if _is_base $_bname quiet ; then
		_error "$_bname already exist"
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if ! _is_init ; then
		${EXIT} 1
	fi
	_info "Create a base with release $_rel"
	# fetch binaries
	if ! _cb_fetch "${_rel}" ; then
		_error "fetch of ${_rel}-RELEASE failed"
		${EXIT} 1
	fi
	# create zfs dataset
	if ! _cb_zfs "${_bname}" ; then
		_error "zfs dataset of ${_bname} failed"
		${EXIT} 1
	fi
	# move binaries to the dataset and create linkx
	_cb_tar_dir "${_rel}" "${_bname}"
	# create jail level 0
	_cb_base_pot "${_bname}"
}
