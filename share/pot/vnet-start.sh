#!/bin/sh

vnet-start-help()
{
	echo 'pot vnet-start [-h][-v]'
	echo '  -h -- print this help'
	echo '  -v verbose'
}


pot-vnet-start()
{
	local _bridge
	args=$(getopt hr:v $*)
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

	if [ -z "${POT_NETWORK}" -o -z "${POT_GATEWAY}" ]; then
		_error "No network or gateway defined"
		exit 1
	fi
	if [ -z "${POT_EXTIF}" ]; then
		_error "No external interface defined"
		exit 1
	fi

	if [ -w "/tmp/pot_pfrules" ]; then
		rm /tmp/pot_pfrules
	fi
	(
		echo "ext_if = \"${POT_EXTIF}\""
		echo "localnet = \"${POT_NETWORK}\""
		echo "nat on \$ext_if from \$localnet to any -> (\$ext_if)"
	) > /tmp/pot_pfrules

	pfctl -F all -f /tmp/pot_pfrules
	## TODO if verbose, pfctl -s nat
	# if bridge0 doesn't exist yet
	_bridge=$(ifconfig bridge create)
	ifconfig $_bridge inet $POT_GATEWAY netmask $POT_NETMASK
}

