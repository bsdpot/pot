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
	if [ -z "${POT_NETWORK}" -o -z "${POT_GATEWAY}" ]; then
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

	# bridge creation
	# if bridge0 doesn't exist yet
	_bridge=$(_pot_bridge)
	if [ -z "$_bridge" ]; then
		_bridge=$(ifconfig bridge create)
		if [ $? -ne 0 ]; then
			_error "Bridge not created"
		else
			_debug "Bridge created $_bridge"
		fi
		ifconfig $_bridge inet $POT_GATEWAY netmask $POT_NETMASK
		if [ $? -ne 0 ]; then
			_error "Error during bridge configuration ($_bridge)"
		else
			_debug "Bridge $_bridge configured with IP $POT_GATEWAY netmask $POT_NETMASK"
		fi
	else
		_debug "Bridge $_bridge already present"
	fi

	# load pf module
	kldload -n pf
	# firewall rules
	_pfrules="/tmp/pot_pfrules"
	if [ -w "$_pfrules" ]; then
		rm -f $_pfrules
	fi
	(
		echo "ext_if = \"${POT_EXTIF}\""
		echo "localnet = \"${POT_NETWORK}\""
		echo "nat on \$ext_if from \$localnet to any -> (\$ext_if)"
	) > $_pfrules

	pfctl -F nat -f $_pfrules
	if _is_verbose ; then
		pfctl -s nat
	fi
	pfctl -e
}

