#!/bin/sh
:

# shellcheck disable=SC2039
export-ports-help()
{
	echo "pot export-ports [-hv] -p pot -P rssPot"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -e port : the tcp port'
	echo '            This option can be repeated multiple time, to export more ports'
	echo '  -S The port is exported statically: the host will use the same port used by the pot'
}

# $1 pot
# $2 port list
_export_ports()
{
	# shellcheck disable=SC2039
	local _pname _ports _static
	_pname="$1"
	_static="$2"
	_ports="$3"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	if [ "$_static" = "YES" ]; then
		sed -i '' -e "/pot.export.static.ports=.*/d" "$_cdir/pot.conf"
		echo "pot.export.static.ports=$_ports" >> "$_cdir/pot.conf"
	else
		sed -i '' -e "/pot.export.ports=.*/d" "$_cdir/pot.conf"
		echo "pot.export.ports=$_ports" >> "$_cdir/pot.conf"
	fi
}

# shellcheck disable=SC2039
pot-export-ports()
{
	local _pname _ports _static
	_pname=
	_ports=
	_static="NO"
	OPTIND=1
	while getopts "hvp:e:S" _o ; do
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
			if [ -z "$_ports" ]; then
				_ports="$OPTARG"
			else
				_ports="$_ports $OPTARG"
			fi
			;;
		S)
			_static="YES"
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
	_export_ports "$_pname" "$_static" "$_ports"
}
