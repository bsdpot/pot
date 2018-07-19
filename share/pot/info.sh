#!/bin/sh

# supported releases
info-help()
{
	echo "pot info [-hvqr] -p pname"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quiet'
	echo '  -p pname: pot name'
	echo '  -r check if the pot is running'
}

# $1 pot name
_info_pot()
{
	local _pname _cdir _lvl _ports
	_pname=$1
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_lvl=$( _get_conf_var $_pname pot.level)
	printf "pot name : %s\n" $_pname
	printf "\tbase : %s\n" "$( _get_conf_var $_pname pot.base)"
	printf "\tlevel : %s\n" "$_lvl"
	if [ $_lvl -eq 2 ]; then
		printf "\tbase pot : %s\n" "$( _get_conf_var $_pname pot.potbase)"
	fi
	printf "\tip4 : %s\n" "$( _get_conf_var $_pname ip4)"
	if _is_verbose ; then
		_ports="$( _get_pot_export_ports $_pname )"
		if [ -z "$_ports" ]; then
			printf "\t\tno ports exported\n"
		else
			printf "\t\texported ports: $_ports\n"
		fi
	fi
	if _is_pot_running $_pname ; then
		printf "\tactive : true\n"
	else
		printf "\tactive : false\n"
	fi
	if _is_verbose ; then
		printf "\tdatasets:\n"
		_print_pot_fscomp "$_cdir/fscomp.conf"
		printf "\tsnapshot:\n"
		_print_pot_snaps "$_pname"
	fi
	echo
}

pot-info()
{
	local _pname _quiet _run
	_pname=""
	_quiet="NO"
	_run="NO"
	args=$(getopt hvqp:r $*)
	if [ $? -ne 0 ]; then
		info-help
		${EXIT} 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			info-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-q)
			_quiet="YES"
			shift
			;;
		-p)
			_pname="$2"
			shift 2
			;;
		-r)
			_run="YES"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_error "Option -p is mandatory"
		info-help
		${EXIT} 1
	fi
	if [ "$_quiet" = "YES" ] && _is_verbose ; then
		_error "Option -q and -v are mutually exclusive"
		info-help
		${EXIT} 1
	fi
	if ! _is_pot $_pname quiet ; then
		if [ "$_quiet" != "YES" ]; then
			_error "$_pname is not a pot"
			info-help
		fi
		${EXIT} 1
	fi
	if [ "$_quiet" = "YES" ]; then
		if [ "$_run" = "YES" ]; then
			if _is_pot_running $_pname ; then
				${EXIT} 0
			else
				${EXIT} 1
			fi
		else
			${EXIT} 0
		fi
	fi
	_info_pot $_pname
}
