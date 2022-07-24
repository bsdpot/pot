#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

signal-help()
{
	cat <<-"EOH"
	pot signal [-hvflC] [-s signal] [-P pid] [-m pattern] -p pot
	  -h print this help
	  -v verbose
	  -C : check/dry-run: show processes that would match
	  -f : force - always returns success, even if signalling failed
	  -l : list supported signals
	  -s signal : the symbolic name of the signal to send to the process,
	              defaults to SIGINFO
	  -P pid : the pid inside the pot to send the signal to
	  -m pattern : A pattern to match
	  -p pot : the pot image

	  Parameters -P and -m are mutually exclusive. If neither of them is
	  is specified and the pot is non-persistent, the signal is delivered
	  to the main process of the pot.

	  For persistent pots, specifying one of -P and -m is mandatory.
	EOH
}

# Get a list of supported signal names
_get_signal_names()
{
	killall -l | xargs
}

# Validate if symbolic signal name is supported
_validate_signal_name()
{
	local _signame
	_signame="$1"

	if ! _get_signal_names | xargs | tr ' ' '\n' |\
	    sed 's/^\(.*\)$/\1\nSIG\1/g' | grep -qFx "$_signame"; then
		return 1
	fi
}

# Validate if a pid is syntactically acceptable
_validate_pid()
{
	case "$_pid" in
	''|*[!0-9]*)
		return 1
		;;
	*)
		;;
	esac
}

# Actually send signal to process inside pot
# $1 pot name
# $2 signal
# $3 pid
# $4 match
# $5 force (YES/NO)
# $6 dry-run (YES/NO)
_send_signal()
{
	local _pname _signal _pid _match _force _dry_run
	local _cmd _tmpfile _persist _ret

	_pname="$1"
	_signal="$2"
	_pid="$3"
	_match="$4"
	_force="$5"
	_dry_run="$6"

	if [ "$_dry_run" = "YES" ]; then
		_cmd=$(_save_params "pgrep")
	else
		_cmd=$(_save_params "pkill" "-$_signal")
	fi

	# load kill command into $@
	eval "set -- $_cmd"

	if [ -n "$_match" ]; then
		_info "Sending $_signal by pattern to pot $_pname"
		"$@" -j "$_pname" "$_match"
		_ret=$?
	elif [ -n "$_pid" ]; then
		_info "Sending $_signal to pid $_pid in pot $_pname"
		_tmpfile=$(mktemp \
		  "${POT_TMP:-/tmp}/pot_sigpid_${_pname}${POT_MKTEMP_SUFFIX}"
		  ) || ${EXIT} 1
		echo "$_pid" >"$_tmpfile" || ${EXIT} 1
		"$@" -j "$_pname" -F "$_tmpfile"
		_ret=$?
		rm -f "$_tmpfile"
	else
		_info "Sending $_signal to main process of pot $_pname"
		_persist="$(_get_conf_var "$_pname" "pot.attr.persistent")"
		if [ "$_persist" != "NO" ]; then
			if [ "$_force" = "YES" ]; then
				_info "Persistent pots have no main process"
				return 0
			else
				_error "Persistent pots have no main process"
				return 1
			fi
		fi
		"$@" -j "$_pname" -F "${POT_TMP:-/tmp}/pot_main_pid_${_pname}"
		_ret=$?
	fi

	if [ $_ret -ne 0 ]; then
		if [ "$_force" = "YES" ]; then
			_info "Sending signal failed"
			_ret=0
		else
			_error "Sending signal failed"
		fi
	fi

	return $_ret
}

pot-signal()
{
	local _pname _signal _pid _match _force _dry_run
	_pname=
	_pid=
	_match=
	_signal="SIGINFO"
	_force="NO"
	_dry_run="NO"
	OPTIND=1
	while getopts "hvflCs:P:m:p:" _o ; do
		case "$_o" in
		h)
			signal-help
			${EXIT} 0
			;;
		l)
			_get_signal_names
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		f)
			_force="YES"
			;;
		C)
			_dry_run="YES"
			;;
		s)
			_signal="$OPTARG"
			;;
		P)
			_pid="$OPTARG"
			;;
		m)
			_match="$OPTARG"
			;;
		p)
			_pname="$OPTARG"
			;;
		*)
			signal-help
			${EXIT} 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		signal-help
		${EXIT} 1
	fi

	if ! _validate_signal_name "$_signal"; then
		_error "Invalid signal, valid signals: $(_get_signal_names)"
		${EXIT} 1
	fi

	if [ -n "$_pid" ] && [ -n "$_match" ]; then
		_error "Process ID and pattern match are mutually exclusive"
		${EXIT} 1
	fi

	if [ -n "$_pid" ] && ! _validate_pid "$_pid"; then
		_error "Invalid pid"
		${EXIT} 1
	fi

	if ! _is_pot_running "$_pname" ; then
		if [ "$_force" = "YES" ]; then
			_info "The pot is not running"
			return 0
		fi
		_error "The pot is not running"
		${EXIT} 1
	fi

	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	_send_signal "$_pname" "$_signal" "$_pid" "$_match" "$_force" "$_dry_run"
}
