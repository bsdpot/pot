#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

signal-help()
{
	cat <<-"EOH"
	pot signal [-hv] [-s signal] [-P pid] [-m pattern]-p pot
	  -h print this help
	  -v verbose
	  -f : force - always returns success, even if no process could be killed
	  -s signal : the symbolic name of the signal to send to the process,
	              defaults to SIGINFO. Use `killall -l` to get a list of
	              supported signals.
	  -P pid : the pid inside the pot to send the signal to.
	           for non-persistent pots this defaults to
	           the pid of the main process
          -m pattern : A pattern to match (overrides -P)
	  -p pot : the pot image
	EOH
}

pot-signal()
{
	local _pname _pid _match _signal _tmpfile _force _ret
	_pname=
	_pid=
	_match=
	_signal="SIGINFO"
	_force="NO"
	OPTIND=1
	while getopts "hvfs:P:m:p:" _o ; do
		case "$_o" in
		h)
			signal-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		f)
			_force="YES"
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

	if ! killall -l | xargs | tr ' ' '\n' |\
	    sed 's/^\(.*\)$/\1\nSIG\1/g' | grep -qFx "$_signal"; then
		_error "Invalid signal, valid signals: $(killall -l | xargs)"
		${EXIT} 1		
	fi

	if [ -n "$_pid" ]; then
		case "$_pid" in
		''|*[!0-9]*)
			_error "Invalid pid"
			${EXIT} 1
			;;
		*)
			;;
		esac
	fi

	if ! _is_pot_running "$_pname" ; then
		if [ "$_force" = "YES" ]; then
			_info "The pot is not running"
			return 0
		fi
		_error "The pot is not running"
		${EXIT} 1
	fi

	if [ -n "$_match" ]; then
		_info "Sending $_signal by pattern to pot $_pname"
		pkill "-$_signal" -j "$_pname" "$_match"
		_ret=$?
	elif [ -n "$_pid" ]; then
		_info "Sending $_signal to pid $_pid in pot $_pname"
		_tmpfile=$(mktemp \
		  "${POT_TMP:-/tmp}/pot_sigpid_${_pname}${POT_MKTEMP_SUFFIX}"
		  ) || exit 1
		echo "$_pid" >"$_tmpfile" || exit 1
		pkill "-$_signal" -j "$_pname" -F "$_tmpfile"
		_ret=$?
		rm -f "$_tmpfile"
	else
		_info "Sending $_signal to main process of pot $_pname"
		pkill "-$_signal" -j "$_pname" \
		  -F "${POT_TMP:-/tmp}/pot_main_pid_${_pname}"
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
