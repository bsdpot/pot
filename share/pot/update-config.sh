#!/bin/sh
:

# shellcheck disable=SC2039
update-config-help()
{
	echo "pot update-config [-h] [-p pot|-a]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -a : all the pots'
}

# $1 pname
_update_one_pot()
{
	# shellcheck disable=SC2039
	local _pname _conf
	_pname="$1"
	if ! _is_pot "$_pname" ; then
		_error "Invalid pot name"
		return 1
	fi
	_conf="${POT_FS_ROOT}/jails/${_pname}/conf/pot.conf"

	# default configuration values
	if [ -z "$(_get_conf_var "$_pname" pot.dns)" ]; then
		_debug "pot.dns=inherit"
		echo "pot.dns=inherit" >> "$_conf"
	fi
	if [ -z "$(_get_conf_var "$_pname" pot.cmd)" ]; then
		_debug "pot.cmd=sh /etc/rc"
		echo "pot.cmd=sh /etc/rc" >> "$_conf"
	fi

	# default attributes values
	if [ -z "$(_get_conf_var "$_pname" "pot.attr.no-rc-script")" ]; then
		_debug "pot.attr.no-rc-script=NO"
		echo "pot.attr.no-rc-script=NO" >> "$_conf"
	fi
	if [ -z "$(_get_conf_var "$_pname" "pot.attr.persistent")" ]; then
		_debug "pot.attr.persistent=YES"
		echo "pot.attr.persistent=YES" >> "$_conf"
	fi
	if [ -z "$(_get_conf_var "$_pname" "pot.attr.start-at-boot")" ]; then
		_debug "pot.attr.start-at-boot=NO"
		echo "pot.attr.start-at-boot=NO" >> "$_conf"
	fi
}

pot-update-config()
{
	# shellcheck disable=SC2039
	local _pname _o _all
	_pname=
	_all=
	OPTIND=1
	while getopts "hvp:a" _o ; do
		case "$_o" in
		h)
			update-config-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		a)
			_all="YES"
			;;
		*)
			update-config-help
			${EXIT} 1
		esac
	done

	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	if [ -n "$_pname" ]; then
		if ! _update_one_pot "$_pname" ; then
			${EXIT} 1
		fi
	elif [ "$_all" = "YES" ]; then
		if ! update_all_pots ; then
			${EXIT} 1
		fi
	else 
		_error "A pot name or -a are mandatory"
		update-config-help
		${EXIT} 1
	fi
	${EXIT} 0
}
