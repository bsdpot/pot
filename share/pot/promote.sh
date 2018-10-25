#!/bin/sh

promote-help()
{
	echo "pot promote [-hv] -p potname"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p potname : the pot name (mandatory)'
}

pot-promote()
{
	local _pname _origin _jdset
	_pname=
	args=$(getopt hvp: $*)
	if [ $? -ne 0 ]; then
		promote-help
		${EXIT} 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			promote-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-p)
			_pname=$2
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done

	echo '#########################'
	echo '# promote is deprecated #'
	echo '#########################'

	if [ -z "$_pname" ]; then
		_error "-p is missing"
		promote-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pname is not a valid pot"
		promote-help
		${EXIT} 1
	fi
	_jdset=${POT_ZFS_ROOT}/jails/$_pname
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if [ "$( _get_conf_var $_pname pot.level )" = "0" ]; then
		_error "The pot $_pname has level 0. Please promote the related base insted"
		${EXIT} 1
	fi
	if [ "$( _get_conf_var $_pname pot.level )" = "1" ]; then
		_origin=$( zfs get -H origin $_jdset/usr.local | awk '{ print $3 }' )
		if [ "$_origin" != "-" ]; then
			_info "Promoting $_jdset/usr.local (origin $_origin)"
			zfs promote $_jdset/usr.local
		fi
	fi
	_origin=$( zfs get -H origin $_jdset/custom | awk '{ print $3 }' )
	if [ "$_origin" != "-" ]; then
		_info "Promoting $_jdset/custom (origin $_origin)"
		zfs promote $_jdset/custom
	fi
}
