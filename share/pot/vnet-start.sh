#!/bin/sh

vnet-start-help()
{
	echo 'pot vnet-start [-h][-v]'
	echo '  -h -- print this help'
	echo '  -v verbose'
	echo '  -B bridge-name (opional)'
}

_public_bridge_start()
{
	# shellcheck disable=SC2039
	local _bridge
	_bridge=$(_pot_bridge)
	if [ -z "$_bridge" ]; then
		if _bridge=$(ifconfig bridge create) ; then
			_debug "Bridge created $_bridge"
		else
			_error "Bridge not created"
		fi
		if ! ifconfig "$_bridge" inet "$POT_GATEWAY" netmask "$POT_NETMASK" ; then
			_error "Error during bridge configuration ($_bridge)"
		else
			_debug "Bridge $_bridge configured with IP $POT_GATEWAY netmask $POT_NETMASK"
		fi
	else
		_debug "Bridge $_bridge already present"
	fi
}

# $1 bridge_name
_private_bridge_start()
{
	# shellcheck disable=SC2039
	local _bridge_name _bridge _gateway _bridge_net
	_bridge_name="$1"
	_bridge=$(_private_bridge)
	if [ -z "$_bridge" ]; then
		if _bridge=$(ifconfig bridge create) ; then
			_debug "Bridge created $_bridge"
		else
			_error "Bridge not created"
		fi
		_gateway="$(_get_bridge_var "$_bridge_name" gateway)"
		_bridge_net="$(_get_bridge_var "$_bridge_name" net)"
		_bridge_net="${_bridge_net##*/}"
		if ! ifconfig "$_bridge" inet "${_gateway}/${_bridge_net}" ; then
			_error "Error during bridge configuration ($_bridge)"
		else
			_debug "Bridge $_bridge configured with IP ${_gateway}/${_bridge_net}"
		fi
	else
		_debug "Bridge $_bridge already present"
	fi
}

pot-vnet-start()
{
	# shellcheck disable=SC2039
	local _bridge _pfrules _bridge_name
	OPTIND=1
	while getopts "hvB:" _o ; do
		case "$_o" in
		h)
			vnet-start-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		B)
			_bridge_name="$OPTARG"
			;;
		?)
			break
			;;
		esac
	done

	# Check configuration
	if [ -z "${POT_NETWORK}" ] || [ -z "${POT_GATEWAY}" ]; then
		_error "No network or gateway defined"
		exit 1
	fi
	if [ -z "${POT_EXTIF}" ]; then
		_error "No external interface defined"
		exit 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	# activate ip forwarding
	if _is_verbose ; then
		sysctl net.inet.ip.forwarding=1
	else
		sysctl -qn net.inet.ip.forwarding=1 > /dev/null
	fi
	# bridge creation
	if [ -z "$_bridge_name" ]; then
		_public_bridge_start
	elif _is_bridge "$_bridge_name" quiet ; then
		_private_bridge_start "$_bridge_name"
	else
		_error "$_bridge_name is not a valid bridge"
	fi

	# load pf module
	kldload -n pf
	pf_file="$(sysrc -n pf_rules)"
	# check anchors
	if ! pfctl -s Anchors | grep -q '^[ \t]*pot-nat$' ||
		! pfctl -s Anchors | grep -q '^[ \t]*pot-rdr$' ; then
		_debug "Pot anchors are missing - load $pf_file"
		pfctl -f "$pf_file"
	fi
	_nat_rules="/tmp/pot_pf_nat_rules"
	if [ -w "$_nat_rules" ]; then
		rm -f "$_nat_rules"
	fi
	# NAT rules
	(
		echo "ext_if = \"${POT_EXTIF}\""
		echo "localnet = \"${POT_NETWORK}\""
		echo "nat on \$ext_if from \$localnet to any -> (\$ext_if)"
	) > $_nat_rules

	# add vpn support
	if [ -n "$POT_VPN_EXTIF" ] && [ -n "$POT_VPN_NETWORKS" ]; then
		for net in $POT_VPN_NETWORKS ; do
			echo "nat on $POT_VPN_EXTIF from \$localnet to $net -> ($POT_VPN_EXTIF)" >> $_nat_rules
		done
	fi

	pfctl -a pot-nat -f $_nat_rules
	# load the rules
	if _is_verbose ; then
		pfctl -s nat -a pot-nat
	fi
	pfctl -e
}

