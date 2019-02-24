#!/bin/sh
:
# TODO
# add sha256 check on fetch pot and option to disable it
# add fscomp.conf management

# shellcheck disable=SC2039
import-help() {
	echo "pot import [-hv] -p pot -t tag [-U URL]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the remote pot name'
	echo '  -t tag : the tag of the pot'
	echo '  -U URL : the URL where to find the image file'
}

# $1 : remote pot name
# $2 : tag
# $3 : URL
_fetch_pot()
{
	# shellcheck disable=SC2039
	local _rpname _tag _URL _filename
	_rpname=$1
	_tag=$2
	_filename="${1}_${2}.xz"
	if [ -z "$3" ]; then
		_URL="file://"
	else
		_URL="$3"
	fi
	if [ ! -r "${POT_CACHE}/$_filename" ]; then
		fetch "$_URL/$_filename" --output "${POT_CACHE}/$_filename"
	fi
}

# $1 : remote pot name
# $2 : tag
# $3 : local pot name
_import_pot()
{
	# shellcheck disable=SC2039
	local _pname _rpname _tag _filename _vnet _ip4 _newip
	_rpname="$1"
	_tag="$2"
	_pname="$3"
	_filename="${_rpname}_${_tag}.xz"
	xzcat "${POT_CACHE}/$_filename" | zfs recv "${POT_ZFS_ROOT}/jails/$_pname"
	# xzcat  "${POT_CACHE}/$_filename" | zfs recv -u ${POT_ZFS_ROOT}/jails/$_pname
	# zfs set mountpoint=${POT_FS_ROOT}/jails/$_rpname
	# zfs set to be repeated for all children or zfs mount

	# pot.conf modifications
	_hostname="${_pname}.$( hostname )"
	sed -i '' -e "s%^host.hostname=.*$%host.hostname=${_hostname}%" "${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"

	# network rework
	_vnet="$( _get_conf_var "$_pname" vnet )"
	_ip4="$( _get_conf_var "$_pname" ip4 )"

	if [ "$_ip4" = "inherit" ]; then
		_debug "ip4 set to inherit, nothing to rework"
	else
		_newip="$(potnet next)"
		sed -i '' -e "s%^ip4=.*$%ip4=${_newip}%" "${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"
		if [ "$_vnet" = "true" ]; then
			_info "Assigning new IP: $_newip"
		else
			_error "Static IP not supported by import. Moving the pot to the internal network"
			sed -i '' -e "s%^vnet=.*$%vnet=true%" "${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"
		fi
	fi
}

# shellcheck disable=SC2039
pot-import()
{
	local _rpname _tag _URL _pname
	_rpname=
	_tag=
	_URL=
	OPTIND=1
	while getopts "hvp:t:U:" _o ; do
		case "$_o" in
		h)
			import-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_rpname="$OPTARG"
			;;
		t)
			_tag="$OPTARG"
			;;
		U)
			_URL="$OPTARG"
			;;
		*)
			import-help
			${EXIT} 1
		esac
	done

	if [ -z "$_rpname" ]; then
		_error "A remote pot name is mandatory"
		import-help
		${EXIT} 1
	fi
	if [ -z "$_tag" ]; then
		_error "A tag name is mandatory"
		import-help
		${EXIT} 1
	fi
	_pname="${_rpname}_${_tag}"
	_pname="$(echo "$_pname" | tr '.' '_')"
	if _is_pot "$_pname" quiet ; then
		_error "pot $_pname is already present"
		import-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_info "importing $_rpname @ $_tag as $_pname"
	_fetch_pot "$_rpname" "$_tag" "$_URL"
	_import_pot "$_rpname" "$_tag" "$_pname"
	return $?
}
