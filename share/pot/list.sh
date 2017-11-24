#!/bin/sh

# supported releases
list-help()
{
	echo "pot list [-hvb]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -b list bases instead of pots'
	echo '  -f list fs components instead of pots'
}

# $1 pot name
_ls_info_pot()
{
	local _pname _cdir _lvl
	_pname=$1
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_lvl=$( _get_conf_var $_pname pot.level)
	printf "pot name\t%s\n" $_pname
	printf "\t\tbase : %s\n" "$( _get_conf_var $_pname pot.base)"
	printf "\t\tlevel : %s\n" "$_lvl"
	if [ $_lvl -eq 2 ]; then
		printf "\t\tbase pot : %s\n" "$( _get_conf_var $_pname pot.potbase)"
	fi
	printf "\t\tip4 : %s\n" "$( _get_conf_var $_pname ip4)"
	if _is_pot_running $_pname ; then
		printf "\t\tactive : true\n"
	else
		printf "\t\tactive : false\n"
	fi
	echo
}

_ls_pots()
{
	local _jdir _pots
	_jdir="${POT_FS_ROOT}/jails/"
	_pots=$( find $_jdir -type d -depth 1 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	for _p in $_pots; do
		_ls_info_pot $_p
	done
}

_ls_bases()
{
	local _bdir _bases
	_bdir="${POT_FS_ROOT}/bases/"
	_bases=$( find $_bdir -type d -depth 1 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	for _b in $_bases; do
		 echo "bases: $_b"
	done
}

_ls_fscomp()
{
	local _fdir _fscomps
	_fdir="${POT_FS_ROOT}/fscomp/"
	_fscomps=$( ls -l $_fdir | grep ^d | awk '{print $9}' )
	for _f in $_fscomps; do
		 echo "fscomp: $_f"
	done
}

pot-list()
{
	local _obj
	_obj="pots"
	args=$(getopt hvbf $*)
	if [ $? -ne 0 ]; then
		list-help
		exit 1
	fi
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
		-b)
			_obj="bases"
			shift
			;;
		-f)
			_obj="fscomp"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done
	case $_obj in
		"pots")
			_ls_pots
			;;
		"bases")
			_ls_bases
			;;
		"fscomp")
			_ls_fscomp
			;;
	esac
}
