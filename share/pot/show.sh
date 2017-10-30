#!/bin/sh

# supported releases
show-help()
{
	echo "pot show [-hv] -p potname"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p potname select the pot by name'
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

pot-show()
{
	local _obj
	_pname=
	args=$(getopt hvp: $*)
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
		--)
			shift
			break
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		show-help
		exit 1
	fi
	if ! _is_pot $_pname ; then
		_error "$_pname is not a valid pot"
		exit 1
	fi
	if ! _is_pot_running $_pname ; then
		_error "$_pname is not running - no runtime information available"
		exit 0
	fi
	_show_pot $_pname
}
