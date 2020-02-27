#!/bin/sh
:

trap _cj_undo_create TERM INT

# shellcheck disable=SC2039
create-help()
{
	echo "pot create [-hv] -p potname [-N network-type] [-i ipaddr] [-l lvl] [-f flavour]"
	echo '  [-b base | -P basepot ] [-d dns] [-t type]'
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -k keep the pot, if create fails'
	echo '  -p potname : the pot name (mandatory)'
	echo '  -l lvl : pot level (only for type multi)'
	echo '  -b base : the base pot'
	echo '  -P pot : the pot to be used as reference'
	echo '  -d dns : one between inherit(default) or pot'
	echo '  -f flavour : flavour to be used'
	echo '  -t type: single or multi (default multi)'
	echo '         single: the pot is based on a unique ZFS dataset'
	echo '         multi: the pot is composed by a classical collection of 3 ZFS dataset'
	echo '  -N network-type: one of those'
	echo '         inherit: inherit the host network stack (default)'
	echo '         alias: use a static ip as alias configured directly to the host NIC'
	echo '         public-bridge: use the internal commonly public bridge'
	echo '         private-bridge: use an internal private bridge (with option -B)'
	echo '  -i ipaddr : an ip address or the keyword auto (if compatible with the network-type)'
	echo '         auto: usable with public-bridge and private-bridge (default)'
	echo '         ipaddr: mandatory with alias, usable with public-bridge and private-bridge'
	echo '  -B bridge-name : the name of the bridge to be used (private-bridge only)'
	echo '  -I netif : network interface to be used instead of the default one (optional, alias only)'
}

_cj_undo_create()
{
	_POT_VERBOSITY=0
	if [ -z "$_cleanup_pname" ]; then
		${EXIT} 1
	fi
	if [ "$_cleanup_keep" = "YES" ]; then
		pot-cmd stop "$_cleanup_pname"
	else
		pot-cmd destroy -Fp "$_cleanup_pname" -q
	fi
	${EXIT} 1
}

# $1 pot name
# $2 type
# $3 level
# $4 base name
# $5 pot-base name
_cj_zfs()
{
	# shellcheck disable=SC2039
	local _pname _base _type _potbase _jdset _snap _dset
	_pname=$1
	_type=$2
	_lvl=$3
	_base=$4
	_potbase=$5
	_jdset=${POT_ZFS_ROOT}/jails/$_pname
	# Create the main jail zfs dataset
	if ! _zfs_dataset_valid "$_jdset" ; then
		if ! zfs create "$_jdset" ; then
			_error "create: failed to create $_jdset dataset"
			_cj_undo_create
			return 1
		fi
	else
		_info "$_jdset exists already"
	fi
	if [ "$_type" = "single" ]; then
		if [ -z "$_potbase" ]; then
			# create an empty dataset
			if ! zfs create "$_jdset/m" ; then
				_error "create: failed to create $_jdset/m dataset"
				_cj_undo_create
				return 1
			fi
			# create the minimum needed tree
			mkdir -p "${POT_FS_ROOT}/jails/$_pname/m/tmp"
			chmod 1777 "${POT_FS_ROOT}/jails/$_pname/m/tmp"
			mkdir -p "${POT_FS_ROOT}/jails/$_pname/m/dev"
		else
			# clone the last snapshot of _potbase
			_dset=${POT_ZFS_ROOT}/jails/$_potbase/m
			_snap=$(_zfs_last_snap "$_dset")
			if [ -n "$_snap" ]; then
				_debug "Clone zfs snapshot $_dset@$_snap"
				if ! zfs clone -o mountpoint="${POT_FS_ROOT}/jails/$_pname/m" "$_dset@$_snap" "$_jdset/m" ; then
					_error "create: zfs clone failed"
					_cj_undo_create
					return 1 # false
				fi
			else
				# TODO - autofix
				_error "no snapshot found for $_dset/m"
				_cj_undo_create
				return 1 # false
			fi
		fi
		return 0
	# Create the root mountpoint
	elif [ ! -d "${POT_FS_ROOT}/jails/$_pname/m" ]; then
		mkdir -p "${POT_FS_ROOT}/jails/$_pname/m"
	fi

	# lvl 0 images mount directly usr.local and custom
	if [ "$_lvl" = "0" ]; then
		return 0 # true
	fi

	# usr.local
	if [ "$_lvl" -eq 1 ]; then
		# lvl 1 images clone usr.local dataset
		if ! _zfs_dataset_valid "$_jdset/usr.local" ; then
			if [ -n "$_potbase" ]; then
				_dset=${POT_ZFS_ROOT}/jails/$_potbase
			else
				_dset=${POT_ZFS_ROOT}/bases/$_base
			fi
			_snap=$(_zfs_last_snap "$_dset/usr.local")
			if [ -n "$_snap" ]; then
				_debug "Clone zfs snapshot $_dset/usr.local@$_snap"
				if ! zfs clone -o mountpoint="${POT_FS_ROOT}/jails/$_pname/usr.local" "$_dset/usr.local@$_snap" "$_jdset/usr.local" ; then
					_error "create: zfs clone failed"
					_cj_undo_create
					return 1 # false
				fi
			else
				# TODO - autofix
				_error "no snapshot found for $_dset/usr.local"
				return 1 # false
			fi
		else
			_info "$_jdset/usr.local exists already"
		fi
	fi

	# custom dataset
	if ! _zfs_dataset_valid "$_jdset/custom" ; then
		if [ -n "$_potbase" ]; then
			_dset=${POT_ZFS_ROOT}/jails/$_potbase/custom
		else
			_dset=${POT_ZFS_ROOT}/bases/$_base/custom
		fi
		_snap=$(_zfs_last_snap "$_dset")
		if [ -n "$_snap" ]; then
			_debug "Clone zfs snapshot $_dset@$_snap"
			if ! zfs clone -o mountpoint="${POT_FS_ROOT}/jails/$_pname/custom" "$_dset@$_snap" "$_jdset/custom" ; then
					_error "create: zfs clone failed"
					_cj_undo_create
					return 1 # false
			fi
		else
			# TODO - autofix
			_error "no snapshot found for $_dset"
			return 1 # false
		fi
	else
		_info "$_jdset/custom exists already"
	fi
	return 0 # true
}

# $1 pot name
# $2 base name
# $3 network type
# $4 ip
# $5 level
# $6 dns
# $7 type
# $8 private bridge (if network tpye is private_bridge"
# $9 pot-base name
# $10 network interface (relevant for alias)
_cj_conf()
{
	# shellcheck disable=SC2039
	local _pname _base _ip _network_type _lvl _jdir _bdir _potbase _dns _type _pblvl _pbpb
	# shellcheck disable=SC2039
	local _jdset _bdset _pbdset _baseos _bridge_name _alias_netif
	_pname=$1
	_base=$2
	_network_type=$3
	_ip=$4
	_lvl=$5
	_dns=$6
	_type=$7
	_bridge_name=$8
	_potbase=$9
	_alias_netif=${10}
	_jdir=${POT_FS_ROOT}/jails/$_pname
	_bdir=${POT_FS_ROOT}/bases/$_base

	_jdset=${POT_ZFS_ROOT}/jails/$_pname
	_bdset=${POT_ZFS_ROOT}/bases/$_base
	if [ -n "$_potbase" ]; then
		_pblvl=$( _get_conf_var "$_potbase" pot.level )
		_pbdset=${POT_ZFS_ROOT}/jails/$_potbase
	else
		_pblvl=
	fi
	if [ ! -d "$_jdir/conf" ]; then
		mkdir -p "$_jdir/conf"
	fi
	(
	if [ "$_type" = "multi" ]; then
		case $_lvl in
		0)
			echo "$_bdset ${_jdir}/m"
			echo "$_bdset/usr.local ${_jdir}/m/usr/local"
			echo "$_bdset/custom ${_jdir}/m/opt/custom"
			;;
		1)
			echo "$_bdset ${_jdir}/m ro"
			echo "$_jdset/usr.local ${_jdir}/m/usr/local zfs-remount"
			echo "$_jdset/custom ${_jdir}/m/opt/custom zfs-remount"
			;;
		2)
			echo "$_bdset ${_jdir}/m ro"
			if [ $_pblvl -eq 1 ]; then
				echo "$_pbdset/usr.local ${_jdir}/m/usr/local ro"
			else
				_pbpb=$( _get_conf_var $_potbase pot.potbase )
				echo "${POT_ZFS_ROOT}/jails/$_pbpb/usr.local ${_jdir}/m/usr/local ro"
			fi
			echo "$_jdset/custom ${_jdir}/m/opt/custom zfs-remount"
			;;
		esac
	fi
	) > "$_jdir/conf/fscomp.conf"
	(
		if [ "$_type" = "multi" ]; then
			_baseos=$( cat $_bdir/.osrelease )
		else
			_baseos="${_base}"
		fi
		echo "pot.level=${_lvl}"
		echo "pot.type=${_type}"
		echo "pot.base=${_base}"
		echo "pot.potbase=${_potbase}"
		echo "pot.dns=${_dns}"
		echo "pot.cmd=sh /etc/rc"
		echo "host.hostname=\"${_pname}.$( hostname )\""
		if echo "$_baseos" | grep -q "RC" ; then
			echo "osrelease=\"${_baseos}\""
		elif echo "$_baseos" | grep -q "RELEASE" ; then
			echo "osrelease=\"${_baseos}\""
		else
			echo "osrelease=\"${_baseos}-RELEASE\""
		fi
		echo "pot.attr.no-rc-script=NO"
		echo "pot.attr.persistent=YES"
		echo "pot.attr.start-at-boot=NO"
		echo "pot.attr.procfs=NO"
		echo "pot.attr.prunable=NO"
		echo "network_type=$_network_type"
		case $_network_type in
		"inherit")
			echo "vnet=false"
			;;
		"alias")
			echo "vnet=false"
			echo "ip=${_ip}"
			if [ -n "${_alias_netif}" ]; then
				echo "alias_netif=${_alias_netif}"
			fi
			;;
		"public-bridge")
			echo "vnet=true"
			echo "ip=${_ip}"
			;;
		"private-bridge")
			echo "vnet=true"
			echo "ip=${_ip}"
			echo "bridge=${_bridge_name}"
			;;
		esac
		if [ "${_dns}" = "pot" ]; then
			echo "pot.depend=${POT_DNS_NAME}"
		fi
	) > $_jdir/conf/pot.conf
	if [ "$_lvl" -eq 2 ]; then
		if [ $_pblvl -eq 1 ]; then
			# CHANGE the potbase usr.local to be not zfs-remount
			# Add an info here would be nice
			if [ -w "${POT_FS_ROOT}/jails/$_potbase/conf/fscomp.conf" ]; then
				_info "${POT_FS_ROOT}/jails/$_potbase/conf/fscomp.conf fix (${POT_FS_ROOT}/jails/$_potbase/m/usr/local zfs-remount)"
				${SED} -i '' s%${POT_FS_ROOT}/jails/$_potbase/m/usr/local\ zfs-remount%${POT_FS_ROOT}/jails/$_potbase/m/usr/local% ${POT_FS_ROOT}/jails/$_potbase/conf/fscomp.conf
			else
				_info "$_potbase fscomp.conf has not fscomp.conf"
			fi
		fi
	fi
	if [ "$_type" = "multi" ]; then
		_cj_internal_conf "$_pname" "$_type" "$_lvl" "$_ip"
	fi
}

# $1 pot name
# $2 type
# $3 level
# $4 ip
_cj_internal_conf()
{
	local _pname _type _lvl _ip _jdir
	_pname=$1
	_type=$2
	_lvl=$3
	_ip=$4
	_jdir=${POT_FS_ROOT}/jails/$_pname
	if [ "$_type" = "multi" ]; then
		_etcdir="${POT_FS_ROOT}/jails/$_pname/custom/etc"
	else
		_etcdir="${POT_FS_ROOT}/jails/$_pname/m/etc"
	fi

	# disable some cron jobs, not relevant in a jail
	if [ "$_type" = "single" ] || [ "$_lvl" -ne 0 ]; then
		${SED} -i '' 's/^.*save-entropy$/# &/g' "${_etcdir}/crontab"
		${SED} -i '' 's/^.*adjkerntz.*$/# &/g' "${_etcdir}/crontab"
	fi

	# TODO: to be verified
	# add remote syslogd capability, if not inherit
	if [ "$_ip" != "inherit" ]; then
		# configure syslog in the pot
		${SED} -i '' 's%^[^#].*/var/log.*$%# &%g' "${_etcdir}/syslog.conf"
		echo "*.*  @${POT_GATEWAY}:514" > "${_etcdir}/syslog.d/pot.conf"
		if [ ! -r "${_etcdir}/rc.conf" ]; then
			touch "${_etcdir}/rc.conf"
		fi
		sysrc -f "${_etcdir}/rc.conf" "syslogd_flags=-vv -s -b $_ip" > /dev/null
		# configure syslogd in the host
		(
			echo +"$_ip"
			echo '*.*		'"/var/log/pot/${_pname}.log"
		) > /usr/local/etc/syslog.d/"${_pname}".conf
		touch /var/log/pot/"${_pname}".log
		(
			echo "# log rotation for pot ${_pname}"
			echo "/var/log/pot/${_pname}.log 644 7 * @T00 CX"
		) > /usr/local/etc/newsyslog.conf.d/"${_pname}".conf
		service syslogd reload
	fi
}

# Special version of set-cmd usable only for flavours
# $1 : pot name
# $2 : the set-cmd line in the file
_cj_flv_set_cmd()
{
	# shellcheck disable=SC2039
	local _pname _line _cmd
	_pname="$1"
	_line="$2"
	_cmd="${_line#set-cmd -c }"
	if [ "$_line" = "$_cmd" ]; then
		_error "In flavour only 'set-cmd -c ' is supported"
		return
	fi
	_set_command "$_pname" "$_cmd"
}

# $1 pot name
# $2 flavour name
_cj_flv()
{
	# shellcheck disable=SC2039
	local _pname _flv _pdir
	_pname=$1
	_flv=$2
	_pdir=${POT_FS_ROOT}/jails/$_pname
	_debug "Flavour: $_flv"
	if [ -r "${_POT_FLAVOUR_DIR}/${_flv}" ]; then
		_debug "Executing $_flv pot commands on $_pname"
		while read -r line ; do
			if _is_cmd_flavorable $line ; then
				if [ "$line" != "${line#set-cmd}" ]; then
					# workaround for set-cmd / damn quoting and shell script
					_cj_flv_set_cmd "$_pname" "$line"
				else
					# shellcheck disable=SC2086
					pot-cmd $line -p "$_pname"
				fi
			else
				_error "Flavor $_flv: line $line not valid - ignoring"
			fi
		done < "${_POT_FLAVOUR_DIR}/${_flv}"
	fi
	if [ -x "${_POT_FLAVOUR_DIR}/${_flv}.sh" ]; then
		_debug "Starting $_pname pot for the initial bootstrap"
		pot-cmd start "$_pname"
		cp -v "${_POT_FLAVOUR_DIR}/${_flv}.sh" "$_pdir/m/tmp"
		_debug "Executing $_flv script on $_pname"
		if ! jexec "$_pname" "/tmp/${_flv}.sh" "$_pname" ; then
			_error "create: flavour $_flv failed (script)"
			_cj_undo_create
			return 1
		fi
		pot-cmd stop "$_pname"
	else
		_debug "No shell script available for the flavour $_flv"
	fi
}

# $1 pot name
# $2 freebsd version
_cj_single_install()
{
	local _pname _base _proot _rel
	_pname=$1
	_base=$2
	_proot=${POT_FS_ROOT}/jails/$_pname/m
	_info "Fetching FreeBSD $_base"
	if ! _fetch_freebsd "$_base" ; then
		_error "FreeBSD $_base fetch failed - try to continue"
		_cj_undo_create
		return 1 # false
	fi
	if echo "$_base" | grep -q "RC" ; then
		_rel="$_base"
	else
		_rel="$_base"-RELEASE
	fi
	if [ ! -r "/tmp/${_rel}_base.txz" ]; then
		_error "FreeBSD base tarball /tmp/${_rel}_base.txz is missing"
		_cj_undo_create
		return 1 # falase
	fi
	(
	  cd "$_proot"
	  _info "Extract the tarball"
	  tar xkf "/tmp/${_rel}_base.txz"
	  if [ ! -d usr/home ]; then
		  mkdir -p usr/home
	  fi
	  if [ ! -e home ]; then
		  ln -s usr/home home
	  fi
	)
	return 0
}

pot-create()
{
	# shellcheck disable=SC2039
	local _pname _ipaddr _lvl _base _flv _potbase _dns _type _new_lvl _network_type _private_bridge _alias_netif
	OPTIND=1
	_type="multi"
	_network_type="inherit"
	_pname=
	_base=
	_ipaddr=
	_lvl=1
	_new_lvl=
	_flv=
	_potbase=
	_dns=inherit
	_private_bridge=
	_cleanup_keep="NO"
	while getopts "hvp:t:N:i:l:b:f:P:d:B:I:k" _o ; do
		case "$_o" in
		h)
			create-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		k)
			_cleanup_keep="YES"
			;;
		p)
			_pname="$OPTARG"
			;;
		t)
			if [ "$OPTARG" = "multi" ] || [ "$OPTARG" = "single" ]; then
				_type="$OPTARG"
			else
				_error "Type $OPTARG not supported"
				create-help
				${EXIT} 1
			fi
			;;
		N)
			if ! _is_in_list "$OPTARG" $_POT_NETWORK_TYPES ; then
				_error "Network type $OPTARG not recognized"
				create-help
				${EXIT} 1
			fi
			_network_type="$OPTARG"
			;;
		B)
			_private_bridge="$OPTARG"
			;;
		i)
			_ipaddr="$OPTARG"
			;;
		l)
			_lvl="$OPTARG"
			_new_lvl="$OPTARG"
			;;
		b)
			_base=$OPTARG
			;;
		P)
			_potbase=$OPTARG
			;;
		d)
			case $OPTARG in
				"inherit")
					;;
				"pot")
					_dns=pot
					;;
				*)
					_error "The dns $OPTARG is not a valid option: choose between inherit or pot"
					create-help
					${EXIT} 1
			esac
			;;
		f)
			if ! _is_flavourdir ; then
				_error "The flavour dir is missing"
				${EXIT} 1
			fi
			if _is_flavour "$OPTARG" ; then
				if [ -z "$_flv" ]; then
					_flv=$OPTARG
				else
					_flv="$_flv $OPTARG"
				fi
			else
				_error "The flavour $OPTARG not found"
				_debug "Looking in the flavour dir ${_POT_FLAVOUR_DIR}"
				${EXIT} 1
			fi
			;;
		I)
			if ! _is_valid_netif "$OPTARG" ; then
				_error "Network interface $OPTARG not found"
				create-help
				${EXIT} 1
			fi
			_alias_netif="$OPTARG"
			;;
		*)
			create-help
			${EXIT} 1
			;;
		esac
	done
	# check options consitency
	if [ "$_type" = "single" ]; then
		if [ -n "$_new_lvl" ] && [ "$_new_lvl" != "0" ]; then
			_error "single pot level can only be zero (omit -l option)"
			create-help
			${EXIT} 1
		fi
		_lvl=0
		if [ -n "$_potbase" ]; then
			if ! _is_pot "$_potbase" quiet ; then
				_error "pot $_potbase not found"
				create-help
				${EXIT} 1
			fi
			if [ "$( _get_pot_type "$_potbase" )" != "single" ]; then
				_error "pot $_potbase has the wrong type, it has to be of type single"
				create-help
				${EXIT} 1
			fi
			if [ -z "$_base" ]; then
				_base="$( _get_pot_base "$_potbase" )"
			elif [ "$( _get_pot_base "$_potbase" )" != "$_base" ]; then
				_error "-b $_base and -P $_potbase are not compatible"
				create-help
				${EXIT} 1
			fi
		else
		   	if [ -z "$_base" ]; then
				_error "at least one of -b and -P has to be used"
				create-help
				${EXIT} 1
			fi
			if ! _is_valid_release "$_base" ; then
				_error "$_base is not a valid release"
				create-help
				${EXIT} 1
			fi
		fi
	else
		case $_lvl in
				0)
				if [ -z "$_base" ]; then
					_error "level $_lvl needs option -b"
					create-help
					${EXIT} 1
				fi
				if [ -n "$_potbase" ]; then
					_error "-P option is not allowed with level $_lvl"
					create-help
					${EXIT} 1
				fi
				if ! _is_base "$_base" quiet ; then
					_error "$_base is not a valid base"
					create-help
					${EXIT} 1
				fi
				;;
			1)
				if [ -z "$_base" -a -z "$_potbase" ]; then
					_error "at least one of -b and -P has to be used"
					create-help
					${EXIT} 1
				fi
				if [ -n "$_base" -a -n "$_potbase" ]; then
					if [ "$( _get_pot_base $_potbase )" != "$_base" ]; then
						_error "-b $_base and -P $_potbase are not compatible"
						create-help
						${EXIT} 1
					fi
					# TODO: an info or debug message che be showned
				fi
				if [ -n "$_potbase" ]; then
					if ! _is_pot $_potbase ; then
						_error "-P $_potbase : is not a pot"
						create-help
						${EXIT} 1
					fi
					if [ "$( _get_conf_var $_potbase pot.level )" != "1" ]; then
						_error "-P $_potbase : it has to be of level 1"
						create-help
						${EXIT} 1
					fi
				fi
				if [ -z "$_base" ]; then
					_base=$( _get_pot_base $_potbase )
					if [ -z "$_base" ]; then
						_error "-P $potbase has no base??"
						${EXIT} 1
					fi
					_debug "-P $_potbase induced -b $_base"
				fi
				if ! _is_base "$_base" quiet ; then
					_error "$_base is not a valid base"
					create-help
					${EXIT} 1
				fi
				;;
			2)
				if [ -z "$_potbase" ]; then
					_error "level $_lvl pots need another pot as reference"
					create-help
					${EXIT} 1
				fi
				if [ $( _get_conf_var $_potbase pot.level ) -lt 1 ]; then
					_error "-P $_potbase : it has to be at least of level 1"
					create-help
					${EXIT} 1
				fi
				if ! _is_pot $_potbase ; then
					_error "-P $_potbase : is not a pot"
					create-help
					${EXIT} 1
				fi
				if [ -n "$_base" ]; then
					if ! _is_base "$_base" quiet ; then
						_error "$_base is not a valid base"
						create-help
						${EXIT} 1
					fi
					if [ "$( _get_pot_base $_potbase )" != "$_base" ]; then
						_error "-b $_base and -P $_potbase are not compatible"
						${EXIT} 1
					fi
				else
					_base=$( _get_pot_base $_potbase )
					if [ -z "$_base" ]; then
						_error "-P $potbase has no base??"
						${EXIT} 1
					fi
					if ! _is_base "$_base" quiet ; then
						_error "$_base (induced by the pot $_potbase) is not a valid base"
						create-help
						${EXIT} 1
					fi
				fi
				;;
			*)
				_error "level $_lvl is not supported"
				${EXIT} 1
				;;
		esac
	fi
	if [ -z "$_pname" ]; then
		_error "pot name is missing"
		create-help
		${EXIT} 1
	fi
	if _is_pot "$_pname" quiet ; then
		_error "pot $_pname already exists"
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	case "$_network_type" in
	"inherit")
		if [ -n "$_ipaddr" ]; then
			_info "option -i is ignored when network type is inherit"
		fi
		_ipaddr="inherit"
		;;
	"alias")
		if [ -z "$_ipaddr" ]; then
			_error "option -i is mandatory with network type is alias"
			${EXIT} 1
		elif [ "$_ipaddr" = "auto" ]; then
			_error "-i auto not usable with network type alias - a real IP address has to be provided"
			${EXIT} 1
		elif ! potnet ipcheck -H "$_ipaddr" ; then
			_error "$_ipaddr is not a valid IPv4 or IPv6 address"
			${EXIT} 1
		fi
		;;
	"public-bridge")
		if ! _is_vnet_available ; then
			_error "This kernel doesn't support VIMAGE! No vnet possible"
			${EXIT} 1
		fi
		if ! _is_vnet_up ; then
			_info "No public bridge found! Calling vnet-start to fix the issue"
			pot-cmd vnet-start
		fi
		if [ "$_ipaddr" = "auto" ] || [ -z "$_ipaddr" ]; then
			if ! _is_potnet_available ; then
			   _error "potnet is not available! It's needed by -i auto"
				${EXIT} 1
			fi
			_ipaddr="$(potnet next)"
			_debug "-i auto: assigned $_ipaddr"
		else
			if ! potnet validate -H "$_ipaddr" 2> /dev/null ; then
				_error "The $_ipaddr IP is not valid - run potnet validate -H $_ipaddr for more information"
				${EXIT} 1
			fi
		fi
		;;
	"private-bridge")
		if ! _is_vnet_available ; then
			_error "This kernel doesn't support VIMAGE! No vnet possible"
			${EXIT} 1
		fi
		if [ -z "$_private_bridge" ]; then
			_error "private-bridge network type requires -B option, to specify which private bridge to use"
			${EXIT} 1
		fi
		if ! _is_bridge "$_private_bridge" ; then
			_error "bridge $_private_bridge is not valid. Have you already created it?"
			${EXIT} 1
		fi
		if [ "$_ipaddr" = "auto" ] || [ -z "$_ipaddr" ]; then
			if ! _is_potnet_available ; then
			   _error "potnet is not available! It's needed by -i auto"
				${EXIT} 1
			fi
			_ipaddr="$(potnet next -b "$_private_bridge")"
			_debug "-i auto: assigned $_ipaddr"
		fi
		if ! potnet validate -H "$_ipaddr" -b "$_private_bridge"  2> /dev/null ; then
			_error "The $_ipaddr IP is not valid for bridge $_private_bridge - run potnet validate -H $_ipaddr -b $_private_bridge for more information"
			${EXIT} 1
		fi
		;;
	esac
	if [ -n "$_alias_netif" ] && [ "$_network_type" != "alias" ]; then
		_info "-I option apply only for alias network type! '-I $_alias_netif' ignored"
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
	_info "Creating a new pot"
	_info "pot name    : $_pname"
	_info "type        : $_type"
	_info "base        : $_base"
	_info "pot_base    : $_potbase"
	_info "level       : $_lvl"
	_info "network-type: $_network_type"
	_info "ip          : $_ipaddr"
	_info "bridge      : $_private_bridge"
	_info "dns         : $_dns"
	_info "flavours    : $_flv"
	export _cleanup_pname="$_pname" # for the cleanup function
	export _cleanup_keep
	if ! _cj_zfs "$_pname" "$_type" "$_lvl" "$_base" "$_potbase" ; then
		${EXIT} 1
	fi
	if ! _cj_conf "$_pname" "$_base" "$_network_type" "$_ipaddr" "$_lvl" "$_dns" "$_type" "$_private_bridge" "$_potbase" "$_alias_netif" ; then
		${EXIT} 1
	fi
	if [ "$_type" = "single" ]; then
		if [ -z "$_potbase" ]; then
			_cj_single_install "$_pname" "$_base"
		fi
		_cj_internal_conf "$_pname" "$_type" "0" "$_ipaddr"
	fi
	if [ -n "$_flv" ]; then
		for _f in $_flv ; do
			_cj_flv "$_pname" "$_f"
		done
	fi
}
