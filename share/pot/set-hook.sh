#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

set-hook-help() {
	cat <<-"EOH"
	pot set-hook [-hv] -p pot [-s hook]
	  -h print this help
	  -v verbose
	  -p pot : the working pot
	  -s hook : the pre-start hook
	  -S hook : the post-start hook
	  -t hook : the pre-stop hook
	  -T hook : the post-stop hook
	EOH
}

# $1 pot
# $2 script name
# $3 hook type
_set_hook()
{
	local _pname _script
	_pname="$1"
	_script="$2"
	_hooktype="$3"
	cp "$_script" "$POT_FS_ROOT/jails/$_pname/conf/${_hooktype}.sh"
}

# $1 hook script
_is_valid_hook()
{
	if [ -x "$1" ]; then
		return 0 # true
	fi
	_error "$1 not a valid hook"
	return 1 # false
}

pot-set-hook()
{
	local _pname _prestart _poststart _prestop _poststop
	_pname=
	_prestart=
	_poststart=
	_prestop=
	_poststop=
	OPTIND=1
	while getopts "hvp:s:S:t:T:" _o ; do
		case "$_o" in
		h)
			set-hook-help
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		s)
			if _is_valid_hook "${OPTARG}" ; then
				_prestart="${OPTARG}"
			fi
			;;
		S)
			if _is_valid_hook "${OPTARG}" ; then
				_poststart="${OPTARG}"
			fi
			;;
		t)
			if _is_valid_hook "${OPTARG}" ; then
				_prestop="${OPTARG}"
			fi
			;;
		T)
			if _is_valid_hook "${OPTARG}" ; then
				_poststop="${OPTARG}"
			fi
			;;
		p)
			_pname="$OPTARG"
			;;
		?)
			set-hook-help
			return 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-hook-help
		return 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		set-hook-help
		return 1
	fi
	if [ -z "$_prestart" ] && [ -z "$_poststart" ] &&
		[ -z "$_prestop" ] && [ -z "$_poststop" ]; then
		_error "No hooks provided - at least one hook as to be set"
		set-hook-help
		return 1
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	if [ -n "$_prestart" ]; then
		_set_hook "$_pname" "$_prestart" "prestart"
	fi
	if [ -n "$_poststart" ]; then
		_set_hook "$_pname" "$_poststart" "poststart"
	fi
	if [ -n "$_prestop" ]; then
		_set_hook "$_pname" "$_prestop" "prestop"
	fi
	if [ -n "$_poststop" ]; then
		_set_hook "$_pname" "$_poststop" "poststop"
	fi
}
