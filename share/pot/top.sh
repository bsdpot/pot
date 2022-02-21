#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

top-help()
{
	cat <<-"EOH"
	pot top [-h] -p pot
	  -h print this help
	  -p pot : the working pot
	EOH
}

pot-top()
{
	local _pname _o
	_pname=
	OPTIND=1
	while getopts "hp:" _o ; do
		case "$_o" in
		h)
			top-help
			${EXIT} 0
			;;
		p)
			_pname="$OPTARG"
			;;
		*)
			top-help
			${EXIT} 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		top-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		top-help
		${EXIT} 1
	fi
	if ! _is_pot_running "$_pname" ; then
		_error "pot $_pname is not in execution"
		top-help
		${EXIT} 1
	fi
	top -J "$_pname"
}
