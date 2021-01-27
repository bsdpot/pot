#!/bin/sh
:

# shellcheck disable=SC2039
clone-fscomp-help()
{
	echo "pot clone-fscomp [-hv] -f fscomp -F fscomp"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -F fscomp : the fscomp to be cloned (mandatory)'
	echo '  -f fscomp : the fscomp name (mandatory)'
}

# $1 new fscomp name
# $2 old fscomp name
_cf_zfs()
{
	local _fscomp _cfscomp _fsdset _pdir _pbdir
	local _node _mnt_p _opt _new_mnt_p
	_fscomp=$1
	_cfscomp=$2
	_fsdset=${POT_ZFS_ROOT}/fscomp
	_fsdir=${POT_FS_ROOT}/fscomp
	_snap=$( _zfs_last_snap $_fsdset/$_cfscomp )
	if [ -z "$_snap" ]; then
		_error "$_fsdset/$_cfscomp has no snapshots - please take one"
		return 1
	else
		_debug "Cloning $_cfscompt@$_snap into $_fsdset/$_fscomp"
		zfs clone -o mountpoint=$_fsdir/$_fscomp $_fsdset/$_cfscomp@$_snap $_fsdset/$_fscomp
	fi
	return 0 # true
}

pot-clone-fscomp()
{
	local _pname _ipaddr _potbase _pb_ipaddr
	_fscomp=
	_cfscomp=
	OPTIND=1
	while getopts "hvf:F:" _o ; do
		case "$_o" in
		h)
			clone-fscomp-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		f)
			_fscomp=$OPTARG
			;;
		F)
			_cfscomp=$OPTARG
			;;
		*)
			clone-fscomp-help
			${EXIT} 1
			;;
		esac
	done
	# parameter validation
	if [ -z "$_fscomp" ]; then
		_error "fscomp name is missing (option -f)"
		clone-fscomp-help
		${EXIT} 1
	fi
	if [ -z "$_cfscomp" ]; then
		_error "clonable fscomp name is missing (option -F)"
		clone-fscomp-help
		${EXIT} 1
	fi
	if _zfs_dataset_valid ${POT_ZFS_ROOT}/fscomp/$_fscomp ; then
		_error "fscomp $_fscomp already exists"
		${EXIT} 1
	fi
	if ! _zfs_dataset_valid ${POT_ZFS_ROOT}/fscomp/$_cfscomp ; then
		_error "fscomp $_cfscomp doesn't exist"
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if ! _cf_zfs $_fscomp $_cfscomp ; then
		${EXIT} 1
	fi
}
