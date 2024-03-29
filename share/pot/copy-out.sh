#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

copy-out-help()
{
	cat <<-"EOH"
	pot copy-out [-hv] -p pot -s source -d dest
	  -h print this help
	  -v verbose
	  -F force copy operation for running jails
	     (warning: can expose parts of the host file system)
	  -p pot : the working pot
	  -s source : the file or directory inside the pot
	  -d dest : the location (directory) on the host to copy-out to
	EOH
}

# $1 source
_destination_validation()
{
	local _destination
	_destination="$1"
	if [ -r "$_destination" ] && [ -d "$_destination" ] && [ -x "$_destination" ]; then
		return 0 # true
	else
		_error "$_destination not valid"
	fi
}

_make_temp_destination()
{
	local _proot
	_proot="$1"
	mktemp -d "$_proot/tmp/copy-out${POT_MKTEMP_SUFFIX}"
}

_mount_destination_into_potroot()
{
	local _destination _mountpoint
	_destination="$1"
	_mountpoint="$2"
	if ! mount_nullfs "$_destination" "$_mountpoint" ; then
		_error "Failed to mount destination inside the pot"
		return 1
	fi
}

pot-copy-out()
{
	local _pname _source _destination _to_be_umount _rc _force _proot _cp_opt _destination_mountpoint
	OPTIND=1
	_pname=
	_destination=
	_force=
	_cp_opt="-a"
	while getopts "hvs:d:p:F" _o ; do
		case "$_o" in
		h)
			copy-out-help
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
			copy-out-help
			return 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		copy-out-help
		return 1
	fi
	if [ -z "$_source" ]; then
		_error "A source is mandatory"
		copy-out-help
		return 1
	fi
	if [ -z "$_destination" ]; then
		_error "A destination is mandatory"
		copy-out-help
		return 1
	fi
	if ! _is_absolute_path "$_source" ; then
		_error "The source has to be an absolute pathname"
		return 1
	fi

	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		copy-out-help
		return 1
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	if ! _destination_validation "$_destination" ; then
		copy-out-help
		return 1
	fi
	if _is_pot_running "$_pname" ; then
		if [ "$_force" != "YES" ]; then
			_error "Copying files from a running pot is discouraged, it can partially expose the host file system to the jail"
			_info "Using the -F flag, the operation can be executed anyway, but we disagree"
			return 1
		else
			_debug "Copying files from a running pot allowed, because of the -F flag"
		fi
	else
		_pot_mount "$_pname"
		_to_be_umount=1
	fi
	_proot=${POT_FS_ROOT}/jails/$_pname/m
	if ! _destination_mountpoint="$( _make_temp_destination "$_proot" )" ; then
		_error "Failed to build a temporary folder in the pot /tmp"
		if [ "$_to_be_umount" = "1" ]; then
			_pot_umount "$_pname"
		fi
		return 1
	fi
	if ! _mount_destination_into_potroot "$_destination" "$_destination_mountpoint" ; then
		if [ "$_to_be_umount" = "1" ]; then
			_pot_umount "$_pname"
		fi
		return 1
	fi
	_cp_destination="/tmp/$( basename "$_destination_mountpoint" )"
	if _is_pot_running "$_pname" ; then
		if jexec "$_pname" /bin/cp "$_cp_opt" "$_source" "$_cp_destination" ; then
			_debug "Source $_source copied from the pot $_pname"
			_rc=0
		else
			_error "Source $_source NOT copied because of an error"
			_rc=1
		fi
	else
		if jail -c path="$_proot" command=/bin/cp "$_cp_opt" "$_source" "$_cp_destination" ; then
			_debug "Source $_source copied from the pot $_pname"
			_rc=0
		else
			_error "Source $_source NOT copied because of an error"
			_rc=1
		fi
	fi

	if ! umount -f "$_destination_mountpoint" ; then
		_error "Failed to unmount the source tmp folder from the pot"
		_rc=1
	fi
	if [ "$_to_be_umount" = "1" ]; then
		_pot_umount "$_pname"
	else
		rmdir "$_destination_mountpoint"
	fi
	return $_rc
}
