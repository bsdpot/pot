#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

exec-help()
{
	cat <<-"EOH"
	pot exec [-hvdt] [-e var=value] [-u username] [-U username]
	         -p pot COMMAND
	  -h print this help
	  -v verbose
	  -d detach, run in background
	  -t allocate pty
	  -e var=value : set environment variable, can be repeated
	  -u username: The username from the host environment as whom the
	               command should run
	  -U username: The username from the pot environment as whom the
	               command should run
	  -p pot : the pot image

	  COMMAND is the command to execute and will be executed in the
	  username's $HOME
	EOH
}

# Actually send signal to process inside pot
# $1 pot name
# $2 detach
# $3 env (encoded with save_params)
# $4 alloc_pty
# $5 user_host
# $6 user_pot
# $7-$n command/args
_exec_cmd()
{
	local _pname _detach _env _alloc_pty _user_host _user_pot
	local _cmd

	_pname=$1
	_detach=$2
	_env=$3
	_alloc_pty=$4
	_user_host=$5
	_user_pot=$6
	shift 6  # $@ contains command/args now

	_debug "Exec in $_pname, cmd: $*"

	# assemble command
	_cmd=
	if [ "$_alloc_pty" = "YES" ]; then
		_cmd="$_cmd"$(_save_params "script" "-q" "/dev/null")
	fi
	_cmd="$_cmd"$(_save_params "jexec" "-l")
	if [ -n "$_user_host" ]; then
		_cmd="$_cmd"$(_save_params "-u" "$_user_host")
	elif [ -n "$_user_pot" ]; then
		_cmd="$_cmd"$(_save_params "-U" "$_user_pot")
	fi
	_cmd="$_cmd"$(_save_params "$_pname")
	_cmd="$_cmd$_env"$(_save_params "$@")

	# execute command
	eval "set -- $_cmd"
	if [ "$_detach" = "YES" ]; then
		nohup "$@" >/dev/null 2>&1 &
	else
		"$@"
	fi
	_ret=$?

	return $_ret
}

pot-exec()
{
	local _pname _detach _env _alloc_pty _user_host _user_pot _ret
	_pname=
	_detach="NO"
	_env=$(_save_params "env")
	_alloc_pty="NO"
	_user_host=
	_user_pot=
	OPTIND=1
	while getopts "hvdtp:e:u:U:" _o ; do
		case "$_o" in
		h)
			exec-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;

		d)
			_detach="YES"
			;;
		t)
			_alloc_pty="YES"
			;;
		e)
			if [ "$OPTARG" = "${OPTARG#*=}" ]; then
				# the argument doesn't have an equal sign
				_error "$OPTARG not in a valid form"
				_error "VARIABLE=value is accetped"
				exec-help
				${EXIT} 1
			fi
			_env="$_env"$(_save_params "$OPTARG")
			;;
		u)
			_user_host="$OPTARG"
			;;
		U)
			_user_pot="$OPTARG"
			;;
		p)
			_pname="$OPTARG"
			;;
		*)
			exec-help
			${EXIT} 1
		esac
	done

	shift $((OPTIND-1))

	if [ "$#" -eq 0 ]; then
		_error "A command is mandatory"
		${EXIT} 1
	fi

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		exec-help
		${EXIT} 1
	fi

	if [ -n "$_user_host" ] && [ -n "$_user_pot" ]; then
		_error "Parameters -u and -U are mutually exclusive"
		${EXIT} 1
	fi

	if ! _is_pot_running "$_pname" ; then
		_error "The pot is not running"
		${EXIT} 1
	fi

	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	_exec_cmd "$_pname" "$_detach" "$_env" \
	  "$_alloc_pty" "$_user_host" "$_user_pot" "$@"
}
