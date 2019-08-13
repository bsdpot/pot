#!/bin/sh
:

# shellcheck disable=SC2039
get-rss-help()
{
	echo "pot get-rss [-h] [-p pot|-a]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -J : output in JSON'
}

# $1 pot name
# $2 json format
print_rss()
{
	# shellcheck disable=SC2039
	local _rss _pname _json _pcpu _mem _cputime _vmem
	_pname=$1
	_json=$2
	_rss="$( rctl -u jail:"$_pname" )"
	_pcpu="$( echo "$_rss" | grep ^pcpu | cut -d'=' -f 2 )"
	_mem="$( echo "$_rss" | grep ^memoryuse | cut -d'=' -f 2 )"
	_vmem="$( echo "$_rss" | grep ^vmemoryuse | cut -d'=' -f 2 )"
	_cputime="$( echo "$_rss" | grep ^cputime | cut -d'=' -f 2 )"
	if [ "$_json" = "YES" ]; then
		echo "{ \"ResourceUsage\": { \"MemoryStats\": { \"RSS\" : $_mem }, \"CpuStats\": { \"TotalTicks\": $_cputime, \"Percent\": $_pcpu } } } "
	else
		echo "Resource usage by the pot $_pname"
		printf "\\tcpu time (ticks): %s\\n" "$_cputime"
		printf "\\tpcpu (%%)        : %s\\n" "$_pcpu"
		printf "\\tvirtual memory  : %s\\n" "$_vmem"
		printf "\\tphysical memory : %s\\n" "$_mem"
	fi
}

pot-get-rss()
{
	# shellcheck disable=SC2039
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
		_error "A pot name or -a are mandatory"
		get-rss-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" quiet ; then
		_error "The pot $_pname is not a valid pot"
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
