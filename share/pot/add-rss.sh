#!/bin/sh

# supported releases
add-rss-help()
{
	echo "pot add-rss [-hv] -p pot -P rssPot"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -C cpuset : the cpu set'
	echo '  -M memory : max memory usable'
}

# $1 pot
# $2 rss name
# $3 rss limit
_add_rss()
{
	local _rssname _rsslimit _pname _cdir
	_pname="$1"
	_rssname="$2"
	_rsslimit="$3"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	sed -i '' -e "s/pot.rss.$_rssname=.*$i/g" $_cdir/pot.conf
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
_add_cpu()
{
	local _pname _cpuset
	_pname=$1
	_cpuset=$2
	if _cpuset_validation $_cpuset ; then
		_add_rss $_pname cpuset $_cpuset
	else
		"cpuset $_cpuset ignored"
	fi
}

_add_memory()
{
	local _pname _memory
	_pname=$1
	_memory=$2
	_add_rss $_pname memory $_memory
}

pot-add-rss()
{
	local _pname _cpuset _memory
	_pname=
	_cpuset=
	_memory=
	args=$(getopt hvp:C:M: $*)
	if [ $? -ne 0 ]; then
		add-rss-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			add-rss-help
			exit 0
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
		add-rss-help
		exit 1
	fi
	if [ -z "${_cpuset}${_memory}" ]; then
		_error "One resource has to be specified (-C or -M)"
		add-rss-help
		exit 1
	fi
	if [ -n "$_cpuset" ]; then
		_add_cpu $_pname $_cpuset
	fi
	if [ -n "$_memory" ]; then
		_add_memory $_pname $_memory
	fi
}
