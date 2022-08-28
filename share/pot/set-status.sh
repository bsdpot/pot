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
	  -s status : the status [starting started stopping stopped]
	EOH
}

# $1 pot name
_get_status()
{
	local _pname _status_file
	_pname="$1"
	_status_file="${POT_TMP:-/tmp}/pot_status_${_pname}"

	if [ ! -e "$_status_file" ]; then
		return
	fi
	_value="$(grep "^pot.status=" "$_status_file" | tail -n 1 \
		|tr -d ' \t"' | cut -f2 -d'=' )"
	echo "$_value"
}

# $1 pot name
# $2 new status
_set_status()
{
	local _pname _status_file _new_status
	_pname="$1"
	_new_status="$2"
	_status_file="${POT_TMP:-/tmp}/pot_status_${_pname}"

	echo "pot.status=$_new_status" >> "$_status_file"
	# remove first (and outdated) occurrence of pot.status
	${SED} -i '' -n -e ":a" \
		-e '/^pot\.status=/{n;bc' -e ':c' -e 'p;n;bc' -e '}' \
		-e "p;n;ba" "$_status_file"
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

	_current_status=$(_get_status "$_pname")
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
	_set_status "$_pname" "$_new_status"
}
