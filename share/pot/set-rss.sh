#!/bin/sh
:

# shellcheck disable=SC3033
set-rss-help()
{
	echo "pot set-rss [-hv] -p pot -C cpus -M memory"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -C cpus : the max amount of CPUs'
	echo '  -M memory : max memory usable (integer values)'
}

# $1 pot
# $2 rss name
# $3 rss limit
_set_rss()
{
	# shellcheck disable=SC2039
	local _rssname _rsslimit _pname _cdir
	_pname="$1"
	_rssname="$2"
	_rsslimit="$3"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	${SED} -i '' -e "/^pot.rss.$_rssname=.*/d" "$_cdir/pot.conf"
	echo "pot.rss.$_rssname=$_rsslimit" >> "$_cdir/pot.conf"
}

# $1 the amount of memory
_memory_validation()
{
	: # Implement
	# shellcheck disable=SC2039
	local _number
	if ! echo "$1" | grep -q -E '^[0-9]+[bBkKmMgG]?$' ; then
		_error "$1 is not a valid memory constraint"
		return 1
	fi
	_number="$( echo "$1" | sed 's/[bBkKmMgG]$//')"
	if ! echo "$_number" | grep -q -E '^[0-9]+' ; then
		_error "$1 has wrong suffix or format"
		return 1
	fi
	if echo "$_number" | grep -q '^00*$' ; then
		_error "Memory constraint has to be greater than zero"
		return 1
	fi
	return 0
}
# $1 pot
# $2 cpus amount
_set_cpu()
{
	# shellcheck disable=SC2039
	local _pname _cpus
	_pname=$1
	_cpus=$2
	if _is_natural_number "$_cpus" ; then
		if [ "$_cpus" -gt 0 ]; then
			_set_rss "$_pname" cpus "$_cpus"
			return 0 # true
		fi
	fi
	return 1 # false
}

_set_memory()
{
	# shellcheck disable=SC2039
	local _pname _memory
	_pname=$1
	_memory=$2
	_set_rss "$_pname" memory "$_memory"
}

# shellcheck disable=SC3033
pot-set-rss()
{
	# shellcheck disable=SC2039
	local _pname _cpus _memory
	_pname=
	_cpus=
	_memory=
	OPTIND=1
	while getopts "hvp:C:M:" _o ; do
		case "$_o" in
		h)
			set-rss-help
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		C)
			_cpus="$OPTARG"
			;;
		M)
			if _memory_validation "$OPTARG"  ; then
				_memory="$OPTARG"
			else
				set-rss-help
				return 1
			fi
			;;
		*)
			set-rss-help
			return 1
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-rss-help
		return 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pname is not a valid pot name"
		set-rss-help
		return 1
	fi
	if [ -z "${_cpus}${_memory}" ]; then
		_error "One resource has to be specified (-C or -M)"
		set-rss-help
		return 1
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	if [ -n "$_cpus" ]; then
		if ! _set_cpu "$_pname" "$_cpus" ; then
			_error "$_cpus is a not valid amount of CPUs!"
			return 1
		fi
	fi
	if [ -n "$_memory" ]; then
		_set_memory "$_pname" "$_memory"
	fi
}
