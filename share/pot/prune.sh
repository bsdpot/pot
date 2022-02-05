#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043

prune-help()
{
	echo "pot prune [-hvq]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quite - prune with no output'
	echo '  -g grace period - do not prune pots that just finished executing'
	echo '  -n dry-run - do not destroy anything'
}

# $1 pot name
_prune_pot()
{
	local _pname _quiet _dry_run _grace_period _confdir
	_pname=$1
	_dry_run=$2
	_quiet=$3
	_grace_period=$4
	_confdir="${POT_FS_ROOT}/jails/$_pname/conf"

	if ! _is_pot_running "$_pname" ; then
		if ! _is_pot_prunable "$_pname" ; then
			return
		fi
		if [ "$( _get_conf_var "$_pname" "pot.attr.to-be-pruned" )" != "YES" ]; then
			return
		fi
		if [ "$_grace_period" = "YES" ]; then
			# check if just finished running
			if find "$_confdir/.last_run_stats" -mtime -1m 2>/dev/null | \
			    grep -q "."; then
				return
			fi

			sleep 2 # give pot-start a chance to write .last_run_stats

			# check again if just finished running
			if find "$_confdir/.last_run_stats" -mtime -1m 2>/dev/null | \
			    grep -q "."; then
				return
			fi

			if _is_pot_running "$_pname" ; then
				return
			fi
		fi

		_info "Pruning $_pname"
		if [ "$_dry_run" = "YES" ]; then
			return
		fi
		pot-cmd stop "$_pname"
		if ! pot-cmd destroy -p "$_pname" ; then
			_qerror "$_quiet" "Error while pruning $_pname"
		else
			_info "Pruned $_pname"
		fi
	fi
}

_prune_pots()
{
	local _pots _dry_run _quiet _grace_period _p
	_dry_run="$1"
	_quiet="$2"
	_grace_period="$3"
	_pots="$( _get_pot_list )"
	for _p in $_pots; do
		_prune_pot "$_p" "$_dry_run" "$_quiet" "$_grace_period"
	done
}

pot-prune()
{
	local _quiet _dry_run
	_quiet=
	_grace_period="NO"
	_dry_run="NO"
	OPTIND=1
	while getopts "hvqgn" _o ; do
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
		g)
			_grace_period="YES"
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
	_prune_pots "$_dry_run" "$_quiet" "$_grace_period"
}
