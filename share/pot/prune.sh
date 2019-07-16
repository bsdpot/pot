#!/bin/sh

# shellcheck disable=SC2039
prune-help()
{
	echo "pot prune [-hvq]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quite - prune with no output'
	echo '  -n dry-run - do not destroy anything'
}

# $1 pot name
_prune_pot()
{
	# shellcheck disable=SC2039
	local _pname _quiet _dry_run
	_pname=$1
	_dry_run=$2
	_quiet=$3
	if ! _is_pot_running "$_pname" ; then
		if [ "$( _get_conf_var "$_pname" "pot.attr.prunable" )" = "YES" ]; then
			_info "Pruning $_pname"
			if [ "$_dry_run" = "YES" ]; then
				return
			fi
			if ! pot-cmd destroy -p "$_pname" ; then
				_qerror "$_quiet" "Error while pruning $_pname"
			else
				_info "Pruned $_pname"
			fi
		fi
	fi
}

_prune_pots()
{
	# shellcheck disable=SC2039
	local _pots _dry_run _quiet _p
	_dry_run="$1"
	_quiet="$2"
	_pots="$( _get_pot_list )"
	for _p in $_pots; do
		_prune_pot "$_p" "$_dry_run" "$_quiet"
	done
}

# shellcheck disable=SC2039
pot-prune()
{
	# shellcheck disable=SC2039
	local _quiet _dry_run
	_quiet=
	_dry_run="NO"
	OPTIND=1
	while getopts "hvqn" _o ; do
		case "$_o" in
		h)
			prune-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_quiet="quiet"
			;;
		n)
			_dry_run="YES"
			;;
		*)
			prune-help
			${EXIT} 1
			;;
		esac
	done
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_prune_pots "$_dry_run" "$_quiet"
}
