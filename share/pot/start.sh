#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

start-help()
{
	cat <<-"EOH"
	pot start [-h] -p potname [pname]
	  -h print this help
	  -v verbose
	  -s take a snapshot before starting the pot
	     snapshots are identified by the epoch
	     all ZFS datasets under the jail dataset are considered
	  -S take a snapshot before starting the pot [DEPRECATED]
	     snapshots are identified by the epoch
	     all ZFS datasets mounted in rw are considered (full)
	  -p potname : the pot to be started

	  pname : the pot to be started if "-p potname" not given
	EOH
}

# $1 pot name
# $2 the network interface, if created
start-cleanup()
{
	local _pname _epaira _epaira2 _ifaces
	_pname=$1
	_epaira=$2
	_epaira2=$3
	_ifaces=
	if [ -z "$_pname" ]; then
		return
	fi
	# doa state will only be set if pot is in state "starting"
	lockf "${POT_TMP:-/tmp}/pot-lock-$_pname" "${_POT_PATHNAME}" \
	  set-status -p "$_pname" -s doa
	if [ -n "$_epaira" ] && _is_valid_netif "$_epaira" ; then
		_ifaces="$_epaira"
	fi
	if [ -n "$_epaira2" ] && _is_valid_netif "$_epaira2" ; then
		_ifaces="$_ifaces:$_epaira2"
	fi
	_ifaces="${_ifaces#:}"

	if [ -n "$_ifaces" ]; then
		pot-cmd stop -p "$_pname" -i "$_ifaces" -s
	else
		pot-cmd stop -p "$_pname" -s
	fi
}

# $1 pot name
_js_dep()
{
	local _pname _depPot
	_pname=$1
	_depPot="$( _get_conf_var "$_pname" pot.depend )"
	if [ -z "$_depPot" ]; then
		return 0 # true
	fi
	for _d in $_depPot ; do
		pot-start "$_d"
	done
	return 0 # true
}

# $1 pot name
_js_resolv()
{
	local _pname _jdir _dns
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	_dns="$(_get_conf_var "$_pname" pot.dns)"
	if [ -z "$_dns" ]; then
		_dns=inherit
	fi
	case "$_dns" in
	"inherit")
		if [ ! -r /etc/resolv.conf ]; then
			_error "No resolv.conf found in /etc"
			return 1 # false
		fi
		if [ -d "$_jdir/m/etc" ]; then
			cp /etc/resolv.conf "$_jdir/m/etc"
		else
			_info "No custom etc directory found, resolv.conf not loaded"
		fi
		;;
	"pot" ) # resolv.conf generation
		_domain="$( _get_conf_var "$_pname" host.hostname | cut -f 2 -d'.' )"
		echo "# Generated by pot" > "$_jdir/m/etc/resolv.conf"
		echo "search $_domain" >> "$_jdir/m/etc/resolv.conf"
		echo "nameserver ${POT_DNS_IP}" >> "$_jdir/m/etc/resolv.conf"
		;;
	"custom")
		if [ ! -r "$_jdir/conf/resolv.conf" ]; then
			_error "No custom resolv.conf! pot configuration corrupted?"
			return 1
		fi
		if [ -d "$_jdir/m/etc" ]; then
			cp "$_jdir/conf/resolv.conf" "$_jdir/m/etc"
		else
			_info "No custom etc directory found, resolv.conf not loaded"
		fi
		;;
	"off")
		;;
	esac
	return 0
}

# tests in start4.sh
# $1 pot name
_js_etc_hosts()
{
	local _pname _phosts _hostname _bridge_name _cfile
	_pname="$1"
	_phosts="${POT_FS_ROOT}/jails/$_pname/m/etc/hosts"
	_hostname="$( _get_conf_var "$_pname" host.hostname )"
	printf "::1 localhost %s\n" "$_hostname" > "$_phosts"
	printf "127.0.0.1 localhost %s\n" "$_hostname" >> "$_phosts"
	if [ "$(_get_conf_var "$_pname" "pot.attr.no-etc-hosts")" = "YES" ]; then
		_debug "Attribute no-etchosts: no additional /etc/hosts entries injected"
	else
		case "$( _get_conf_var "$_pname" network_type )" in
		"public-bridge")
			potnet etc-hosts >> "$_phosts"
			;;
		"private-bridge")
			_bridge_name="$( _get_conf_var "$_pname" bridge )"
			potnet etc-hosts -b "$_bridge_name" >> "$_phosts"
			;;
		esac
	fi
	_cfile="${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"
	grep '^pot.hosts=' "$_cfile" | sed 's/^pot.hosts=//g' >> "$_phosts"
}

# returns interface names of epaira and epairb
# optional prefix, one char
_js_create_epair()
{
	local _epaira _epaira_renamed _epairb _prefix

	_prefix="$1"
	_epaira=$(ifconfig epair create descr "$_pname" group "pot")

	if [ -z "${_epaira}" ]; then
		_error "ifconfig epair failed" >&2
		start-cleanup "$_pname"
		exit 1 # false
	fi

	_epairb="${_epaira%a}b"
	_epaira_renamed=$(ifconfig "$_epaira" name \
	    "$(printf "p%s%x%x" "$_prefix" "$(date +%s)" "$$")")

	if [ -z "${_epaira_renamed}" ]; then
		_error "ifconfig epair rename failed" >&2
		start-cleanup "$_pname" "$_epaira"
		exit 1 # false
	fi

	echo "$_epaira_renamed"
	echo "$_epairb"
}

# $1 pot name
# $2 epaira interface
# $3 epairb interface
_js_vnet()
{
	local _pname _bridge _epaira _epairb _ip
	_pname=$1
	if ! _is_vnet_ipv4_up ; then
		_info "Internal network not found! Calling vnet-start to fix the issue"
		pot-cmd vnet-start
	fi
	_bridge=$(_pot_bridge_ipv4)
	_epaira=$2
	_epairb=$3
	ifconfig "$_epaira" up
	ifconfig "$_bridge" addm "$_epaira"
	_ip=$( _get_ip_var "$_pname" )
	## if norcscript - write a ad-hoc one
	if [ "$(_get_conf_var "$_pname" "pot.attr.no-rc-script")" = "YES" ]; then
		cat >>"${POT_FS_ROOT}/jails/$_pname/m/tmp/tinirc" <<-EOT
		if ! ifconfig ${_epairb} >/dev/null 2>&1; then
		    sleep 1
		    if ! ifconfig ${_epairb} >/dev/null 2>&1; then
		        >&2 echo "Interface ${_epairb} does not exist"
		        exit 1
		    fi
		fi
		ifconfig ${_epairb} inet $_ip netmask $POT_NETMASK
		route add default $POT_GATEWAY
		EOT
	else # use rc scripts
		# set the network configuration in the pot's rc.conf
		if [ -w "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf" ]; then
			sed -i '' '/ifconfig_epair[0-9][0-9]*[ab]=/d' "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf"
		fi
		echo "ifconfig_${_epairb}=\"inet $_ip netmask $POT_NETMASK\"" >> "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf"
		sysrc -f "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf" defaultrouter="$POT_GATEWAY"
	fi
}

# $1 pot name
# $2 epaira interface
# $3 epairb interface
# $4 stack (ipv6 or dual)
_js_vnet_ipv6()
{
	local _pname _bridge _epaira _epairb _ip
	_pname=$1
	if ! _is_vnet_ipv6_up ; then
		_info "Internal network not found! Calling vnet-start to fix the issue"
		pot-cmd vnet-start
	fi
	_bridge=$(_pot_bridge_ipv6)
	_epaira=$2
	_epairb=$3
	ifconfig "$_epaira" up
	ifconfig "$_bridge" addm "$_epaira"
	if [ "$(_get_conf_var "$_pname" "pot.attr.no-rc-script")" = "YES" ]; then
		cat >>"${POT_FS_ROOT}/jails/$_pname/m/tmp/tinirc" <<-EOT
		if ! ifconfig ${_epairb} >/dev/null 2>&1; then
		    sleep 1
		    if ! ifconfig ${_epairb} >/dev/null 2>&1; then
		        >&2 echo "Interface ${_epairb} does not exist"
		        exit 1
		    fi
		fi
		ifconfig ${_epairb} inet6 up accept_rtadv -ifdisabled
		/sbin/rtsol -d ${_epairb}
		EOT
	else # use rc scripts
		# set the network configuration in the pot's rc.conf
		if [ -w "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf" ]; then
			sed -i '' '/ifconfig_epair[0-9][0-9]*[ab]_ipv6/d' "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf"
		fi
		echo "ifconfig_${_epairb}_ipv6=\"inet6 accept_rtadv auto_linklocal -ifdisabled\"" >> "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf"
		sysrc -f "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf" rtsold_enable="YES"
		# Fix a bug in the rtsold rc script in 11.3
		sed -i '' 's/nojail/nojailvnet/' "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.d/rtsold"
	fi
}

# $1 pot name
# $2 epaira interface
# $3 epairb interface
_js_private_vnet()
{
	local _pname _bridge_name _bridge _epaira _epairb _ip _net_size _gateway
	_pname=$1
	_bridge_name="$( _get_conf_var "$_pname" bridge )"
	if ! _is_vnet_ipv4_up "$_bridge_name" ; then
		_debug "No pot bridge found! Calling vnet-start to fix the issue"
		pot-cmd vnet-start -B "$_bridge_name"
	fi
	_bridge="$(_private_bridge "$_bridge_name")"
	_epaira=$2
	_epairb=$3
	ifconfig "$_epaira" up
	ifconfig "$_bridge" addm "$_epaira"
	_ip=$( _get_ip_var "$_pname"  )
	_net_size="$(_get_bridge_var "$_bridge_name" net)"
	_net_size="${_net_size##*/}"
	_gateway="$(_get_bridge_var "$_bridge_name" gateway)"
	## if norcscript - write a ad-hoc one
	if [ "$(_get_conf_var "$_pname" "pot.attr.no-rc-script")" = "YES" ]; then
		cat >>"${POT_FS_ROOT}/jails/$_pname/m/tmp/tinirc" <<-EOT
		if ! ifconfig ${_epairb} >/dev/null 2>&1; then
		    sleep 1
		    if ! ifconfig ${_epairb} >/dev/null 2>&1; then
		        >&2 echo "Interface ${_epairb} does not exist"
		        exit 1
		    fi
		fi
		ifconfig ${_epairb} inet $_ip/$_net_size
		route add default $_gateway
		EOT
	else # use rc scripts
		# set the network configuration in the pot's rc.conf
		if [ -w "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.con"f ]; then
			sed -i '' '/ifconfig_epair/d' "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf"
		fi
		echo "ifconfig_${_epairb}=\"inet $_ip/$_net_size\"" >> "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf"
		sysrc -f "${POT_FS_ROOT}/jails/$_pname/m/etc/rc.conf" defaultrouter="$_gateway"
	fi
}

# $1: exclude list
_js_get_free_rnd_port()
{
	local _min _max excl_ports used_ports rdr_ports rand
	excl_ports="$1"
	_min=$( sysctl -n net.inet.ip.portrange.reservedhigh )
	_min=$(( _min + 1 ))
	_max=$( sysctl -n net.inet.ip.portrange.first )
	_max=$(( _max - 1 ))
	used_ports="$(sockstat -p ${_min}-${_max} -4l | awk '!/USER/ { n=split($6,a,":"); if ( n == 2 ) { print a[2]; }}' | sort -u)"
	anchors="$(pfctl -a pot-rdr -s Anchors)"
	for a in $anchors ; do
		new_ports="$( pfctl -a "$a" -s nat -P | awk '/rdr/ { n=split($0,a," "); for(i=1;i<=n;i++) { if (a[i] == "=" ) { print a[i+1];break;}}}')"
		rdr_ports="$rdr_ports $new_ports"
	done
	rand=$_min
	while [ $rand -le $_max ]; do
		for p in $excl_ports $used_ports $rdr_ports ; do
			if [ "$p" = "$rand" ]; then
				rand=$(( rand + 1 ))
				continue 2
			fi
		done
		echo $rand
		break
	done
}

# $1 pot name
_js_export_ports()
{
	local _pname _ip _ports _excl_list _pot_port _host_port _proto_port _aname _pdir _ncat_opt _to_arg
	_pname=$1
	_ip="$( _get_ip_var "$_pname" )"
	_ports="$( _get_pot_export_ports "$_pname" )"
	if [ -z "$_ports" ]; then
		return
	fi
	_pfrules=$(mktemp "${POT_TMP:-/tmp}/pot_pfrules_${_pname}${POT_MKTEMP_SUFFIX}") || exit 1
	_lo_tunnel="$(_get_conf_var "$_pname" "pot.attr.localhost-tunnel")"
	for _port in $_ports ; do
		_proto_port="tcp"
		if [ "${_port#udp:}" != "${_port}" ]; then
			_proto_port="udp"
			_port="${_port#udp:}"
			_ncat_opt="-u"
		elif [ "${_port#tcp:}" != "${_port}" ]; then
			_proto_port="tcp"
			_port="${_port#tcp:}"
		fi
		_pot_port="$( echo "${_port}" | cut -d':' -f 1)"
		_host_port="$( echo "${_port}" | cut -d':' -f 2)"
		if [ "$_pot_port" = "$_port" ]; then
			_host_port=$( _js_get_free_rnd_port "$_excl_list" )
		fi
		if [ -n "$POT_EXTIF_ADDR" ]; then
			_to_arg="$POT_EXTIF_ADDR"
		else
			_to_arg="($POT_EXTIF)"
		fi

		_debug "Redirect: from $_to_arg : $_proto_port:$_host_port to $_ip : $_proto_port:$_pot_port"
		echo "rdr pass on $POT_EXTIF proto $_proto_port from any to $_to_arg port $_host_port -> $_ip port $_pot_port" >> "$_pfrules"
		_excl_list="$_excl_list $_host_port"
		if [ -n "$POT_EXTRA_EXTIF" ]; then
			for extra_netif in $POT_EXTRA_EXTIF ; do
				echo "rdr pass on $extra_netif proto $_proto_port from any to ($extra_netif) port $_host_port -> $_ip port $_pot_port" >> "$_pfrules"
			done
		fi
		if [ "$_lo_tunnel" = "YES" ]; then
			_pdir="${POT_FS_ROOT}/jails/$_pname"
			if [ -x "/usr/local/bin/ncat" ]; then
				cp /usr/local/bin/ncat "$_pdir/ncat-$_pname-$_pot_port"
				daemon -f -p "$_pdir/ncat-$_pot_port.pid" "$_pdir/ncat-$_pname-$_pot_port" -lk $_ncat_opt "$_host_port" -c "/usr/local/bin/ncat $_ncat_opt $_ip $_pot_port"
			else
				_error "nmap package is missing, localhost-tunnel attribute ignored"
			fi
		fi
	done
	_aname="$( _get_pot_rdr_anchor_name "$_pname" )"
	if ! pfctl -a "pot-rdr/$_aname" -f "$_pfrules" ; then
		_error "pfctl failed to apply redirection rules - ignoring but no redirection is performed"
		if _is_verbose ; then
			cat "$_pfrules"
		fi
	fi
	rm -f "$_pfrules"
}

# $1 jail name
_js_rss()
{
	local _pname _jid _cpus _cpuset _memory
	_pname=$1
	_cpus="$( _get_conf_var "$_pname" pot.rss.cpus)"
	_memory="$( _get_conf_var "$_pname" pot.rss.memory)"
	if [ -n "$_cpus" ]; then
		_jid="$( jls -j "$_pname" | sed 1d | awk '{ print $1 }' )"
		_cpuset="$( potcpu get-cpu -n "$_cpus" )"
		cpuset -l "$_cpuset" -j "$_jid"
	fi
	if [ -n "$_memory" ]; then
		if ! _is_rctl_available ; then
			_info "memory constraint cannot be applies because rctl is not enabled - ignoring"
		else
			rctl -a jail:"$_pname":memoryuse:deny="$_memory"
		fi
	fi
}

# $1 pot name
_js_get_cmd()
{
	local _pname _cdir _value
	_pname="$1"
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_value="$( grep "^pot.cmd=" "$_cdir/pot.conf" | sed 's/^pot.cmd=//' )"
	[ -z "$_value" ] && _value="sh /etc/rc"
	echo "$_value"
}

_js_norc()
{
	local _pname
	_pname="$1"
	_cmd="$(_js_get_cmd "$_pname")"
	case "$( _get_conf_var "$_pname" network_type )" in
	"public-bridge"|\
	"private-bridge")
		echo "ifconfig lo0 inet 127.0.0.1 alias" >> "${POT_FS_ROOT}/jails/$_pname/m/tmp/tinirc"
		;;
	esac
	echo "exec $_cmd" >> "${POT_FS_ROOT}/jails/$_pname/m/tmp/tinirc"
	chmod a+x "${POT_FS_ROOT}/jails/$_pname/m/tmp/tinirc"
}

_js_env()
{
	local _pname _shfile _cfile
	_pname="$1"
	_cfile="${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"
	_shfile=$(mktemp "${POT_TMP:-/tmp}/pot_environment_${_pname}${POT_MKTEMP_SUFFIX}") || exit 1
	grep '^pot.env=' "$_cfile" | sed 's/^pot.env=/export /g' > "$_shfile"
	pot-cmd info -E -p "$_pname" >> "$_shfile"
	if [ "$(_get_conf_var "$_pname" "pot.attr.no-rc-script")" = "YES" ]; then
		cat "$_shfile" >> "${POT_FS_ROOT}/jails/$_pname/m/tmp/tinirc"
	else
		cp "$_shfile" "${POT_FS_ROOT}/jails/$_pname/m/tmp/environment.sh"
	fi
	rm -f "$_shfile"
}

# $1 jail name
_js_start()
{
	local _pname _confdir _epaira _epairb _ipv6_epaira _ipv6_epairb
	local _ifaces _hostname _osrelease _param _ip _cmd _persist
	local _stack _value _name _type _wait_pid _exit_code _tmp
	_pname="$1"
	_confdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_param="allow.set_hostname=false allow.raw_sockets allow.socket_af allow.sysvipc"
	_param="$_param allow.chflags exec.clean mount.devfs"
	_param="$_param sysvmsg=new sysvsem=new sysvshm=new"

	for _attr in ${_POT_JAIL_RW_ATTRIBUTES} ; do
		# shellcheck disable=SC1083,2086
		eval _name=\"\${_POT_DEFAULT_${_attr}_N}\"
		# shellcheck disable=SC1083,2086
		eval _type=\"\${_POT_DEFAULT_${_attr}_T}\"
		_value="$(_get_conf_var "$_pname" "pot.attr.${_attr}")"
		if [ "${_value}" = "YES" ]; then
			_param="$_param ${_name}"
		elif [ "${_type}" != "bool" ] && [ -n "${_value}" ]; then
			_param="$_param ${_name}=${_value}"
		fi
	done

	_hostname="$( _get_conf_var "$_pname" host.hostname )"
	_osrelease="$( _get_os_release "$_pname" )"
	_param="$_param name=$_pname host.hostname=$_hostname osrelease=$_osrelease"
	_param="$_param path=${POT_FS_ROOT}/jails/$_pname/m"
	_persist="$(_get_conf_var "$_pname" "pot.attr.persistent")"
	if [ "$_persist" != "NO" ]; then
		_param="$_param persist"
	else
		_param="$_param nopersist"
	fi
	if [ "$(_get_conf_var "$_pname" "pot.attr.no-rc-script")" = "YES" ]; then
		if [ "$( _get_pot_network_stack "$_pname" )" = "ipv4" ]; then
			prec=100
		else
			prec=35
		fi
		cat >>"${POT_FS_ROOT}/jails/$_pname/m/tmp/tinirc" <<-EOT
		if sysctl -n kern.features.inet6 >/dev/null 2>&1; then
		        ip6addrctl flush >/dev/null 2>&1
		        ip6addrctl install /dev/stdin <<EOF
		        ::1/128		 50	 0
		        ::/0		 40	 1
		        ::ffff:0:0/96	 $prec	 4
		        2002::/16	 30	 2
		        2001::/32	  5	 5
		        fc00::/7	  3	13
		        ::/96		  1	 3
		        fec0::/10	  1	11
		        3ffe::/16	  1	12
		EOF
		fi
		EOT
	fi
	case "$( _get_conf_var "$_pname" network_type )" in
	"inherit")
		case "$( _get_pot_network_stack "$_pname" )" in
			"dual")
				_param="$_param ip4=inherit ip6=inherit"
				;;
			"ipv4")
				_param="$_param ip4=inherit"
				;;
			"ipv6")
				_param="$_param ip6=inherit"
				;;
		esac
		;;
	"alias")
		local _ip4addr _ip6addr
		_ip=$( _get_ip_var "$_pname" )
		case "$( _get_pot_network_stack "$_pname" )" in
			"dual")
				_ip4addr="$( _get_alias_ipv4 "$_pname" "$_ip" )"
				_ip6addr="$( _get_alias_ipv6 "$_pname" "$_ip" )"
				if [ -n "$_ip4addr" ]; then
					_param="$_param ip4.addr=$_ip4addr"
				fi
				if [ -n "$_ip6addr" ]; then
					_param="$_param ip6.addr=$_ip6addr"
				fi
				;;
			"ipv4")
				_ip4addr="$( _get_alias_ipv4 "$_pname" "$_ip" )"
				if [ -n "$_ip4addr" ]; then
					_param="$_param ip4.addr=$_ip4addr"
				else
					_error "No ipv4 address found for $_pname"
					start-cleanup "$_pname"
					return 1 # false
				fi
				;;
			"ipv6")
				_ip6addr="$( _get_alias_ipv6 "$_pname" "$_ip" )"
				if [ -n "$_ip6addr" ]; then
					_param="$_param ip6.addr=$_ip6addr"
				else
					_error "No ipv6 address found for $_pname"
					start-cleanup "$_pname"
					return 1 # false
				fi
				;;
		esac
		;;
	"public-bridge")
		_param="$_param vnet"
		_stack="$( _get_pot_network_stack "$_pname" )"
		if [ "$_stack" = "dual" ] || [ "$_stack" = "ipv4" ]; then
			_tmp="$( _js_create_epair '4' )" || return 1
			# shellcheck disable=SC2086
			set -- $_tmp

			_epaira=$1
			_epairb=$2
			_js_vnet "$_pname" "$_epaira" "$_epairb"
			_param="$_param vnet.interface=${_epairb}"
			_js_export_ports "$_pname"
		fi
		if [ "$_stack" = "dual" ] || [ "$_stack" = "ipv6" ]; then
			_tmp="$( _js_create_epair '6' )" || return 1
			# shellcheck disable=SC2086
			set -- $_tmp

			_ipv6_epaira=$1
			_ipv6_epairb=$2
			_js_vnet_ipv6 "$_pname" "$_ipv6_epaira" \
			  "$_ipv6_epairb" "$_stack"
			_param="$_param vnet.interface=${_ipv6_epairb}"
		fi
		;;
	"private-bridge")
		_tmp="$( _js_create_epair '4' )" || return 1
		# shellcheck disable=SC2086
		set -- $_tmp

		_epaira=$1
		_epairb=$2
		_js_private_vnet "$_pname" "$_epaira" "$_epairb"
		_param="$_param vnet vnet.interface=${_epairb}"
		_js_export_ports "$_pname"
		;;
	esac
	_ifaces="$_epaira:$_ipv6_epaira"
	_ifaces="${_ifaces#:}"
	_js_env "$_pname"
	if [ "$(_get_conf_var "$_pname" "pot.attr.no-rc-script")" = "YES" ]; then
		_js_norc "$_pname"
		_cmd=/tmp/tinirc
	else
		_cmd="$( _js_get_cmd "$_pname" )"
	fi
	if [ -x "$_confdir/prestart.sh" ]; then
		_info "Executing the pre-start script for the pot $_pname"
		(
			# shellcheck disable=SC2046
			eval $( pot info -E -p "$_pname" )
			"$_confdir/prestart.sh"
		)
	fi

	rm -f "${POT_TMP:-/tmp}/pot_main_pid_${_pname}"

	_info "Starting the pot $_pname"
	# shellcheck disable=SC2086
	jail -c $_param exec.start="sh -c 'sleep 1234&'"

	if [ -e "$_confdir/pot.conf" ] && _is_pot_prunable "$_pname" ; then
		# set-attr cannot be used for read-only attributes
		${SED} -i '' -e "/^pot.attr.to-be-pruned=.*/d" \
		    "$_confdir/pot.conf"
		echo "pot.attr.to-be-pruned=YES" >> "$_confdir/pot.conf"
	fi

	if _is_pot_running "$_pname" ; then
		_js_rss "$_pname"
	fi

	# shellcheck disable=SC2086
	jexec "$_pname" $_cmd &
	_wait_pid=$!

	if [ -x "$_confdir/poststart.sh" ]; then
		_info "Executing the post-start script for the pot $_pname"
		(
			# shellcheck disable=SC2046
			eval $( pot info -E -p "$_pname" )
			"$_confdir/poststart.sh"
		)
	fi

	sleep 0.5
	pkill -f -j "$_pname" "^sleep 1234$"

	if [ "$_persist" = "NO" ]; then
		echo "$_wait_pid" >"${POT_TMP:-/tmp}/pot_main_pid_${_pname}"
	fi
	# Here is where the pot is marked as started
	lockf "${POT_TMP:-/tmp}/pot-lock-$_pname" "${_POT_PATHNAME}" set-status \
	  -p "$_pname" -s started -i "$_ifaces"
	rc=$?
	if [ $rc -eq 2 ]; then
		_info "pot $_pname is already started (???)"
	elif [ $rc -eq 1 ]; then
		# should we retry (in case it's stopping?)
		_error "pot $_pname is not in a state where it can be started"
		# not returning, it could be catastrophic, but the situation is quite messed up
	fi

	wait "$_wait_pid"
	_exit_code=$?

	echo "{ \"ExitCode\": $_exit_code }" > "$_confdir/.last_run_stats"

	if [ "$_persist" = "NO" ]; then
		rm -f "${POT_TMP:-/tmp}/pot_main_pid_${_pname}"
		# non-persistent jails always need to die
		# Here is where the pot is stopping
		lockf "${POT_TMP:-/tmp}/pot-lock-$_pname" "${_POT_PATHNAME}" set-status -p "$_pname" -s stopping
		rc=$?
		if [ $rc -eq 2 ]; then
			_debug "pot $_pname is already stopping (maybe by a pot stop)"
			return 0
		elif [ $rc -eq 1 ]; then
			# should we retry (in case it's stopping?)
			_error "pot $_pname is not in a state where it can be stopped"
			# returning, but the situation is quite messed up
			return 1
		fi
		start-cleanup "$_pname" "${_epaira}" "${_ipv6_epaira}"
		if [ "$_exit_code" -ne 0 ]; then
			# return code to signal application exit error
			return 125
		fi
	elif ! _is_pot_running "$_pname" ; then
		# persistent jail didn't come up, this is an error
		lockf "${POT_TMP:-/tmp}/pot-lock-$_pname" "${_POT_PATHNAME}" set-status -p "$_pname" -s stopping
		rc=$?
		if [ $rc -eq 2 ]; then
			_debug "pot $_pname is already stopping (maybe by a pot stop?)"
			return 0
		fi
		if [ $rc -eq 1 ]; then
			# should we retry (in case it's stopping?)
			_error "pot $_pname is not in a state where it can be stopped"
			# returning, but the situation is quite messed up
			return 1
		fi
		start-cleanup "$_pname" "${_epaira}" "${_ipv6_epaira}"
		return 1
	fi
}

pot-start()
{
	local _pname _snap _start_result
	_snap=none
	_pname=
	OPTIND=1
	while getopts "hvsSp:" _o ; do
		case "$_o" in
		h)
			start-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		s)
			_snap=normal
			;;
		S)
			_snap=full
			;;
		p)
			_pname="$OPTARG"
			;;
		*)
			start-help
			${EXIT} 1
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_pname="$( eval echo \$$OPTIND)"
	fi
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		start-help
		return 1
	fi
	if ! _is_pot "$_pname" ; then
		return 1
	fi
	if _is_pot_running "$_pname" ; then
		_debug "pot $_pname is already running"
		return 0
	fi
	## detect obsolete config parameter
	if [ -n "$(_get_conf_var "$_pname" "pot.export.static.ports")" ] ||
		[ -n "$(_get_conf_var "$_pname" "ip4")" ]; then
		_error "Configuration file for $_pname contains obsolete elements"
		_error "Please run pot update-config -p $_pname to fix"
		return 1
	fi
	if [ -n "$(_get_conf_var "$_pname" "pot.rss.cpuset")" ]; then
		_info "Found old cpuset rss limitation - it will be ignored"
		_info "Please run pot update-config -p $_pname to clean up the configuration"
	fi

	if [ "$( _get_pot_network_stack "$_pname" )" = "ipv6" ] && [ "$( _get_conf_var "$_pname" network_type )" = "private-bridge" ]; then
		_error "The framework is configured to run ipv6 only and private-bridge are supported only on ipv4 - abort"
		return 1
	fi
	if [ "$( _get_pot_network_stack "$_pname" )" = "dual" ] && [ "$( _get_conf_var "$_pname" network_type )" = "private-bridge" ]; then
		_info "The framework is configured to run dual stack, but private-bridge are supported only on ipv4 - ipv6 ignored"
	fi
	if _is_pot_vnet "$_pname" ; then
		if ! _is_vnet_available ; then
			_error "This kernel doesn't support VIMAGE! No vnet possible - abort"
			return 1
		fi
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	if ! _is_pot_tmp_dir ; then
		_error "failed to create the POT_TMP directory"
		return 1
	fi

	# Here is where the pot is starting
	lockf "${POT_TMP:-/tmp}/pot-lock-$_pname" "${_POT_PATHNAME}" set-status -p "$_pname" -s starting
	rc=$?
	if [ $rc -eq 2 ]; then
		_error "pot $_pname is already starting"
		return 1
	fi
	if [ $rc -eq 1 ]; then
		# should we retry (in case it's stopping?)
		_error "pot $_pname is not in a state where it can start"
		return 1
	fi

	if ! _js_dep "$_pname" ; then
		_error "dependecy failed to start"
	fi
	case $_snap in
		normal)
			_pot_zfs_snap "$_pname"
			;;
		full)
			_pot_zfs_snap_full "$_pname"
			;;
		none|*)
			;;
	esac
	if ! _pot_mount "$_pname" ; then
		_error "Mount failed "
		start-cleanup "$_pname"
		return 1
	fi
	if ! _js_resolv "$_pname" ; then
		start-cleanup "$_pname"
		return 1
	fi
	_js_etc_hosts "$_pname"
	_js_start "$_pname"
	_start_result=$?
	if [ $_start_result -eq 125 ]; then
		_error "$_pname reported application error"
		return 125
	elif [ $_start_result -ne 0 ]; then
		_error "$_pname failed to start"
		return 1
	fi
	return 0
}
