#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

# TODO
# add sha256 check on fetch pot and option to disable it
# add fscomp.conf management

import-help() {
	cat <<-"EOH"
	pot import [-hv] -p pot -t tag -U URL [-C pubkey]
	  -h print this help
	  -v verbose
	  -p pot : the remote pot name
	  -t tag : the tag of the pot
	  -U URL : the base URL where to find the image file
	  -C pubkey : verify with public key 'pubkey' using signify(1)
	EOH
}

# $1 : remote pot name
# $2 : tag
# $3 : pubkey (if non-empty, signature is fetched)
# $4 : URL
_fetch_pot()
{
	local _filename
	_filename="${1}_${2}.xz"
	if ! _fetch_pot_internal "$1" "$2" "$3" "$4" ; then
		# remove the artifacts and retry, but only once
		rm -f "${POT_CACHE}/${_filename}" \
			"${POT_CACHE}/${_filename}.meta" \
			"${POT_CACHE}/${_filename}.skein" \
			"${POT_CACHE}/${_filename}.skein.sig"
		if ! _fetch_pot_internal "$1" "$2" "$3" "$4"; then
			return 1 # false
		fi
		return 0 # true
	fi
	return 0 # true
}

# $1 : remote pot name
# $2 : tag
# $3 : pubkey (if non-empty, signature is fetched)
# $4 : URL
_fetch_pot_internal()
{
	local _rpname _tag _sign_pubkey _URL _filename
	_rpname=$1
	_tag=$2
	_sign_pubkey=$3
	_filename="${1}_${2}.xz"
	if [ -z "$4" ]; then
		_URL="file://"
	else
		_URL="$4"
	fi
	if [ ! -r "${POT_CACHE}/$_filename.skein" ]; then
		if ! fetch "$_URL/$_filename.skein" --output "${POT_CACHE}/$_filename.skein" ; then
			return 1 # false
		fi
	fi
	if [ -n "$_sign_pubkey" ]; then
		if [ ! -r "${POT_CACHE}/$_filename.skein.sig" ]; then
			if ! fetch "$_URL/$_filename.skein.sig" \
			    --output "${POT_CACHE}/$_filename.skein.sig" ; then
				return 1 # false
			fi
		fi
		if signify -V -p "$_sign_pubkey" -x "${POT_CACHE}/$_filename.skein.sig" \
		    -m "${POT_CACHE}/$_filename.skein"; then
			_debug "Signature verification succeeded"
		else
			_error "Signature verification failed"
			return 1 # false
		fi
	fi
	if [ ! -r "${POT_CACHE}/$_filename" ]; then
		if ! fetch "$_URL/$_filename" --output "${POT_CACHE}/$_filename" ; then
			return 1 # false
		fi
	fi
	if [ ! -r "${POT_CACHE}/$_filename.meta" ]; then
		if ! fetch "$_URL/$_filename.meta" --output "${POT_CACHE}/$_filename.meta" ; then
			# At the moment, ignore this to be backwards compatible
			_info "No ${POT_CACHE}/$_filename.meta, ignoring"
			touch "${POT_CACHE}/$_filename.meta"
		fi
	fi
	if (cat "${POT_CACHE}/$_filename" "${POT_CACHE}/$_filename.meta" |\
		skein1024 -q) | cmp "${POT_CACHE}/$_filename.skein" - ; then
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
	local _pname _rpname _tag _filename _network_type _newip _cdir
	local _sign_pubkey _origin_pname _origin_snap
	_rpname="$1"
	_tag="$2"
	_pname="$3"
	_sign_pubkey="$4"
	_origin_pname="$5"
	_origin_snap="$6"
	_filename="${_rpname}_${_tag}.xz"
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"

	if [ -n "$_origin_pname" ] && [ -n "$_origin_snap" ]; then
		# shellcheck disable=SC2046
		xzcat "${POT_CACHE}/$_filename" | zfs receive -uo \
		  "origin=${POT_ZFS_ROOT}/jails/$_origin_pname@$_origin_snap" \
		  $(_get_zfs_receive_extra_args) \
		  "${POT_ZFS_ROOT}/jails/$_pname"
		zfs inherit mountpoint "${POT_ZFS_ROOT}/jails/$_pname/m"
		zfs mount "${POT_ZFS_ROOT}/jails/$_pname"
		zfs mount "${POT_ZFS_ROOT}/jails/$_pname/m"
	else
		# shellcheck disable=SC2046
		xzcat "${POT_CACHE}/$_filename" | zfs receive \
		  $(_get_zfs_receive_extra_args) "${POT_ZFS_ROOT}/jails/$_pname"
	fi

	# pot.conf modifications
	_hostname="${_pname}.$( hostname )"
	${SED} -i '' -e "/^host.hostname=.*/d" "$_cdir/pot.conf"
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

pot-import()
{
	local _rpname _tag _URL _pname _sign_pubkey
	_rpname=
	_tag=
	_URL=
	_sign_pubkey=
	local _meta _dep_pname_tag _dep_snap _dep_pname _dep_tag _dep_origin
	local _filename

	OPTIND=1
	while getopts "hvp:t:U:C:" _o ; do
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
			if [ -z "$OPTARG" ]; then
				_error "Argument of -U cannot be empty"
				import-help
				${EXIT} 1
			fi
			_URL="$OPTARG"
			;;
		C)
			_sign_pubkey="$OPTARG"
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
	if [ -n "$_sign_pubkey" ]; then
		if [ ! -r "$_sign_pubkey" ]; then
			_error "Public key $_sign_pubkey not found"
			${EXIT} 1
		fi
		if ! type "signify" >/dev/null 2>&1; then
			_error "Could not find 'signify',"\
			       "try 'pkg install signify'"
			${EXIT} 1
		fi
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_info "importing $_rpname @ $_tag as $_pname"
	if ! _fetch_pot "$_rpname" "$_tag" "$_sign_pubkey" "$_URL" ; then
		${EXIT} 1
	fi

	_dep_origin=""
	_dep_snap=""
	_filename="${_rpname}_${_tag}.xz"
	_meta=$(head -n1 "${POT_CACHE}/$_filename.meta")
	if [ -n "${_meta}" ] && [ "${_meta}" != "-" ]; then
		_dep_pname_tag=$(echo "${_meta}" | awk -F@ '{ print $1 }')
		_dep_snap=$(echo "${_meta}" | awk -F@ '{ print $2 }')
		_dep_pname=$(echo "${_dep_pname_tag}" | awk -F: '{ print $1 }')
		_dep_tag=$(echo "${_dep_pname_tag}" | awk -F: '{ print $2 }')
		_dep_origin=$(echo "${_dep_pname}_${_dep_tag}" | sed "s/\./_/g")
		_info "Pot $_pname depends on ${_dep_origin} (@${_dep_snap})"
		# XXX: assumes remote name equals local name
		if ! _is_pot "${_dep_origin}" quiet ; then
			_info "Installing dependency ${_dep_origin}"
			if ! pot-cmd import -p "$_dep_pname" -t "$_dep_tag" \
			    -U "$_URL" -C "$_sign_pubkey"; then
				${EXIT} 1
			fi
		else
			_info "${_dep_origin} already installed"
		fi
		#exit 1
	else
		_info "Pot $_pname has no dependencies"
	fi

	if ! _import_pot "$_rpname" "$_tag" "$_pname" "$_sign_pubkey" \
	    "$_dep_origin" "$_dep_snap"; then
		${EXIT} 1
	fi
	return 0
}
