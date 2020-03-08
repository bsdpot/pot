#!/bin/sh

# supported releases
term-help()
{
	echo "pot term [-h] [potname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f force: it start the pot, if it'\''s not running'
	echo '  potname : the desired pot'
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
	while getopts "hvf" _o; do
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
		?)
			break
			;;
		esac
	done
	_pname=$1
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		term-help
		${EXIT} 1
	fi
	if ! _is_pot_running $_pname ; then
		if [ "$_force" = "YES" ]; then
			if ! _is_uid0 ; then
				${EXIT} 1
			fi

			pot-cmd start $_pname
			if ! _is_pot_running $_pname ; then
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

	_term $_pname
}
