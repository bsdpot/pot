#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

prepare-help()
{
	cat <<-"EOH"
	pot prepare [-hvS] -p pot -U URL -t tag -a aID -n potname -c cmd
	            [-e [proto:]port[:pot_port]] [-N network-type]
	            [-i ipaddr] [-B bridge-name] [-C pubkey]
	  -h print this help
	  -h verbose
	  -p pot : the pot image
	  -U URL : the base URL where to find the image file
	  -t tag : the tag of the pot
	  -a aID : the allocation ID
	  -n potname : the new potname (used instead of pot_tag)
	  -c cmd : the command line to start the container
	  -N network-type : new network type of the imported pot
	  -i ipaddr : an ip address or the keyword auto (if applicable)
	  -e [proto:]port[:pot_port] : port(s) to export
	         This option can be repeated to export multiple ports.
	         See `pot help export-ports` for details.
	  -B bridge-name : the name of the private bridge to be used
	  -S network-stack : the network stack (ipv4, ipv6 or dual)
	  -d dns : change pot dns resolver configuration, one of
	           inherit       - inherit from jailhost
	           pot           - the pot configured in POT_DNS_NAME
	           custom:<file> - copy <file> into pot configuration
	           off           - leave resolver config unaltered
	  -s : start the newly generated pot immediately
	  -C pubkey : verify with public key 'pubkey' using signify(1)
	              on pot import
	EOH
}

pot-prepare()
{
	local _pname _o _URL _tag _tpname _cmd _ports _allocation_tag _new_pname
	local _auto_start _network_type _ipaddr _ipaddr_list _bridge_name _dns
	local _sign_pubkey
	_pname=
	_ports=
	_network_type=
	_ipaddr=
	_ipaddr_list=
	_auto_start="NO"
	_bridge_name=
	_cmd=
	_dns=
	_sign_pubkey=
	OPTIND=1
	while getopts "hvp:U:t:c:e:a:n:sN:i:B:S:d:C:" _o ; do
		case "$_o" in
		h)
			prepare-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		U)
			_URL="$OPTARG"
			;;
		t)
			_tag="$OPTARG"
			;;
		c)
			_cmd="$OPTARG"
			;;
		a)
			_allocation_tag="$OPTARG"
			;;
		n)
			_tpname="$OPTARG"
			;;
		e)
			if ! _is_export_port_valid "$OPTARG" ; then
				_error "$OPTARG is not a valid port number"
				prepare-help
				${EXIT} 1
			fi
			if [ -z "$_ports" ]; then
				_ports="$OPTARG"
			else
				_ports="$_ports $OPTARG"
			fi
			;;
		s)
			_auto_start="YES"
			;;
		N)
			if [ "$OPTARG" = "host" ]; then
				_network_type="inherit"
			else
				_network_type="$OPTARG"
			fi
			# shellcheck disable=SC2086
			if ! _is_in_list "$_network_type" $_POT_NETWORK_TYPES ; then
				_error "Network type $_network_type not recognized"
				prepare-help
				${EXIT} 1
			fi
			;;
		B)
			_bridge_name="$OPTARG"
			;;
		i)
			_ipaddr_list="$_ipaddr_list $OPTARG"
			;;
		S)
			if ! _is_in_list "$OPTARG" "ipv4" "ipv6" "dual" ; then
				_error "Network stack $OPTARG not valid"
				create-help
				${EXIT} 1
			fi
			_network_stack="$OPTARG"
			;;
		d)
			case $OPTARG in
				inherit|pot|off)
					_dns=$OPTARG
					;;
				custom:*)
					if [ -r "${OPTARG##custom:}" ]; then
						_dns=$OPTARG
					else
						_error "The file ${OPTARG##custom:} is not valid or readable"
						${EXIT} 1
					fi
					;;
				*)
					_error "'${OPTART}' is not a valid dns option"
					prepare-help
					${EXIT} 1
			esac
			;;
		C)
			_sign_pubkey="$OPTARG"
			;;
		*)
			prepare-help
			${EXIT} 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		prepare-help
		${EXIT} 1
	fi
	if [ -z "$_tag" ]; then
		_error "A tag is mandatory"
		prepare-help
		${EXIT} 1
	fi
	if [ -z "$_allocation_tag" ]; then
		_error "An allocation id is mandatory"
		prepare-help
		${EXIT} 1
	fi
	if [ "$_network_type" = "private-bridge" ] && [ -z "$_bridge_name" ]; then
		_error "A bridge name has to be provided if private-bridge is selected as network-type"
		prepare-help
		${EXIT} 1
	fi
	_imported_pname="${_pname}_${_tag}"
	_imported_pname="$(echo "$_imported_pname" | tr '.' '_')"
	if [ -z "$_tpname" ]; then
		_tpname="${_imported_pname}"
	fi
	_new_pname="${_tpname}_${_allocation_tag}"
	_new_pname="$(echo "$_new_pname" | tr '.' '_')"
	if _is_pot "$_new_pname" quiet ; then
		_error "A pot with name $_new_pname already exists"
		prepare-help
		${EXIT} 1
	fi
	if ! _is_pot "$_imported_pname" quiet ; then
		if ! pot-cmd import -U "$_URL" -t "$_tag" -p "$_pname" \
		    -C "$_sign_pubkey"; then
			_error "pot import failed"
			pot-cmd stop "$_imported_pname"
			${EXIT} 1
		fi
		if ! _is_pot "$_imported_pname" quiet ; then
			_error "imported pot is weirdly not found after import - cannot proceed"
			pot-cmd destroy -p "$_imported_pname"
			${EXIT} 1
		fi
	else
		_debug "pot $_imported_pname already imported - reusing it"
	fi
	_clone_network_opt=
	if [ -n "$_network_type" ]; then
		_clone_network_opt="-N $_network_type"
	fi
	if [ "$_network_type" = "private-bridge" ]; then
		_clone_network_opt="$_clone_network_opt -B $_bridge_name"
	fi
	for _ipaddr in $_ipaddr_list; do
		_clone_network_opt="$_clone_network_opt -i $_ipaddr"
	done
	if [ -n "$_network_stack" ]; then
		_clone_network_opt="$_clone_network_opt -S $_network_stack"
	fi
	if [ -n "$_dns" ]; then
		_clone_network_opt="$_clone_network_opt -d $_dns"
	fi
	# shellcheck disable=SC2086
	if ! pot-cmd clone -P "${_imported_pname}" -p "${_new_pname}" $_clone_network_opt ; then
		_error "Not able to clone imported pot as $_new_pname"
	fi
	if [ -n "$_cmd" ]; then
		if ! pot-cmd set-cmd -p "$_new_pname" -c "$_cmd" ; then
			_error "Couldn't set the command $_cmd ot the pot - ignoring"
		fi
	fi
	if ! pot-cmd set-attribute -A persistent -V OFF -p "$_new_pname" ; then
		_error "Couldn't disable the persistent attribute - ignoring"
	fi
	if ! pot-cmd set-attribute -A no-rc-script -V ON -p "$_new_pname" ; then
		_error "Couldn't enable the no-rc-script attribute - ignoring"
	fi
	if ! pot-cmd set-attribute -A prunable -V ON -p "$_new_pname" ; then
		_error "Couldn't enable the no-rc-script attribute - ignoring"
	fi
	if ! pot-cmd set-attribute -A localhost-tunnel -V YES -p "$_new_pname" ; then
		_error "Couldn't enable the localhost-tunnel attribute - ignoring"
	fi
	if ! pot-cmd set-attribute -A no-etc-hosts -V YES -p "$_new_pname" ; then
		_error "Couldn't disable the enrichment of /etc/hosts - ignoring"
	fi
	if ! pot-cmd set-attribute -A dynamic-etc-hosts -V NO -p "$_new_pname" ; then
		_error "Couldn't disable the enrichment of dynamic /etc/hosts - ignoring"
	fi
	if ! pot-cmd set-attribute -A no-tmpfs -V YES -p "$_new_pname" ; then
		_error "Couldn't disable tmpfs for /tmp - ignoring"
	fi

	if [ -n "$_ports" ]; then
		for _p in $_ports ; do
			_port_args="-e $_p $_port_args"
		done
		# shellcheck disable=SC2086
		if ! pot-cmd export-ports -p "$_new_pname" $_port_args ; then
			_error "Couldn't export ports $_ports - ignoring"
		fi
	fi
	if [ "$_auto_start" = "YES" ]; then
		_debug "Auto starting the pot $_new_pname"
		if ! pot-cmd start "$_new_pname" ; then
			_error "pot $_new_pname failed to start"
			pot-cmd stop "$_new_pname"
			${EXIT} 1
		fi
	else
		_info "Prepared the pot $_new_pname"
	fi
	return 0
}
