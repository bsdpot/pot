#!/bin/sh
:
# shellcheck disable=SC2039
top-help()
{
	echo "pot top [-h] -p pot"
	echo '  -h print this help'
	echo '  -p pot : the working pot'
}

# shellcheck disable=SC2039
pot-top()
{
	# shellcheck disable=SC2039
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
