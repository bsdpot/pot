#!/bin/sh
:

# shellcheck disable=SC3033
update-config-help()
{
	echo "pot update-config [-h] [-p pot|-a]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -a : all the pots'
}

# $1 pname
_get_conf_static_ports()
{
	# shellcheck disable=SC3043
	local _pname _cdir _value
	_pname="$1"
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_value="$( grep "^pot.export.static.ports=" "$_cdir/pot.conf" | cut -f2 -d'=' )"
	echo "$_value"
}

# $1 pname
_update_one_pot()
{
	# shellcheck disable=SC3043
	local _pname _conf _attr _value
	_pname="$1"
	if ! _is_pot "$_pname" ; then
		_error "Invalid pot name"
		return 1
	fi
	_conf="${POT_FS_ROOT}/jails/${_pname}/conf/pot.conf"

	# default configuration values
	if [ -z "$(_get_conf_var "$_pname" pot.dns)" ]; then
		_debug "pot.dns=inherit"
		echo "pot.dns=inherit" >> "$_conf"
	fi
	if [ -z "$(_get_conf_var "$_pname" pot.cmd)" ]; then
		_debug "pot.cmd=sh /etc/rc"
		echo "pot.cmd=sh /etc/rc" >> "$_conf"
	fi

	# default attributes values
	if [ -z "$(_get_conf_var "$_pname" "pot.attr.no-rc-script")" ]; then
		_debug "pot.attr.no-rc-script=NO"
		echo "pot.attr.no-rc-script=NO" >> "$_conf"
	fi
	if [ -z "$(_get_conf_var "$_pname" "pot.attr.persistent")" ]; then
		_debug "pot.attr.persistent=YES"
		echo "pot.attr.persistent=YES" >> "$_conf"
	fi
	if [ -z "$(_get_conf_var "$_pname" "pot.attr.start-at-boot")" ]; then
		_debug "pot.attr.start-at-boot=NO"
		echo "pot.attr.start-at-boot=NO" >> "$_conf"
	fi
	if [ -z "$(_get_conf_var "$_pname" "pot.attr.early.start-at-boot")" ]; then
		_debug "pot.attr.early.start-at-boot=NO"
		echo "pot.attr.early.start-at-boot=NO" >> "$_conf"
	fi

	for _attr in ${_POT_JAIL_RW_ATTRIBUTES} ; do
		if [ -z "$(_get_conf_var "$_pname" "pot.attr.${_attr}")" ]; then
			# shellcheck disable=SC1083,2086
			eval _value=\"\${_POT_DEFAULT_${_attr}_D}\"
			_debug "pot.attr.${_attr}=${_value}"
			echo "pot.attr.${_attr}=${_value}" >> "$_conf"
		fi
	done

	if [ -z "$(_get_conf_var "$_pname" "pot.attr.prunable")" ]; then
		_debug "pot.attr.prunable=NO"
		echo "pot.attr.prunable=NO" >> "$_conf"
	fi
	if [ -z "$(_get_conf_var "$_pname" "pot.attr.localhost-tunnel")" ]; then
		_debug "pot.attr.localhost-tunnel=NO"
		echo "pot.attr.localhost-tunnel=NO" >> "$_conf"
	fi

	# convert pot.export.static.ports=80 to the new format pot.export.ports=80:80
	# being aware that pot.export.ports may already exist
	if [ -n "$(_get_conf_static_ports "$_pname")" ]; then
		_debug "converting exported static ports using the new format"
		_static_ports="$( _get_conf_static_ports "$_pname")"
		${SED} -i '' -e "/pot.export.static.ports=.*/d" "$_conf"
		_new_ports=
		for p in $_static_ports ; do
			if [ -z "$_new_ports" ]; then
				_new_ports="$p:$p"
			else
				_new_ports="$_new_ports $p:$p"
			fi
		done
		if [ -n "$(_get_pot_export_ports "$_pname")" ]; then
			_ports="$(_get_pot_export_ports "$_pname")"
			_new_ports="$_ports $_new_ports"
			${SED} -i '' -e "/pot.export.ports=.*/d" "$_conf"
		fi
		echo "pot.export.ports=$_new_ports" >> "$_conf"
	fi

	# convert ip4 and static entries with the new network_type and ip
	if [ -n "$(_get_conf_var "$_pname" "ip4")" ]; then
		_debug "converting the network configuration using the new format"
		_ip4="$(_get_conf_var "$_pname" "ip4")"
		_vnet="$(_get_conf_var "$_pname" "vnet")"
		${SED} -i '' -e "/ip4=.*/d" "$_conf"
		if [ "$_ip4" = "inherit" ]; then
			echo "network_type=inherit" >> "$_conf"
		else
			if [ "$_vnet" = "false" ]; then
				echo "network_type=alias" >> "$_conf"
			else
				echo "network_type=public-bridge" >> "$_conf"
			fi
			echo "ip=$_ip4" >> "$_conf"
		fi
	fi

	# remove the fixed cpuset rss allocation
	if [ -n "$(_get_conf_var "$_pname" "pot.rss.cpuset")" ]; then
		_info "Removing cpuset rss allocation: $(_get_conf_var "$_pname" "pot.rss.cpuset")"
		_info "rss.cpuset has been deprecated; please use the more generic rss.cpus"
		${SED} -i '' -e "/pot.rss.cpuset=.*/d" "$_conf"
	fi
}

_update_all_pots()
{
	# shellcheck disable=SC3043
	local _pots
	_pots="$( _get_pot_list )"
	for _pname in $_pots ; do
		if ! _update_one_pot "$_pname" ; then
			return 1
		else
			_debug "Updated $_pname configuration"
		fi
	done
}

# shellcheck disable=SC3033
pot-update-config()
{
	# shellcheck disable=SC3043
	local _pname _o _all
	_pname=
	_all=
	OPTIND=1
	while getopts "hvp:a" _o ; do
		case "$_o" in
		h)
			update-config-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		a)
			_all="YES"
			;;
		*)
			update-config-help
			${EXIT} 1
		esac
	done

	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	if [ -n "$_pname" ]; then
		if ! _update_one_pot "$_pname" ; then
			${EXIT} 1
		fi
	elif [ "$_all" = "YES" ]; then
		if ! _update_all_pots ; then
			${EXIT} 1
		fi
	else
		_error "A pot name or -a are mandatory"
		update-config-help
		${EXIT} 1
	fi
	${EXIT} 0
}
