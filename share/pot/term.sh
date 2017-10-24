#!/bin/sh

# supported releases
term-help()
{
	echo "pot term [-h] [potname]"
	echo '  -h print this help'
	echo '  -v verbose'
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
	local _pname
	args=$(getopt hv $*)
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
		_error "The pot $_pname is not running"
		exit 1
	fi
	_term $_pname
}
