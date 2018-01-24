#!/bin/sh

# supported releases
add-dep-help()
{
	echo "pot add-dep [-hv] -p pot -P depPot"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -P depPot : the pot to run before '
}

# $1 pot
# $2 depPot
_add_dependency()
{
	local _depPot _pname _cdir
	_pname="$1"
	_depPot="$2"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	echo "pot.depend=$_depPot" >> $_cdir/pot.conf
}

pot-add-dep()
{
	local _pname _depPot _mnt_p
	args=$(getopt hvP:p: $*)
	if [ $? -ne 0 ]; then
		add-dep-help
		${EXIT} 1
	fi
	_depPot=
	_pname=
	set -- $args
	while true; do
		case "$1" in
		-h)
			add-dep-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-P)
			_depPot="$2"
			shift 2
			;;
		-p)
			_pname="$2"
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		add-dep-help
		${EXIT} 1
	fi
	if [ -z "$_depPot" ]; then
		_error "A dependency pot is mandatory"
		add-dep-help
		${EXIT} 1
	fi
	if [ "$_pname" = "$_depPot" ]; then
		_error "a pot cannot be run time dependecy of itself"
		add-dep-help
		${EXIT} 1
	fi
	if ! _is_pot $_pname ; then
		_error "pot $_pname is not valid"
		add-dep-help
		${EXIT} 1
	fi
	if ! _is_pot $_depPot ; then
		_error "dependency pot $_depPot is not valid"
		add-dep-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_add_dependency $_pname $_depPot
}
