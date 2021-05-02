#!/bin/sh
:

# shellcheck disable=SC3033
info-help()
{
	echo "pot info [-hvqr] [-p pname|-B bname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quiet'
	echo '  -p pname: pot name'
	echo '  -B bname: bridge name'
	echo '  -r check only if the pot is running'
	echo '  -E print few pot information as environment variables'
	echo '  -s list the available snapshots for the pot'
}

# $! pot name
_info_pot_env()
{
	# shellcheck disable=SC3043
	local _pname _ips _idx _all_ips
	_pname=$1
	echo "export _POT_NAME=$_pname"
	if [ "$( _get_pot_network_type "$_pname" )" != "alias" ]; then
		echo "export _POT_IP=$( _get_ip_var "$_pname" )"
	else
		_all_ips="$( _get_ip_var "$_pname" ) "
		_ips="$( _get_alias_ipv4 "$_pname" "$_all_ips" ) $( _get_alias_ipv6 "$_pname" "$_all_ips" )"
		_idx=0
		_ipvar_list=""
		_nicvar_list=""
		for ip in $_ips ; do
			nic="${ip%%|*}"
			ip="${ip##*|}"
			if [ "$_idx" = "0" ]; then
				echo "export _POT_IP=$ip"
				_ipvar_list="_POT_IP_$_idx"
				_nicvar_list="_POT_NIC_$_idx"
			else
				_ipvar_list="$_ipvar_list\\ _POT_IP_$_idx"
				_nicvar_list="$_nicvar_list\\ _POT_NIC_$_idx"
			fi
			echo "export _POT_IP_$_idx=$ip"
			echo "export _POT_NIC_$_idx=$nic"
			_idx=$(( _idx + 1 ))
		done
		echo "export _POT_IP_LIST=$_ipvar_list"
		echo "export _POT_NIC_LIST=$_nicvar_list"
	fi
	if [ "$( _get_pot_network_type "$_pname" )" = "private-bridge" ]; then
		echo "export _POT_BRIDGE=$( _get_conf_var "$_pname" bridge)"
	fi
	if _is_pot_running "$_pname" ; then
		echo "export _POT_JID=$( jls -j "$_pname" jid )"
	fi
}

# $1 pot name
_info_pot()
{
	# shellcheck disable=SC3043
	local _pname _cdir _lvl _ports _type
	_pname=$1
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_lvl=$( _get_conf_var "$_pname" pot.level)
	_type=$( _get_conf_var "$_pname" pot.type)
	printf "pot name : %s\n" "$_pname"
	printf "\ttype : %s\n" "$_type"
	printf "\tbase : %s\n" "$( _get_conf_var "$_pname" pot.base)"
	printf "\tlevel : %s\n" "$_lvl"
	if [ "$_lvl" -eq 2 ]; then
		printf "\tbase pot : %s\n" "$( _get_conf_var "$_pname" pot.potbase)"
	fi
	printf "\tnetwork_type : %s\n" "$( _get_pot_network_type "$_pname" )"
	if [ "$( _get_pot_network_type "$_pname" )" != "inherit" ]; then
		printf "\tip : %s\n" "$( _get_ip_var "$_pname" )"
		if [ "$( _get_pot_network_type "$_pname" )" = "private-bridge" ]; then
			printf "\tbridge : %s\n" "$( _get_conf_var "$_pname" bridge)"
		fi
		if _is_verbose ; then
			_ports="$( _get_pot_export_ports "$_pname" )"
			if [ -z "$_ports" ]; then
				printf "\t\tno ports exported\n"
			else
				printf "\t\texported ports: %s\n" "$_ports"
			fi
		fi
	fi
	if _is_pot_running "$_pname" ; then
		printf "\tactive : true\n"
	else
		printf "\tactive : false\n"
	fi
	if _is_verbose ; then
		printf "\tdatasets:\n"
		if [ "$_type" = "single" ]; then
			printf "\\t\\t%s\\n" "$_pname/m"
		fi
		_print_pot_fscomp "$_cdir/fscomp.conf"
		printf "\tsnapshots:\n"
		_print_pot_snaps "$_pname"
	fi
	printf "\tattributes:\n"
	for _a in $_POT_RW_ATTRIBUTES $_POT_RO_ATTRIBUTES ; do
		_value=$( _get_conf_var "$_pname" "pot.attr.$_a")
		printf "\t\t%s: %s\n" "$_a" "${_value:-"NO"}"
	done
	printf "\tjail attributes:\n"
	for _a in $_POT_JAIL_RW_ATTRIBUTES ; do
		_value=$( _get_conf_var "$_pname" "pot.attr.$_a")
		if [ -z "$_value" ]; then
			eval _value="\$_POT_DEFAULT_${_a}_D"
		fi
		printf "\t\t%s: %s\n" "$_a" "${_value:-"NO"}"
	done
	if _is_verbose ; then
		_cpu="$( _get_conf_var "$_pname" pot.rss.cpus)"
		_mem="$( _get_conf_var "$_pname" pot.rss.memory)"
		if [ -n "${_cpu}${_mem}" ]; then
			printf "\tresource limits:\n"
			if [ -n "${_cpu}" ]; then
				printf "\t\tmax amount cpus: %s\n" "$_cpu"
			fi
			if [ -n "${_mem}" ]; then
				printf "\t\tmax amount memory: %s\n" "$_mem"
			fi
		fi
	fi
	echo
}

# $1 pot name
_info_pot_snapshots()
{
	# shellcheck disable=SC3043
	local _pname _snaps
	_pname="$1"
	if _is_verbose ; then
		_snaps="$( _get_pot_snaps "$_pname" )"
		for _s in $_snaps ; do
			echo "$_s: -> " "$( date -r "$_s" )"
		done
	else
		_get_pot_snaps "$_pname"
	fi
}

# $1 bridge name
_info_bridge()
{
# shellcheck disable=SC3033
	local _bname
	_bname="$1"
	if _is_potnet_available ; then
		potnet show -b "$_bname"
	else
		_error "potnet is needed to show bridge information"
	fi
}

# shellcheck disable=SC3033
pot-info()
{
	# shellcheck disable=SC3043
	local _pname _quiet _run _bname _env_output _snaps
	_pname=""
	_quiet="NO"
	_run="NO"
	_env_output="NO"
	_snaps="NO"
	OPTIND=1
	while getopts "hvqp:rB:Es" _o ; do
		case "$_o" in
		h)
			info-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_quiet="quiet"
			;;
		p)
			_pname="$OPTARG"
			;;
		B)
			_bname="$OPTARG"
			;;
		r)
			_run="YES"
			;;
		E)
			_env_output="YES"
			;;
		s)
			_snaps="YES"
			;;
		*)
			info-help
			${EXIT} 1
			;;
		esac
	done
	if [ -z "$_pname" ] && [ -z "$_bname" ]; then
		_error "Option -p or -b are mandatory"
		info-help
		${EXIT} 1
	fi
	if [ -n "$_pname" ] && [ -n "$_bname" ]; then
		_error "Option -p and -b are mutually exclusive"
		info-help
		${EXIT} 1
	fi
	if [ "$_quiet" = "quiet" ] && _is_verbose ; then
		_error "Option -q and -v are mutually exclusive"
		info-help
		${EXIT} 1
	fi
	if [ "$_env_output" = "YES" ] && [ -z "$_pname" ]; then
		_error "Environment variable output available for pot only"
		info-help
		${EXIT} 1
	fi
	if [ -n "$_bname" ] && [ "$_snaps" = "YES" ]; then
		_info "Bridges has no snapshots - -s ignored"
		_snaps="NO"
	fi
	if [ -n "$_pname" ]; then
		if ! _is_pot "$_pname" quiet ; then
			_qerror "$_quiet" "$_pname is not a pot"
			info-help
			${EXIT} 1
		fi
		if [ "$_run" = "YES" ]; then
			if _is_pot_running "$_pname" ; then
				${EXIT} 0
			else
				${EXIT} 1
			fi
		fi
		if [ "$_quiet" = "quiet" ]; then
			${EXIT} 0
		fi
		if [ "$_snaps" = "YES" ]; then
			_info_pot_snapshots "$_pname"
		elif [ "$_env_output" = "YES" ]; then
			_info_pot_env "$_pname"
		else
			_info_pot "$_pname"
		fi
	fi
	if [ -n "$_bname" ]; then
		if ! _is_bridge "$_bname" quiet ; then
			_qerror "$_quiet" "$_bname is not a bridge"
			${EXIT} 1
		fi
		if [ "$_quiet" = "quiet" ]; then
			${EXIT} 0
		fi
		_info_bridge "$_bname"
	fi
}
