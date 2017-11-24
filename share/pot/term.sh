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
	jexec $_pname tcsh
}

pot-term()
{
	local _pname _force
	_pname=
	_force=
	args=$(getopt hvf $*)
	if [ $? -ne 0 ]; then
		term-help
		exit 1
	fi

	set -- $args
	while true; do
		case "$1" in
		-h)
			term-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-f)
			_force="YES"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done
	_pname=$1
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		term-help
		exit 1
	fi
	if ! _is_pot_running $_pname ; then
		if [ "$_force" = "YES" ]; then
			pot-cmd start $_pname
			if ! _is_pot_running $_pname ; then
				_error "The pot $_pname doesn't start"
				exit 1
			fi
		else
			_error "The pot $_pname is not running"
			exit 1
		fi
	fi
	_term $_pname
}
