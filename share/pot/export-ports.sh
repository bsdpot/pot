#!/bin/sh

# supported releases
export-ports-help()
{
	echo "pot export-ports [-hv] -p pot -P rssPot"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -e port : the tcp port'
	echo '            This option can be repeated multiple time, to export more ports'
}

# $1 pot
# $2 port list
_export_ports()
{
	local _pname _ports
	_pname="$1"
	_ports="$2"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	sed -i '' -e "/pot.export.ports=.*/d" $_cdir/pot.conf
	echo "pot.export.ports=$_ports" >> $_cdir/pot.conf
}

pot-export-ports()
{
	local _pname _ports
	_pname=
	_ports=
	if ! args=$(getopt hvp:e: "$@") ; then
		export-ports-help
		${EXIT} 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			export-ports-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-p)
			_pname="$2"
			shift 2
			;;
		-e)
			if [ -z "$_ports" ]; then
				_ports="$2"
			else
				_ports="$_ports $2"
			fi
			shift 2
			;;
		--)
			shift
			break
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
