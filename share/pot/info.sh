#!/bin/sh
:

# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
	local _pname _cdir _lvl _ports _type
	_pname=$1
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_lvl=$( _get_conf_var "$_pname" pot.level)
	_type=$( _get_conf_var "$_pname" pot.type)
	printf "pot name : %s\n" "$_pname"
	printf "\ttype : %s\n" "$_type"
	printf "\tbase : %s\n" "$( _get_conf_var "$_pname" pot.base)"
	printf "\tlevel : %s\n" "$_lvl"
	if [ "$_lvl" -eq 2 ]; then
		printf "\tbase pot : %s\n" "$( _get_conf_var "$_pname" pot.potbase)"
	fi
	printf "\tnetwork_type : %s\n" "$( _get_pot_network_type "$_pname" )"
	if [ "$( _get_pot_network_type "$_pname" )" != "inherit" ]; then
		printf "\tip : %s\n" "$( _get_conf_var "$_pname" ip)"
		if [ "$( _get_pot_network_type "$_pname" )" = "private-bridge" ]; then
			printf "\tbridge : %s\n" "$( _get_conf_var "$_pname" bridge)"
		fi
		if _is_verbose ; then
			_ports="$( _get_pot_export_ports "$_pname" )"
			if [ -z "$_ports" ]; then
				printf "\t\tno ports exported\n"
			else
				printf "\t\texported ports: %s\n" "$_ports"
			fi
		fi
	fi
	if _is_pot_running "$_pname" ; then
		printf "\tactive : true\n"
	else
		printf "\tactive : false\n"
	fi
	if _is_verbose ; then
		printf "\tdatasets:\n"
		if [ "$_type" = "single" ]; then
			printf "\\t\\t%s\\n" "$_pname/m"
		fi
		_print_pot_fscomp "$_cdir/fscomp.conf"
		printf "\tsnapshots:\n"
		_print_pot_snaps "$_pname"
	fi
	printf "\tattributes:\n"
	for _a in $_POT_RW_ATTRIBUTES $_POT_RO_ATTRIBUTES ; do
		_value=$( _get_conf_var "$_pname" "pot.attr.$_a")
		printf "\t\t%s: %s\n" "$_a" "${_value:-"NO"}"
	done
	if _is_verbose ; then
		_cpu="$( _get_conf_var "$_pname" pot.rss.cpus)"
		_mem="$( _get_conf_var "$_pname" pot.rss.memory)"
		if [ -n "${_cpu}${_mem}" ]; then
			printf "\tresource limits:\n"
			if [ -n "${_cpu}" ]; then
				printf "\t\tmax amount cpus: %s\n" "$_cpu"
			fi
			if [ -n "${_mem}" ]; then
				printf "\t\tmax amount memory: %s\n" "$_mem"
			fi
		fi
	fi
	echo
}

# shellcheck disable=SC2039
pot-info()
{
	local _pname _quiet _run
	_pname=""
	_quiet="NO"
	_run="NO"
	OPTIND=1
	while getopts "hvqp:r" _o ; do
		case "$_o" in
		h)
			info-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_quiet="YES"
			;;
		p)
			_pname="$OPTARG"
			;;
		r)
			_run="YES"
			;;
		*)
			info-help
			${EXIT} 1
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
	if ! _is_pot "$_pname" quiet ; then
		if [ "$_quiet" != "YES" ]; then
			_error "$_pname is not a pot"
			info-help
		fi
		${EXIT} 1
	fi
	if [ "$_quiet" = "YES" ]; then
		if [ "$_run" = "YES" ]; then
			if _is_pot_running "$_pname" ; then
				${EXIT} 0
			else
				${EXIT} 1
			fi
		else
			${EXIT} 0
		fi
	fi
	_info_pot "$_pname"
}
