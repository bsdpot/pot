#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

create-private-bridge-help()
{
	echo 'pot create-private-bridge [-h][-v][-B name][-S size]'
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -B bridge name'
	echo '  -S bridge size (number of host expected)'
}

# $1 bridge-name
# $2 bridge-size
create-bridge()
{
	local _bconf _bname _bsize
	_bname=$1
	_bsize=$2
	_bconf="${POT_FS_ROOT}/bridges/$_bname"
	if potnet new-net -s "$_bsize" > "$_bconf" ; then
		echo "name=$_bname" >> "$_bconf"
	else
		rm -f "$_bconf"
		_error "Not able to get a valid network with size $_bsize"
		${EXIT} 1
	fi
}

pot-create-private-bridge()
{
	local _bname _host_amount
	OPTIND=1
	while getopts "hvB:S:" _o ; do
		case "$_o" in
		h)
			create-private-bridge-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		B)
			_bname="$OPTARG"
			;;
		S)
			_host_amount="$OPTARG"
			;;
		?)
			create-private-bridge-help
			${EXIT} 1
		esac
	done

	if [ -z "$_bname" ]; then
		_error "A bridge name is mandatory (-B option)"
		${EXIT} 1
	fi
	if [ -z "$_host_amount" ]; then
		_error "The amount of host is mandatory (-S option)"
		${EXIT} 1
	fi
	if ! _is_potnet_available ; then
	   _error "potnet is not available! It's needed - cannot proceed"
		${EXIT} 1
	fi
	if _is_bridge "$_bname" quiet ; then
		_error "A bridge with name $_bname already exists"
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	mkdir -p "${POT_FS_ROOT}/bridges"
	create-bridge "$_bname" "$_host_amount"
}
