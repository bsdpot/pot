#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

term-help()
{
	cat <<-"EOH"
	pot term [-hvf] -p potname [pname]
	pot run [-hv] -p potname [pname]
	  -h print this help
	  -v verbose
	  -f : start the pot if it is not running
	  -p potname : the pot to open terminal in

	  pname : pot to open terminal in if "-p potname" not given
	EOH
}

# TODO a configurable shell or a login shell
# $1 pot name
_term()
{
	local _pname
	_pname="$1"
	jexec -l -U root "$_pname"
	# This would perform a login (poudriere approach)
	# jexec "$_pname" env -i TERM="$TERM" /usr/bin/login -fp root
}

pot-term()
{
	local _pname _force
	_pname=
	_force=

	OPTIND=1
	while getopts "hvfp:" _o; do
		case "$_o" in
		h)
			term-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		f)
			_force="YES"
			;;
		p)
			_pname="$OPTARG"
			;;
		?)
			break
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_pname="$(eval echo \$$OPTIND)"
	fi
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		term-help
		${EXIT} 1
	fi
	# shellcheck disable=2086
	if ! _is_pot_running $_pname ; then
		if [ "$_force" = "YES" ]; then
			if ! _is_uid0 ; then
				${EXIT} 1
			fi

			pot-cmd start "$_pname"
			if ! _is_pot_running "$_pname" ; then
				_error "The pot $_pname doesn't start"
				${EXIT} 1
			fi
		else
			_error "The pot $_pname is not running"
			${EXIT} 1
		fi
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	_term "$_pname"
}
