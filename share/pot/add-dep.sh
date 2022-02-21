#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

add-dep-help()
{
	cat <<-"EOH"
	pot add-dep [-hv] -p potname -P depPot
	  -h print this help
	  -v verbose
	  -p potname : the working pot
	  -P depPot : the pot to depend on. Will be started automatically
	              before starting the working pot "potname".
	EOH
}

# $1 pot
# $2 depPot
_add_dependency()
{
	local _depPot _pname _cdir
	_pname="$1"
	_depPot="$2"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	echo "pot.depend=$_depPot" >> "$_cdir"/pot.conf
}

pot-add-dep()
{
	local _pname _depPot
	_depPot=
	_pname=
	OPTIND=1
	while getopts "hvp:P:" _o ; do
		case "$_o" in
		h)
			add-dep-help
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		P)
			_depPot="$OPTARG"
			;;
		p)
			_pname="$OPTARG"
			;;
		*)
			add-dep-help
			return 1
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		add-dep-help
		return 1
	fi
	if [ -z "$_depPot" ]; then
		_error "A dependency pot is mandatory"
		add-dep-help
		return 1
	fi
	if [ "$_pname" = "$_depPot" ]; then
		_error "a pot cannot be run time dependecy of itself"
		add-dep-help
		return 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		add-dep-help
		return 1
	fi
	if ! _is_pot "$_depPot" ; then
		_error "dependency pot $_depPot is not valid"
		add-dep-help
		return 1
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	_add_dependency "$_pname" "$_depPot"
}
