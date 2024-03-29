#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

get-rss-help()
{
	cat <<-"EOH"
	pot get-rss [-h] -p pot
	  -h print this help
	  -v verbose
	  -p pot : the working pot
	  -J : output in JSON format
	EOH
}

# $1 pot name
# $2 json format
print_rss()
{
	local _rss _pname _json _pcpu _mem _cputime _vmem _clockrate _cputimecounter _swap
	_pname=$1
	_json=$2
	_clockrate="$( sysctl -n hw.clockrate )"
	_rss="$( rctl -u jail:"$_pname" )"
	_pcpu="$( echo "$_rss" | grep ^pcpu | cut -d'=' -f 2 )"
	_cputimecounter="$( echo "$_rss" | grep ^cputime | cut -d'=' -f 2 )"
	_mem="$( echo "$_rss" | grep ^memoryuse | cut -d'=' -f 2 )"
	_vmem="$( echo "$_rss" | grep ^vmemoryuse | cut -d'=' -f 2 )"
	_swap="$( echo "$_rss" | grep ^swapuse | cut -d'=' -f 2 )"
	_cputime="$( printf "scale=3\n %s * %s / 100\n" "$_clockrate" "$_pcpu" | bc )"
	if [ "$_json" = "YES" ]; then
		echo "{ \"ResourceUsage\": { \"MemoryStats\": { \"RSS\" : $_mem, \"Swap\" : $_swap }, \"CpuStats\": { \"TotalTicks\": $_cputime, \"Percent\": $_pcpu } } } "
	else
		echo "Resource usage by the pot $_pname"
		printf "\\tcpu time (ticks spent) : %s\\n" "$_cputimecounter"
		printf "\\tcpu time (MHz)         : %s\\n" "$_cputime"
		printf "\\tpcpu (%%)               : %s\\n" "$_pcpu"
		printf "\\tvirtual memory         : %s\\n" "$_vmem"
		printf "\\tphysical memory        : %s\\n" "$_mem"
		printf "\\tswap memory            : %s\\n" "$_swap"
	fi
}

pot-get-rss()
{
	local _pname _o _json
	_pname=
	_json=
	OPTIND=1
	while getopts "hvp:J" _o ; do
		case "$_o" in
		h)
			get-rss-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		J)
			_json="YES"
			;;
		*)
			get-rss-help
			${EXIT} 1
		esac
	done
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		get-rss-help
		${EXIT} 1
	fi
	if ! _is_pot_running "$_pname" ; then
		_error "The pot $_pname is not running"
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if ! _is_rctl_available ; then
		_error "To get resource usage, rctl has to be enabled"
		${EXIT} 1
	fi
	print_rss "$_pname" "$_json"
	${EXIT} 0
}
