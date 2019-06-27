#!/bin/sh
:

# shellcheck disable=SC2039
export-ports-help()
{
	echo "pot export-ports [-hv] -p pot [-S] -e port ..."
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -e port : the tcp port'
	echo '            This option can be repeated multiple time, to export more ports'
	echo '            -e 80 will export port 80 using an available port'
	echo '            -e 80:30000 will export port 80 using port 30000'
}

# $1 pot
# $2 port list
_export_ports()
{
	# shellcheck disable=SC2039
	local _pname _ports
	_pname="$1"
	_ports="$2"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	sed -i '' -e "/pot.export.ports=.*/d" "$_cdir/pot.conf"
	echo "pot.export.ports=$_ports" >> "$_cdir/pot.conf"
}

# shellcheck disable=SC2039
pot-export-ports()
{
	local _pname _ports _pot_port _host_port
	_pname=
	_ports=
	OPTIND=1

	while getopts "hvp:e:" _o ; do
		case "$_o" in
		h)
			export-ports-help
			${EXIT} 0
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
				${EXIT} 1
			fi
			if [ -z "$_ports" ]; then
				_ports="$OPTARG"
			else
				_ports="$_ports $OPTARG"
			fi
			;;
		*)
			export-ports-help
			${EXIT} 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		export-ports-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pname is not a valid pot name"
		export-ports-help
		${EXIT} 1
	fi
	if [ -z "${_ports}" ]; then
		_error "One port has to be specified"
		export-ports-help
		${EXIT} 1
	fi
	# validate port numbers
	_debug "Exporting the following ports: $_ports"
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_export_ports "$_pname" "$_ports"
}
