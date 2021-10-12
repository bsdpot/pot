#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043

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
	local _pname _quiet
	_pname=$1
	_quiet=$2
	if _is_pot_running "$_pname" ; then
		if [ "$_quiet" = "quiet" ]; then
			echo "$_pname"
			return
		fi
		echo "$_pname"
	fi
}

_ps_pots()
{
	local _pots _quiet _p
	_quiet="$1"
	_pots="$( _get_pot_list )"
	for _p in $_pots ; do
		_ps_pot "$_p" "$_quiet"
	done
}

pot-ps()
{
	local _quiet
	_quiet=
	OPTIND=1
	while getopts "hvq" _o ; do
		case "$_o" in
		h)
			ps-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_quiet="quiet"
			;;
		*)
			ps-help
			${EXIT} 1
			;;
		esac
	done
	if [ -z "$_quiet" ]; then
		if ! _is_uid0 quiet ; then
			_info "Need privileges to read internal network status"
		elif _is_vnet_up ; then
			_info "Internal network up"
		else
			_info "Internal network down"
		fi
	fi
	_ps_pots "$_quiet"
}
