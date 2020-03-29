#!/bin/sh

_get_network_stack()
{
	# shellcheck disable=SC2039
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

# tested
_pot_bridge()
{
	_pot_bridge_ipv4
}

_pot_bridge_ipv4()
{
	# shellcheck disable=SC2039
	local _bridges
	_bridges=$( ifconfig | grep ^bridge | cut -f1 -d':' )
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
	# shellcheck disable=SC2039
	local _bridges
	_bridges=$( ifconfig | grep ^bridge | cut -f1 -d':' )
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
	# shellcheck disable=SC2039
	local _bridges _bridge _bridge_ip
	_bridge="$1"
	_bridges=$( ifconfig | grep ^bridge | cut -f1 -d':' )
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
	# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
	local _pot_port _host_port
	_pot_port="$( echo "${1}" | cut -d':' -f 1)"
	if [ "$1" = "${_pot_port}" ]; then
		if ! _is_port_number "$OPTARG" ; then
			return 1 # false
		fi
	else
		_host_port="$( echo "${1}" | cut -d':' -f 2)"
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
	# shellcheck disable=SC2039
	local _netif
	_netif="$1"
	if ifconfig "$_netif" > /dev/null 2> /dev/null ; then
		return 0 # true
	else
		return 1 # false
	fi
}

# $1 ipaddr
_get_alias_ipv4()
{
	# shellcheck disable=SC2039
	local _i _ip _nic _output
	_output=
	if [ "$( _get_network_stack )" != "ipv6" ]; then
		for _i in $1 ; do
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

# $1 ipaddr
_get_alias_ipv6()
{
	# shellcheck disable=SC2039
	local _i _ip _nic _output
	_output=
	if [ "$( _get_network_stack )" != "ipv4" ]; then
		for _i in $1 ; do
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
_validate_alias_ipaddr()
{
	# shellcheck disable=SC2039
	local _i _nic _ip
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
	done
	return 0
}

# $1 network type
# $2 ipaddr
# $3 bridge-name (private-bridge only)
# if success, then print the ip addr (it could be empty)
# otherwise it print the an error message
_validate_network_param()
{
	# shellcheck disable=SC2039
	local _network_type _ipaddr _private_bridge
	_network_type=$1
	_ipaddr=$2
	_private_bridge=$3
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
		if ! _validate_alias_ipaddr "$_ipaddr" ; then
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
		if [ "$( _get_network_stack )" = "ipv6" ]; then
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
