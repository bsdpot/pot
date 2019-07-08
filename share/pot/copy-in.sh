#!/bin/sh
:

# shellcheck disable=SC2039
copy-in-help()
{
	echo "pot copy-in [-hv] -p pot -s source -d destination"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -s source : the file to be added component to be added'
	echo '  -d destination : the final location inside the pot'
}

# $1 source
_source_validation()
{
	# shellcheck disable=SC2039
	local _pname _source _destination
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

# shellcheck disable=SC2039
pot-copy-in()
{
	local _pname _source _destination _to_be_umount _rc
	OPTIND=1
	_pname=
	_destination=
	while getopts "hvs:d:p:" _o ; do
		case "$_o" in
		h)
			copy-in-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
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
			${EXIT} 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		copy-in-help
		${EXIT} 1
	fi
	if [ -z "$_source" ]; then
		_error "A source is mandatory"
		copy-in-help
		${EXIT} 1
	fi
	if [ -z "$_destination" ]; then
		_error "A destination is mandatory"
		copy-in-help
		${EXIT} 1
	fi
	if ! _is_absolute_path "$_destination" ; then
		_error "The destination has to be an absolute pathname"
		${EXIT} 1
	fi
	_destination="${_destination#/}"

	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		copy-in-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if ! _source_validation "$_source" ; then
		copy-in-help
		${EXIT} 1
	fi
	if ! _is_pot_running "$_pname" ; then 
		_pot_mount "$_pname"
		_to_be_umount=1
	fi
	if _is_verbose ; then
		_cp_opt="-va"
	else
		_cp_opt="-a"
	fi
	if cp "$_cp_opt" "$_source" "${POT_FS_ROOT}/jails/$_pname/m/$_destination" ; then
		_debug "Source $_source copied in the pot $_pname"
		_rc=0
	else
		_error "Source $_source NOT copied because of an error"
		_rc=1
	fi
	if [ "$_to_be_umount" = "1" ]; then
		_pot_umount "$_pname"
	fi
	${EXIT} $_rc
}
