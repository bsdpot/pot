#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

create-fscomp-help()
{
	echo "pot create-fscomp [-hv] -f name"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f name : the fs component name (mandatory)'
}

pot-create-fscomp()
{
	local _dset
	_dset=
	OPTIND=1
	while getopts "hvf:" _o ; do
		case "$_o" in
		h)
			create-fscomp-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		f)
			_dset="${POT_ZFS_ROOT}/fscomp/$OPTARG"
			;;
		?)
			create-fscomp-help
			${EXIT} 1
		esac
	done

	if [ -z "$_dset" ]; then
		_error "fs component name is missing"
		create-fscomp-help
		${EXIT} 1
	fi
	if ! _is_init ; then
		${EXIT} 1
	fi
	if ! _zfs_dataset_valid "$_dset" ; then
		if ! _is_uid0 ; then
			${EXIT} 1
		fi
		if ! zfs create "$_dset" ; then
			_error "fs component $_dset creation failed"
			${EXIT} 1
		fi
	else
		_info "fs component $_dset already exists"
	fi
	return 0
}
