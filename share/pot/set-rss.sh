#!/bin/sh

# supported releases
set-rss-help()
{
	echo "pot set-rss [-hv] -p pot -P rssPot"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -C cpuset : the cpu set'
	echo '  -M memory : max memory usable'
}

# $1 pot
# $2 rss name
# $3 rss limit
_set_rss()
{
	local _rssname _rsslimit _pname _cdir
	_pname="$1"
	_rssname="$2"
	_rsslimit="$3"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	sed -i '' -e "/pot.rss.$_rssname=.*/d" $_cdir/pot.conf
	echo "pot.rss.$_rssname=$_rsslimit" >> $_cdir/pot.conf
}

# $1 cpu limit
_cpuset_validation()
{
	local _cpuset
	_cpuset="$1"
	cpuset -l $_cpuset ls>/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		_debug "cpuset $_cpuset is not valid"
		return 1 # false
	fi
	return 0 # true
}

# $1 pot
# $2 cpuset list
_set_cpu()
{
	local _pname _cpuset
	_pname=$1
	_cpuset=$2
	if _cpuset_validation $_cpuset ; then
		_set_rss $_pname cpuset $_cpuset
		return 0 # true
	fi
	return 1 # false
}

_set_memory()
{
	local _pname _memory
	_pname=$1
	_memory=$2
	_set_rss $_pname memory $_memory
}

pot-set-rss()
{
	local _pname _cpuset _memory
	_pname=
	_cpuset=
	_memory=
	args=$(getopt hvp:C:M: $*)
	if [ $? -ne 0 ]; then
		set-rss-help
		${EXIT} 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			set-rss-help
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
		-C)
			_cpuset="$2"
			shift 2
			;;
		-M)
			_memory="$2"
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
		set-rss-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pot is not a valid pot name"
		set-rss-help
		${EXIT} 1
	fi
	if [ -z "${_cpuset}${_memory}" ]; then
		_error "One resource has to be specified (-C or -M)"
		set-rss-help
		${EXIT} 1
	fi
	if [ -n "$_cpuset" ]; then
		if ! _set_cpu $_pname $_cpuset ; then
			_error "cpuset $_cpuset not valid!"
			${EXIT} 1
		fi
	fi
	if [ -n "$_memory" ]; then
		_set_memory $_pname $_memory
	fi
}
