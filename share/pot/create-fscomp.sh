#!/bin/sh

create-fscomp-help()
{
	echo "pot create-fscomp [-h][-v] -f name"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f name : the fs component name (mandatory)'
}

pot-create-fscomp()
{
	local _dset
	_dset=
	args=$(getopt hvf: $*)
	if [ $? -ne 0 ]; then
		create-fscomp-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			create-fscomp-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-f)
			_dset="${POT_ZFS_ROOT}/fscomp/$2"
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done

	if [ -z "$_dset" ]; then
		_error "fs component name is missing"
		create-fscomp-help
		exit 1
	fi
	if ! _is_init ; then
		${EXIT} 1
	fi
	if ! _zfs_dataset_valid "$_dset" ; then
		if ! _is_uid0 ; then
			${EXIT} 1
		fi
		zfs create "$_dset"
		if [ $? -ne 0 ]; then
			_error "fs component $_dset creation failed"
			exit 1
		fi
	else
		_info "fs component $_dset already exists"
	fi
	return 0
}
