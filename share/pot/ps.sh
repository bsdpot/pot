#!/bin/sh

# shellcheck disable=SC2039
ps-help()
{
	echo "pot ps [-hvq]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quite: print only active pot'\''s name'
}

# $1 pot name
_ps_pot()
{
	# shellcheck disable=SC2039
	local _pname _q
	_pname=$1
	_q=$2
	if _is_pot_running "$_pname" ; then
		if [ "$_q" = "quiet" ]; then
			echo "$_pname"
			return
		fi
		echo "$_pname"
	fi
}

_ps_pots()
{
	# shellcheck disable=SC2039
	local _jdir _pots _q _p
	_q="$1"
	_jdir="${POT_FS_ROOT}/jails/"
	_pots=$( find "$_jdir/" -type d -mindepth 1 -maxdepth 1 -exec basename {} \; | tr '\n' ' ' )
	for _p in $_pots; do
		_ps_pot "$_p" "$_q"
	done
}

# shellcheck disable=SC2039
pot-ps()
{
	# shellcheck disable=SC2039
	local _q
	_q=
	if ! args=$(getopt hvq "$@") ; then
		ps-help
		${EXIT} 1
	fi
	# shellcheck disable=SC2086
	set -- $args
	while true; do
		case "$1" in
		-h)
			ps-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-q)
			_q="quiet"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done
	_ps_pots "$_q"
}
