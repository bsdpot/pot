#!/bin/sh

vnet-start-help()
{
	echo 'pot vnet-start [-h][-v]'
	echo '  -h -- print this help'
	echo '  -v verbose'
}


pot-vnet-start()
{
	local _bridge _pfrules
	args=$(getopt hv $*)
	if [ $? -ne 0 ]; then
		vnet-start-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			vnet-start-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		--)
			shift
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
	# if bridge0 doesn't exist yet
	_bridge=$(_pot_bridge)
	if [ -z "$_bridge" ]; then
		if _bridge=$(ifconfig bridge create) ; then
			_error "Bridge not created"
		else
			_debug "Bridge created $_bridge"
		fi
		if ! ifconfig "$_bridge" inet "$POT_GATEWAY" netmask "$POT_NETMASK" ; then
			_error "Error during bridge configuration ($_bridge)"
		else
			_debug "Bridge $_bridge configured with IP $POT_GATEWAY netmask $POT_NETMASK"
		fi
	else
		_debug "Bridge $_bridge already present"
	fi

	# load pf module
	kldload -n pf
	# check anchors
	if ! pfctl -s Anchors | grep -q '^[ \t]*pot-nat$' ||
		! pfctl -s Anchors | grep -q '^[ \t]*pot-rdr$' ; then
		_debug "Pot anchors are missing - load pf.conf"
		pfctl -f pf.conf
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

