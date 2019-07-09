#!/bin/sh
:
# TODO
# add sha256 check on fetch pot and option to disable it
# add fscomp.conf management

# shellcheck disable=SC2039
import-help() {
	echo "pot import [-hv] -p pot -t tag -a aID -U URL"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the remote pot name'
	echo '  -t tag : the tag of the pot'
	echo '  -a aID : the allocation ID for the pot'
	echo '  -U URL : the base URL where to find the image file'
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
		if ! fetch "$_URL/$_filename" --output "${POT_CACHE}/$_filename" ; then
			return 1 # false
		fi
	fi
	if [ ! -r "${POT_CACHE}/$_filename.skein" ]; then
		if ! fetch "$_URL/$_filename.skein" --output "${POT_CACHE}/$_filename.skein" ; then
			return 1 # false
		fi
	fi
	if skein1024 -q "${POT_CACHE}/$_filename" | cmp "${POT_CACHE}/$_filename.skein" - ; then
		_debug "Hash confirmed"
	else
		_error "The image and its hash do not overlap"
		return 1 # false
	fi
	return 0 # false
}

# $1 : remote pot name
# $2 : tag
# $3 : local pot name
_import_pot()
{
	# shellcheck disable=SC2039
	local _pname _rpname _tag _filename _network_type _vnet _ip _newip
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
	${SED} -i '' -e "/^host.hostname=.*/d" "${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"
	echo "host.hostname=\"${_hostname}.$( hostname )\"" >> "$_cdir/pot.conf"

	# network rework
	_network_type="$( _get_pot_network_type "$_pname" )"
	case "$_network_type" in
	"inherit")
		_debug "network_type set to inherit, nothing to rework"
		;;
	"alias")
		_error "Static IP not supported by import. Moving the pot to the internal network"
		${SED} -i '' -e "s%^vnet=.*$%vnet=true%" "${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"
		_newip="$(potnet next)"
		sed -i '' -e "s%^ip=.*$%ip=${_newip}%" "${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"
		_info "Assigning new IP: $_newip"
		;;
	"public-bridge")
		_newip="$(potnet next)"
		sed -i '' -e "s%^ip=.*$%ip=${_newip}%" "${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"
		_info "Assigning new IP: $_newip"
		;;
	esac
}

# shellcheck disable=SC2039
pot-import()
{
	local _rpname _tag _URL _pname _allocation_tag
	_rpname=
	_tag=
	_URL=
	_allocation_tag=
	OPTIND=1
	while getopts "hvp:t:U:a:" _o ; do
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
		a)
			_allocation_tag="$OPTARG"
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
	if [ -z "$_allocation_tag" ]; then
		_error "A allocation id is mandatory"
		import-help
		${EXIT} 1
	fi
	_pname="${_rpname}_${_tag}_${_allocation_tag}"
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
	if ! _fetch_pot "$_rpname" "$_tag" "$_URL" ; then
		${EXIT} 1
	fi
	if ! _import_pot "$_rpname" "$_tag" "$_pname" ; then
		${EXIT} 1
	fi
	return 0
}
