#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

export-ports-help()
{
	cat <<-"EOH"
	pot export-ports configure exported ports - public-bridge only
	pot export-ports [-hv] -p pot [-S] -e [proto:]port[:pot_port] ...
	  -h print this help
	  -v verbose
	  -p pot : the working pot
	  -e [proto:]port[:pot_port] : port(s) to export
	         proto can be tcp (default) or udp
	         port is the port to export
	         pot_port : a static port to NAT to inside the pot
	                    dynamically allocated by default
	         This option can be repeated to export multiple ports.

	     Examples:
	       -e 80            export proto tcp port 80 to a dynamic port
	       -e 80:30000      export proto tcp port 80 to pot_port 30000
	       -e tcp:80:30000  export proto tcp port 80 to pot_port 30000
	       -e udp:53:30053  export proto udp port 53 to pot_port 30053
	EOH
}

# $1 pot
# $2 port list
_export_ports()
{
	local _pname _ports _cdir
	_pname="$1"
	_ports="$2"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	sed -i '' -e "/pot.export.ports=.*/d" "$_cdir/pot.conf"
	echo "pot.export.ports=$_ports" >> "$_cdir/pot.conf"
}

pot-export-ports()
{
	local _pname _ports
	_pname=
	_ports=
	OPTIND=1

	while getopts "hvp:e:" _o ; do
		case "$_o" in
		h)
			export-ports-help
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		e)
			if ! _is_export_port_valid "${OPTARG}" ; then
				_error "$OPTARG is not a valid port number"
				export-ports-help
				return 1
			fi
			if [ -z "$_ports" ]; then
				_ports="$OPTARG"
			else
				_ports="$_ports $OPTARG"
			fi
			;;
		*)
			export-ports-help
			return 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		export-ports-help
		return 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pname is not a valid pot name"
		export-ports-help
		return 1
	fi
	if [ -z "${_ports}" ]; then
		_error "One port has to be specified"
		export-ports-help
		return 1
	fi
	if [ "$(_get_pot_network_type "$_pname")" != "public-bridge" ] &&
		[ "$(_get_pot_network_type "$_pname")" != "private-bridge" ] ; then
		_info "Only public-bridge and private-bridge network type can export ports - this setting will be ignored during start"
	fi
	if [ "$( _get_pot_network_stack "$_pname" )" = "ipv6" ]; then
		_info "Only ipv4 can export ports, on ipv6 the pot has already a unique address - this setting will be ignored during start"
	fi
	_debug "Exporting the following ports: $_ports"
	if ! _is_uid0 ; then
		return 1
	fi
	_export_ports "$_pname" "$_ports"
}
