#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

: "${_POT_INTERNAL_STATUS:="starting started stopping stopped"}"

set-status-help()
{
	cat <<-"EOH"
	Internal command, DO NOT USE IF YOU DON'T KNOW WHAT YOU ARE DOING!
	This command is meant to be invoked using lockf
	pot set-status [-hv] [-p pname] [-s status]
	  -h print this help
	  -v verbose
	  -p pname : pot name
	  -s status : he status [starting started stopping stopped]
	EOH
}

pot-set-status()
{
	local _pname _new_status _current_status _conf
	_pname=""
	_new_status=""
	OPTIND=1
	while getopts "hvp:s:" _o ; do
		case "$_o" in
		h)
			set-status-help
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		s)
			# shellcheck disable=SC2086
			if _is_in_list "$OPTARG" $_POT_INTERNAL_STATUS ; then
				_new_status="$OPTARG"
			else
				_error "$OPTARG is not a valid status"
			fi
			;;
		*)
			set-status-help
			return 1
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-status-help
		return 1
	fi
	if ! _is_pot "$_pname"; then
		_error "$_pname is not a pot"
		return 1
	fi

	_current_status=$(_get_conf_var "$_pname" "pot.status")
	# if current status is equal to new status, it means that some other pot command is
	# taking care of the execution of the transition and an exit code 2 is returned
	if [ "$_current_status" = "$_new_status" ]; then
		return 2
	fi
	# new status can only be accepted from a specific current status
	# any other case, the command return an exit code 1
	case "$_new_status" in
		"starting")
			if [ -n "$_current_status" ] && [ "$_current_status" != "stopped" ]; then
				return 1
			fi
			;;
		"started")
			if [ "$_current_status" != "starting" ]; then
				return 1
			fi
			;;
		"stopping")
			# you can always stop a stopped pot (for cleanup reasons)
			if [ "$_current_status" != "started" ] && [ "$_current_status" != "stopped" ]; then
				return 1
			fi
			;;
		"stopped")
			if [ "$_current_status" != "stopping" ]; then
				return 1
			fi
			;;
	esac
	_conf="${POT_FS_ROOT}/jails/$_pname/conf/pot.conf"

	${SED} -i '' -e "/^pot.status=.*/d" "$_conf"
	echo "pot.status=$_new_status" >> "$_conf"
}
