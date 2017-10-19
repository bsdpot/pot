#!/bin/sh

# supported releases
list-help()
{
	echo "pot list [-hv]"
	echo '  -h print this help'
	echo '  -v verbose'
}

# $1 jail name
_js_is_running()
{
	local _jname _jlist
	_jname="$1"
	_jlist="$(jls -N | sed 1d | awk '{print $1}')"
	if _is_in_list $_jname $_jlist ; then
		return 0 # true
	fi
	return 1 # false
}

# $1 pot name
_ls_info_pot()
{
	local _pname _cdir
	_pname=$1
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	printf "pot name\t%s\n" $_pname
	if grep -q 'ip4 = inherit' $_cdir/jail.conf ; then
		printf "\t\tip4 : inherited\n"
	else
		printf "\t\tip4 : %s\n" $(awk '/ip4.addr/ { print $3 }' $_cdir/jail.conf | sed 's/;//')
	fi
	echo
}

# $1 pot name
_ls_pots()
{
	local _jdir _pots
	_jdir="${POT_FS_ROOT}/jails/"
	_pots=$( find /opt/pot/jails -type d -depth 1 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	for _p in $_pots; do
		_ls_info_pot $_p
	done
}

pot-list()
{
	args=$(getopt hv $*)

	set -- $args
	while true; do
		case "$1" in
		-h)
			list-help
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
		*)
			list-help
			exit 1
		esac
	done
	_ls_pots
}
