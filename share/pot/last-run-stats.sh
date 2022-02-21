#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

last-run-stats-help()
{
	cat <<-"EOH"
	pot last-run-stats [-hv] [-p pname]
	  -h print this help
	  -v verbose
	  -p pname : pot name
	EOH
}

pot-last-run-stats()
{
	local _pname
	_pname=""
	OPTIND=1
	while getopts "hvp:" _o ; do
		case "$_o" in
		h)
			last-run-stats-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		*)
			last-run-stats-help
			${EXIT} 1
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		last-run-stats-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname"; then
		_error "$_pname is not a pot"
		${EXIT} 1
	fi
	_confdir="${POT_FS_ROOT}/jails/$_pname/conf"
	cat "$_confdir/.last_run_stats" 2>/dev/null || echo "{}"
}
