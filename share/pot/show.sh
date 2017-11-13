#!/bin/sh

# supported releases
show-help()
{
	echo "pot show [-hv] [-a|-p potname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -a all pots'
	echo '  -p potname select the pot by name'
}

# $1 pot name
_show_pot()
{
	local _pname _res
	local _vm _pm
	_pname=$1
	_res="$(rctl -hu jail:$_pname )"
	_vm="$(echo $_res | tr ' ' '\n' | grep ^vmemoryuse | cut -d'=' -f2)"
	_pm="$(echo $_res | tr ' ' '\n' | grep ^memoryuse | cut -d'=' -f2)"
	printf "pot %s\n" $_pname
	printf "\tvirtual memory  : %s\n" $_vm
	printf "\tphysical memory : %s\n" $_pm
}

_show_all_pots()
{
	local _jdir _pots
	_jdir="${POT_FS_ROOT}/jails/"
	_pots=$( find $_jdir -type d -depth 1 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	for _p in $_pots; do
		if _is_pot_running $_p ; then
			_show_pot $_p
		fi
	done
}

pot-show()
{
	local _obj
	_pname=
	_all=
	args=$(getopt hvp:a $*)
	if [ $? -ne 0 ]; then
		show-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			show-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-p)
			_pname="$2"
			shift 2
			;;
		-a)
			_all="YES"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done
	if [ -z "$_pname" -a -z "$_all" ]; then
		_all="YES"
	fi
	if [ -n "$_all" ]; then
		_show_all_pots
	else
		if ! _is_pot $_pname ; then
			_error "$_pname is not a valid pot"
			exit 1
		fi
		if ! _is_pot_running $_pname ; then
			_error "$_pname is not running - no runtime information available"
			exit 0
		fi
		_show_pot $_pname
	fi
}
