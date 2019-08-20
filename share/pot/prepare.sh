#!/bin/sh
:

# shellcheck disable=SC2039
prepare-help()
{
	echo "pot prepare [-hvS] -p pot -U URL -t tag -a aID -n potname -c cmd"
	echo '        [-e port] [-N network-type] [-i ipaddr]'
	echo '  -h print this help'
	echo '  -h verbose'
	echo '  -p pot : the pot image'
	echo '  -U URL : the base URL where to find the image file'
	echo '  -t tag : the tag of the pot'
	echo '  -a aID : the allocation ID'
	echo '  -n potname : the new potname (used instead of pot_tag)'
	echo '  -c cmd : the command line to start the container'
	echo '  -N network-type : new network type of the imported pot'
	echo '  -i ipaddr : an ip address or the keyword auto (if applicable)'
	echo '  -e port : the tcp port'
	echo '            This option can be repeated multiple time, to export more ports'
	echo '  -S : start immediately the newly generated pot'
}

pot-prepare()
{
	# shellcheck disable=SC2039
	local _pname _o _URL _tag _tpname _cmd _ports _allocation_tag _new_pname _auto_start _network_type _ipaddr
	_pname=
	_ports=
	_network_type=
	_ipaddr=
	_auto_start="NO"
	OPTIND=1
	while getopts "hvp:U:t:c:e:a:n:SN:i:" _o ; do
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
		S)
			_auto_start="YES"
			;;
		N)
			if [ "$OPTARG" = "host" ]; then
				_network_type="inherit"
			else
				_network_type="$OPTARG"
			fi
			if ! _is_in_list "$OPTARG" $_POT_NETWORK_TYPES ; then
				_error "Network type $OPTARG not recognized"
				clone-help
				${EXIT} 1
			fi
			;;
		i)
			_ipaddr=$OPTARG
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
		if ! pot-cmd import -U "$_URL" -t "$_tag" -p "$_pname" ; then
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
	if [ -n "$_ipaddr" ]; then
		_clone_network_opt="$_clone_network_opt -i $_ipaddr"
	fi
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
	if [ -n "$_ports" ]; then
		for _p in $_ports ; do
			_port_args="-e $_p "
		done
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
