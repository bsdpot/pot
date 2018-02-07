#!/bin/sh

create-help()
{
	echo "pot create [-hv] -p potname [-i ipaddr] [-l lvl] [-f flavour|-F]"
	echo '  [-b base | -P basepot ] [-S] [-d dns]'
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p potname : the pot name (mandatory)'
	echo '  -l lvl : pot level'
	echo '  -b base : the base pot'
	echo '  -P pot : the pot to be used as reference with lvl 2'
	echo '  -i ipaddr : an ip address'
	echo '  -d dns : one between inherit(default) or pot'
	echo '  -f flavour : flavour to be used'
	echo '  -F : no default flavour is used'
	echo '  -S : use snapshots for lvl 2 fs component'
}

# $1 pot name
# $2 base name
# $3 level
# $4 pot-base name
# $5 use snapshots
_cj_zfs()
{
	local _pname _base _potbase _jdset _usesnap _snap _custom
	_pname=$1
	_base=$2
	_lvl=$3
	_potbase=$4
	_usesnap=$5
	_jdset=${POT_ZFS_ROOT}/jails/$_pname
	# Create the main jail zfs dataset
	if ! _zfs_is_dataset $_jdset ; then
		zfs create $_jdset
	else
		_info "$_jdset exists already"
	fi
	# Create the root mountpoint
	if [ ! -d "${POT_FS_ROOT}/jails/$_pname/m" ]; then
		mkdir -p ${POT_FS_ROOT}/jails/$_pname/m
	fi

	# lvl 0 images mount directly usr.local and custom
	if [ $_lvl -eq 0 ]; then
		return 0 # true
	fi

	# usr.local
	if [ $_lvl -eq 1 ]; then
		# lvl 1 images clone usr.local dataset
		if ! _zfs_is_dataset $_jdset/usr.local ; then
			_snap=$(_zfs_last_snap ${POT_ZFS_ROOT}/bases/$_base/usr.local)
			if [ -n "$_snap" ]; then
				_debug "Clone zfs snapshot ${POT_ZFS_ROOT}/bases/$_base/usr.local@$_snap"
				zfs clone -o mountpoint=${POT_FS_ROOT}/jails/$_pname/usr.local ${POT_ZFS_ROOT}/bases/$_base/usr.local@$_snap $_jdset/usr.local
			else
				_error "no snapshot found for ${POT_ZFS_ROOT}/bases/$_base/usr.local"
				return 1 # false
			fi
		else
			_info "$_jdset/usr.local exists already"
		fi
	else
		# lvl 2 - use snapshot if requested
		if [ "$_usesnap" = "YES" ]; then
			if ! _zfs_is_dataset $_jdset/usr.local ; then
				_snap=$(_zfs_last_snap ${POT_ZFS_ROOT}/jails/$_potbase/usr.local)
				if [ -n "$_snap" ]; then
					_debug "Clone zfs snapshot ${POT_ZFS_ROOT}/jails/$_potbase/usr.local@$_snap"
					zfs clone -o mountpoint=${POT_FS_ROOT}/jails/$_pname/usr.local ${POT_ZFS_ROOT}/jails/$_potbase/usr.local@$_snap $_jdset/usr.local
				else
					_error "no snapshot found for ${POT_ZFS_ROOT}/jails/$_potbase/usr.local"
					return 1 # false
				fi
			else
				_info "$_jdset/usr.local exists already"
			fi
		fi
	fi

	# custom dataset
	if ! _zfs_is_dataset $_jdset/custom ; then
		if [ $_lvl -eq 2 ]; then
			_custom=${POT_ZFS_ROOT}/jails/$_potbase/custom
		else
			_custom=${POT_ZFS_ROOT}/bases/$_base/custom
		fi
		_snap=$(_zfs_last_snap $_custom)
		if [ -n "$_snap" ]; then
			_debug "Clone zfs snapshot $_custom@$_snap"
			zfs clone -o mountpoint=${POT_FS_ROOT}/jails/$_pname/custom $_custom@$_snap $_jdset/custom
		else
			_error "no snapshot found for $_custom"
			return 1 # false
		fi
	else
		_info "$_jdset/custom exists already"
	fi
	return 0 # true
}

# $1 pot name
# $2 base name
# $3 ip
# $4 level
# $5 use snapshots
# $6 dns
# $7 pot-base name
_cj_conf()
{
	local _pname _base _ip _lvl _jdir _bdir _potbase _usesnap _dns
	_pname=$1
	_base=$2
	_ip=$3
	_lvl=$4
	_usesnap=$5
	_dns=$6
	_potbase=$7
	_jdir=${POT_FS_ROOT}/jails/$_pname
	_bdir=${POT_FS_ROOT}/bases/$_base
	if [ ! -d $_jdir/conf ]; then
		mkdir -p $_jdir/conf
	fi
	(
		if [ $_lvl -eq 0 ]; then
			echo "$_bdir ${_jdir}/m"
			echo "$_bdir/usr/local ${_jdir}/m/usr/local"
			echo "$_bdir/opt/custom ${_jdir}/m/opt/custom"
		elif [ $_lvl -eq 1 ]; then
			echo "$_bdir ${_jdir}/m ro"
			echo "$_jdir/usr.local ${_jdir}/m/usr/local"
			echo "$_jdir/custom ${_jdir}/m/opt/custom"
		elif [ $_lvl -eq 2 ]; then
			echo "$_bdir ${_jdir}/m ro"
			if [ "$_usesnap" = "YES" ]; then
				echo "$_jdir/usr.local ${_jdir}/m/usr/local ro"
			else
				echo "${POT_FS_ROOT}/jails/$_potbase/usr.local ${_jdir}/m/usr/local ro"
			fi
			echo "$_jdir/custom ${_jdir}/m/opt/custom"
		fi
	) > $_jdir/conf/fs.conf
	(
		echo "pot.level=${_lvl}"
		echo "pot.base=${_base}"
		echo "pot.potbase=${_potbase}"
		echo "pot.dns=${_dns}"
		echo "host.hostname=\"${_pname}.$( hostname )\""
		echo "osrelease=\"${_base}-RELEASE\""
		if [ "$_ip" = "inherit" ]; then
			echo "ip4=inherit"
			echo "vnet=false"
		else
			echo "ip4=${_ipaddr}"
			echo "vnet=true"
		fi
		if [ "${_dns}" == "pot" ]; then
			echo "pot.depend=${POT_DNS_NAME}"
		fi
	) > $_jdir/conf/pot.conf
}

# $1 pot name
# $2 flavour name
_cj_flv()
{
	local _pname _flv _pdir
	_pname=$1
	_flv=$2
	_pdir=${POT_FS_ROOT}/jails/$_pname
	_debug "Flavour: $_flv"
	if [ -r ${_POT_FLAVOUR_DIR}/${_flv} ]; then
		_debug "Adopt $_flv for $_pname"
		while read -r line ; do
			if _is_cmd_flavorable $line ; then
				pot-cmd $line -p $_pname
			else
				_error "Flavor $_flv: line $line not valid - ignoring"
			fi
		done < ${_POT_FLAVOUR_DIR}/${_flv}
	fi
	if [ -x ${_POT_FLAVOUR_DIR}/${_flv}.sh ]; then
		_debug "Start $_pname pot for the initial bootstrap"
		pot-cmd start $_pname
		cp -v ${_POT_FLAVOUR_DIR}/${_flv}.sh $_pdir/m/tmp
		jexec $_pname /tmp/${_flv}.sh $_pname
		pot-cmd stop $_pname
	else
		_debug "No shell script available for the flavour $_flv"
	fi
}

pot-create()
{
	local _pname _ipaddr _lvl _base _flv _potbase
	local _flv_default _usesnap _dns
	_pname=
	_base=
	_ipaddr=inherit
	_lvl=1
	_flv=
	_potbase=
	_flv_default="YES"
	_usesnap="NO"
	_dns=inherit
	args=$(getopt hvp:i:l:b:f:P:SFd: $*)
	if [ $? -ne 0 ]; then
		create-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			create-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-p)
			_pname=$2
			shift 2
			;;
		-i)
			_ipaddr=$2
			shift 2
			;;
		-l)
			_lvl=$2
			shift 2
			;;
		-b)
			_base=$2
			shift 2
			;;
		-P)
			_potbase=$2
			shift 2
			;;
		-S)
			_usesnap="YES"
			shift
			;;
		-f)
			if [ -z "${_POT_FLAVOUR_DIR}" -o ! -d "${_POT_FLAVOUR_DIR}" ]; then
				_error "The flavour dir is missing"
				exit 1
			fi
			if [ -r "${_POT_FLAVOUR_DIR}/$2" -o -x "${_POT_FLAVOUR_DIR}/$2.sh" ]; then
				_flv=$2
			else
				_error "The flavour $2 not found"
				_debug "Looking in the flavour dir ${_POT_FLAVOUR_DIR}"
				exit 1
			fi
			shift 2
			;;
		-F)
			_flv_default="NO"
			shift
			;;
		-d)
			case $2 in
				"inherit")
					;;
				"pot")
					_dns=pot
					;;
				*)
					_error "The dns $2 is not a valid option: choose between inherit or pot"
					exit 1
			esac
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done

	# check options consitency
	case $_lvl in
		0)
			if [ -z "$_base" ]; then
				_error "level $_lvl needs option -b"
				create-help
				exit 1
			fi
			if ! _is_base "$_base" quiet ; then
				_error "$_base is not a valid base"
				create-help
				exit 1
			fi
			;;
		1)
			if [ -z "$_base" -a -z "$_potbase" ]; then
				_error "at least one of -b and -P has to be used"
				create-help
				exit 1
			fi
			if [ -z "$_base" ]; then
				if ! _is_pot $_potbase ; then
					_error "-P $_potbase : is not a pot"
					create-help
					exit 1
				fi
				_base=$( _get_pot_base $_potbase )
				if [ -z "$_base" ]; then
					_error "-P $potbase has no base??"
					exit 1
				fi
				_debug "-P $_potbase induced -b $_base"
			fi
			if ! _is_base "$_base" quiet ; then
				_error "$_base is not a valid base"
				create-help
				exit 1
			fi
			if [ -n "$_potbase" ]; then
				_info "-p $_potbase will be ignored"
			fi
			;;
		2)
			if [ -z "$_potbase" ]; then
				_error "level $_lvl pots need another pot as reference"
				create-help
				exit 1
			fi
			if ! _is_pot $_potbase ; then
				_error "-P $_potbase : is not a pot"
				create-help
				exit 1
			fi
			if [ -n "$_base" ]; then
				if ! _is_base "$_base" quiet ; then
					_error "$_base is not a valid base"
					create-help
					exit 1
				fi
				if [ "$( _get_pot_base $_potbase )" != "$_base" ]; then
					_error "-b $_base and -P $_potbase are not compatible"
					exit 1
				fi
			else
				_base=$( _get_pot_base $_potbase )
				if [ -z "$_base" ]; then
					_error "-P $potbase has no base??"
					exit 1
				fi
				if ! _is_base "$_base" quiet ; then
					_error "$_base (induced by the pot $_potbase) is not a valid base"
					create-help
					exit 1
				fi
			fi
			;;
		*)
			_error "level $_lvl is not supported"
			exit 1
			;;
	esac
	if [ -z "$_pname" ]; then
		_error "pot name is missing"
		create-help
		exit 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if [ "$_ipaddr" != "inherit" ]; then
		if ! _is_vnet_available ; then
			_error "This kernel doesn't support VIMAGE! No vnet possible"
			${EXIT} 1
		fi
		if ! _is_vnet_up ; then
			_info "No pot bridge found! Calling vnet-start to fix the issue"
			pot-cmd vnet-start
		fi
	fi
	if [ "$_dns" = "pot" ]; then
		if ! _is_vnet_available ; then
			_error "This kernel doesn't support VIMAGE! No vnet possible (needed by the dns)"
			${EXIT} 1
		fi
		if ! _is_pot "${POT_DNS_NAME}" quiet ; then
			_info "dns pot not found ($POT_DNS_NAME) - fixing"
			pot-cmd create-dns
		fi
	fi
	if _is_verbose ; then
		_info "Option summary"
		_info "pname : $_pname"
		_info "base  : $_base"
		_info "lvl   : $_lvl"
		_info "dns   : $_dns"
		_info "pbase : $_potbase"
		_info "snap  : $_usesnap"
	fi
	if ! _cj_zfs $_pname $_base $_lvl $_potbase $_usesnap ; then
		exit 1
	fi
	if ! _cj_conf $_pname $_base $_ipaddr $_lvl ${_usesnap} $_dns $_potbase ; then
		exit 1
	fi
	if [ $_flv_default = "YES" ]; then
		_cj_flv $_pname default
	fi
	if [ -n "$_flv" ]; then
		_cj_flv $_pname $_flv
	fi
}
