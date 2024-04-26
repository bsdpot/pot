#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043

# tested
_pot_bridge()
{
	_pot_bridge_ipv4
}

_pot_bridge_ipv4()
{
	local _bridges
	_bridges=$( ifconfig -g bridge )
	if [ -z "$_bridges" ]; then
		return
	fi
	for _b in $_bridges ; do
		_ip=$( ifconfig "$_b" inet | awk '/inet/ { print $2 }' )
		if [ "$_ip" = "$POT_GATEWAY" ]; then
			echo "$_b"
			return
		fi
	done
}

_pot_bridge_ipv6()
{
	local _bridges
	_bridges=$( ifconfig -g bridge )
	if [ -z "$_bridges" ]; then
		return
	fi
	for _b in $_bridges ; do
		if ifconfig "$_b" |grep -q "member: $POT_EXTIF" ; then
			echo "$_b"
			return
		fi
	done
}

# $1 bridge name
_private_bridge()
{
	local _bridges _bridge _bridge_ip
	_bridge="$1"
	_bridges=$( ifconfig -g bridge )
	if [ -z "$_bridges" ]; then
		return
	fi
	_bridge_ip="$(_get_bridge_var "$_bridge" gateway)"
	for _b in $_bridges ; do
		_ip=$( ifconfig "$_b" inet | awk '/inet/ { print $2 }' )
		if [ "$_ip" = "$_bridge_ip" ]; then
			echo "$_b"
			return
		fi
	done
}

_get_pot_rdr_anchor_name()
{
	local _pname
	_pname=$1
	if [ "${#_pname}" -gt "55" ]; then
		echo "$_pname" | awk '{ truncated = substr($1, length($1)-54); printf("%s", truncated);}' | sed 's/^__*//'
	else
		echo "$_pname"
	fi
}

_is_vnet_up()
{
	_is_vnet_ipv4_up "$1"
}

# $1 bridge name (optional)
_is_vnet_ipv4_up()
{
	local _bridge
	if [ -z "$1" ]; then
		_bridge=$(_pot_bridge)
	else
		_bridge="$( _private_bridge "$1" )"
	fi
	if [ -z "$_bridge" ]; then
		return 1 # false
	elif [ ! -c /dev/pf ]; then
		return 1 # false
	elif ! pfctl -s Anchors | grep -q '^[ \t]*pot-nat$' ; then
		return 1 # false
	elif ! pfctl -s Anchors | grep -q '^[ \t]*pot-rdr$' ; then
		return 1 # false
	elif [ -z "$(pfctl -s nat -a pot-nat)" ]; then
		return 1 # false
	else
		return 0 # true
	fi
}

_is_vnet_ipv6_up()
{
	local _bridge
	_bridge="$(_pot_bridge_ipv6)"
	if [ -z "$_bridge" ]; then
		return 1 # false
	fi
	return 0
}

# $1 the number to test
_is_port_number()
{
	local _port
	_port=$1
	if [ -z "$_port" ]; then
		return 1
	fi
	# check if it's a number
	if [ -n "$( echo "$_port" | sed 's/[0-9][0-9]*//' )" ]; then
		return 1
	fi
	# check if it's a 16 bit number
	if [ "$_port" -le 0 ] || [ "$_port" -gt 65535 ]; then
		return 1 # false
	fi
	return 0
}

# $1: the -e option argument
_is_export_port_valid()
{
	local _pot_port _host_port _arg
	if [ "${1#tcp:}" != "${1}" ]; then
		_arg="${1#tcp:}"
	elif [ "${1#udp:}" != "${1}" ]; then
		_arg="${1#udp:}"
	else
		_arg="${1}"
	fi
	_pot_port="$( echo "${_arg}" | cut -d':' -f 1)"
	if [ "$_arg" = "${_pot_port}" ]; then
		if ! _is_port_number "$_pot_port" ; then
			return 1 # false
		fi
	else
		_host_port="$( echo "${_arg}" | cut -d':' -f 2)"
		if ! _is_port_number "$_pot_port" ; then
			return 1 # false
		fi
		if ! _is_port_number "$_host_port" ; then
			return 1 # false
		fi
	fi
}

# $1 name of the network interface
_is_valid_netif()
{
	local _netif
	_netif="$1"
	if ifconfig "$_netif" > /dev/null 2> /dev/null ; then
		return 0 # true
	else
		return 1 # false
	fi
}

_is_valid_extif_addr()
{
	local _netif _ip
	_netif="$1"
	_ip="$2"
	ifconfig "$_netif" | grep -F "inet " | grep -qF " $_ip "
}

# get the network stack defined in the global configuration
_get_network_stack()
{
	local _stack
	_stack="${POT_NETWORK_STACK:-ipv4}"
	case $_stack in
		ipv4|ipv6|dual)
			echo "$_stack"
			;;
		*)
			echo ipv4
			return 1
			;;
	esac
}

# get the network stack for the specific pot
# $1 pot name
_get_pot_network_stack()
{
	local _stack _pname
	_pname="$1"
	_stack="$( _get_conf_var "$_pname" pot.stack )"
	if [ -z "$_stack" ]; then
		_get_network_stack
	else
		echo "$_stack"
	fi
}

# $1 pot name
# $2 ipaddr
_get_alias_ipv4()
{
	local _i _ip _nic _output
	_output=
	if [ "$( _get_pot_network_stack "$1" )" != "ipv6" ]; then
		for _i in $2 ; do
			if echo "$_i" | grep -qF '|' ; then
				_nic="$( echo "$_i" | cut -f 1 -d '|' )"
				_ip="$( echo "$_i" | cut -f 2 -d '|' )"
			else
				_nic="$POT_EXTIF"
				_ip="$_i"
			fi
			if potnet ip4check -H "$_ip" 2> /dev/null ; then
				if [ -z "$_output" ]; then
					_output="$_nic|$_ip"
				else
					_output="$_output,$_nic|$_ip"
				fi
			fi
		done
	fi
	echo "$_output"
}

# $1 pot name
# $2 ipaddr
_get_alias_ipv6()
{
	local _i _ip _nic _output
	_output=
	if [ "$( _get_pot_network_stack "$1" )" != "ipv4" ]; then
		for _i in $2 ; do
			if echo "$_i" | grep -qF '|' ; then
				_nic="$( echo "$_i" | cut -f 1 -d '|' )"
				_ip="$( echo "$_i" | cut -f 2 -d '|' )"
			else
				_nic="$POT_EXTIF"
				_ip="$_i"
			fi
			if potnet ip6check -H "$_ip" 2> /dev/null ; then
				if [ -z "$_output" ]; then
					_output="$_nic|$_ip"
				else
					_output="$_output,$_nic|$_ip"
				fi
			fi
		done
	fi
	echo "$_output"
}

# $1 ipaddr
# $2 network stack
_validate_alias_ipaddr()
{
	local _i _nic _ip _ipv4_empty _ipv6_empty _stack
	_stack="$2"
	_ipv4_empty="YES"
	_ipv6_empty="YES"
	for _i in $1 ; do
		if echo "$_i" | grep -qF '|' ; then
			_nic="$( echo "$_i" | cut -f 1 -d '|' )"
			_ip="$( echo "$_i" | cut -f 2 -d '|' )"
			if ! _is_valid_netif "$_nic" ; then
				_error "$_nic is not a valid network interface"
				return 1 # false
			fi
		else
			_ip="$_i"
		fi
		if ! potnet ipcheck -H "$_ip" 2> /dev/null ; then
			_error "$_ip is not a valid IP address"
			return 1 # false
		fi
		if potnet ip4check -H "$_ip" 2> /dev/null ; then
			_ipv4_empty="NO"
		fi
		if potnet ip6check -H "$_ip" 2> /dev/null ; then
			_ipv6_empty="NO"
		fi
	done
	if [ "$_stack" = "ipv4" ] && [ "$_ipv4_empty" = "YES" ]; then
		_error "Stack is ipv4 but not ipv4 address has been provided"
		return 1 # false
	fi
	if [ "$_stack" = "ipv6" ] && [ "$_ipv6_empty" = "YES" ]; then
		_error "Stack is ipv6 but not ipv6 address has been provided"
		return 1 # false
	fi
	return 0
}

# $1 network type
# $2 ipaddr
# $3 bridge-name (private-bridge only)
# $4 network stack
# if success, then print the ip addr (it could be empty)
# otherwise it print the an error message
_validate_network_param()
{
	local _network_type _ipaddr _private_bridge
	_network_type=$1
	_ipaddr=$2
	_private_bridge=$3
	_network_stack=$4
	if [ -z "$_network_stack" ]; then
		_network_stack="$( _get_network_stack )"
	fi
	case "$_network_type" in
	"inherit")
		_ipaddr=
		;;
	"alias")
		if [ -z "$_ipaddr" ]; then
			_error "option -i is mandatory with network type is alias"
			return 1
		elif [ "$_ipaddr" = "auto" ]; then
			_error "-i auto not usable with network type alias - a real IP address has to be provided"
			return 1
		fi
		if ! _validate_alias_ipaddr "$_ipaddr" "$_network_stack" ; then
			_error "$_ipaddr is not a valid alias configuration"
			return 1
		fi
		;;
	"public-bridge")
		if ! _is_vnet_available ; then
			_error "This kernel doesn't support VIMAGE! No vnet possible"
			return 1
		fi
		if [ "$_ipaddr" = "auto" ] || [ -z "$_ipaddr" ]; then
			if ! _is_potnet_available ; then
			   _error "potnet is not available! It's needed by -i auto"
				return 1
			fi
			_ipaddr="$(potnet next)"
		else
			if ! potnet validate -H "$_ipaddr" 2> /dev/null ; then
				_error "The $_ipaddr IP is not valid - run potnet validate -H $_ipaddr for more information"
				return 1
			fi
		fi
		;;
	"private-bridge")
		if ! _is_vnet_available ; then
			_error "This kernel doesn't support VIMAGE! No vnet possible"
			return 1
		fi
		if [ "$_network_stack" = "ipv6" ]; then
			_error "private-bridge network type is not supported on ipv6 stack only"
			return 1
		fi
		if [ -z "$_private_bridge" ]; then
			_error "private-bridge network type requires -B option, to specify which private bridge to use"
			return 1
		fi
		if ! _is_bridge "$_private_bridge" ; then
			_error "bridge $_private_bridge is not valid. Have you already created it?"
			return 1
		fi
		if [ "$_ipaddr" = "auto" ] || [ -z "$_ipaddr" ]; then
			if ! _is_potnet_available ; then
			   _error "potnet is not available! It's needed by -i auto"
				return 1
			fi
			_ipaddr="$(potnet next -b "$_private_bridge")"
		elif ! potnet validate -H "$_ipaddr" -b "$_private_bridge"  2> /dev/null ; then
			_error "The $_ipaddr IP is not valid for bridge $_private_bridge - run potnet validate -H $_ipaddr -b $_private_bridge for more information"
			return 1
		fi
		;;
	*)
		_error "Network type $_network_type not recognized"
		return 1
		;;
	esac
	echo "$_ipaddr"
	return 0
}
