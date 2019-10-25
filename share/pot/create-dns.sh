#!/bin/sh

create-dns-help()
{
	echo "pot create-dns [-hv] [-b RELEASE]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -b base : the base pot to use (optional)'
}

pot-create-dns()
{
	local _base
	args=$(getopt hb:v $*)
	if [ $? -ne 0 ]; then
		create-dns-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			create-dns-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-b)
			_base=$2
			if ! _is_base $2  ; then
				_error "$2 is not a valid base"
				${EXIT} 1
			fi
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done
	echo "############################"
	echo "# create-dns is deprecated #"
	echo "############################"

	if _is_pot $POT_DNS_NAME quiet ; then
		_info "The dns port ${POT_DNS_NAME} is already available"
		return 0
	fi

	if [ -z "$_base" ]; then
		_base="$( ls -d ${POT_FS_ROOT}/bases/*/ 2> /dev/null | xargs -I {} basename {} | sort -rV | head -n 1)"
		if [ -z "$_base" ]; then
			_error "no valid base found in ${POT_FS_ROOT}/bases/"
		fi
	fi

	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	_info "Create a dns pot with base "${_base}" (name: ${POT_DNS_NAME} - IP: ${POT_DNS_IP}"

	pot-cmd create -p ${POT_DNS_NAME} -i ${POT_DNS_IP} -b ${_base} -f dns
}
