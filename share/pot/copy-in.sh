#!/bin/sh
:

# shellcheck disable=SC3033
copy-in-help()
{
	echo "pot copy-in [-hv] -p pot -s source -d destination"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -F force copy operation for running jails (can partially expose the host file system)'
	echo '  -p pot : the working pot'
	echo '  -s source : the file or directory to be copied in'
	echo '  -d destination : the final location inside the pot'
}

# $1 source
_source_validation()
{
	# shellcheck disable=SC3043
	local _source
	_source="$1"
	if [ -f "$_source" ] || [ -d "$_source" ]; then
		if [ -r "$_source" ]; then
			return 0 # true
		else
			_error "$_source not readable"
		fi
	else
		_error "$_source not valid"
		return 1 # false
	fi
}

_make_temp_source()
{
	# shellcheck disable=SC3043
	local _proot
	_proot="$2"
	mktemp -d "$_proot/tmp/copy-in${POT_MKTEMP_SUFFIX}"
}

_mount_source_into_potroot()
{
	# shellcheck disable=SC3043
	local _source _mountpoint _source_mnt
	_source="$1"
	_mountpoint="$2"
	if [ -f "$_source" ]; then
		_source_mnt="$( dirname "$_source" )"
	else
		_source_mnt="$_source"
	fi
	if ! mount_nullfs -o ro "$_source_mnt" "$_mountpoint" ; then
		_error "Failed to mount source inside the pot"
		return 1
	fi
}

# shellcheck disable=SC3033
pot-copy-in()
{
	# shellcheck disable=SC3043
	local _pname _source _destination _to_be_umount _rc _force _proot _cp_opt
	OPTIND=1
	_pname=
	_destination=
	_force=
	_cp_opt="-a"
	while getopts "hvs:d:p:F" _o ; do
		case "$_o" in
		h)
			copy-in-help
			return 0
			;;
		F)
			_force="YES"
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			_cp_opt="-va"
			;;
		s)
			_source="$OPTARG"
			;;
		p)
			_pname="$OPTARG"
			;;
		d)
			_destination="$OPTARG"
			;;
		*)
			copy-in-help
			return 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		copy-in-help
		return 1
	fi
	if [ -z "$_source" ]; then
		_error "A source is mandatory"
		copy-in-help
		return 1
	fi
	if [ -z "$_destination" ]; then
		_error "A destination is mandatory"
		copy-in-help
		return 1
	fi
	if ! _is_absolute_path "$_destination" ; then
		_error "The destination has to be an absolute pathname"
		return 1
	fi

	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		copy-in-help
		return 1
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	if ! _source_validation "$_source" ; then
		copy-in-help
		return 1
	fi
	if _is_pot_running "$_pname" ; then
		if [ "$_force" != "YES" ]; then
			_error "Copying files on a running pot is discouraged, it can partially expose the host file system to the jail"
			_info "Using the -F flag, the operation can be executed anyway, but we disagree"
			return 1
		else
			_debug "Copying files on a running pot allowed, because of the -F flag"
		fi
	else
		_pot_mount "$_pname"
		_to_be_umount=1
	fi
	_proot=${POT_FS_ROOT}/jails/$_pname/m
	if ! _source_mountpoint="$( _make_temp_source "$_proot" )" ; then
		_error "Failed to build a temporary folder in the pot /tmp"
		if [ "$_to_be_umount" = "1" ]; then
			_pot_umount "$_pname"
		fi
		return 1
	fi
	if ! _mount_source_into_potroot "$_source" "$_source_mountpoint" ; then
		if [ "$_to_be_umount" = "1" ]; then
			_pot_umount "$_pname"
		fi
		return 1
	fi
	if [ -f "$_source" ]; then
		_cp_source="/tmp/$( basename "$_source_mountpoint" )/$( basename "$_source" )"
	else
		_cp_source="/tmp/$( basename "$_source_mountpoint" )"
	fi
	if _is_pot_running "$_pname" ; then
		if jexec "$_pname" /bin/cp "$_cp_opt" "$_cp_source" "$_destination" ; then
			_debug "Source $_source copied in the pot $_pname"
			_rc=0
		else
			_error "Source $_source NOT copied because of an error"
			_rc=1
		fi
	else
		if jail -c path="$_proot" command=/bin/cp "$_cp_opt" "$_cp_source" "$_destination" ; then
			_debug "Source $_source copied in the pot $_pname"
			_rc=0
		else
			_error "Source $_source NOT copied because of an error"
			_rc=1
		fi
	fi

	if ! umount -f "$_source_mountpoint" ; then
		_error "Failed to unmount the source tmp folder from the pot"
		_rc=1
	fi
	if [ "$_to_be_umount" = "1" ]; then
		_pot_umount "$_pname"
	else
		rmdir "$_source_mountpoint"
	fi
	return $_rc
}
