#!/bin/sh
:
# shellcheck disable=SC3033
list-help()
{
	echo "pot list [-hpbfFa][-qv]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quiet'
	echo '  -p list pots (default)'
	echo '  -b list bases instead of pots'
	echo '  -f list fs components instead of pots'
	echo '  -F list available flavours'
	echo '  -B list available bridges (newtork type)'
	echo '  -a list everything (-q not compatible)'
}

# $1 pot name
_ls_info_pot()
{
	# shellcheck disable=SC2039
	local _pname _cdir _lvl
	_pname=$1
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_lvl=$( _get_conf_var "$_pname" pot.level)
	printf "pot name : %s\\n" "$_pname"
	printf "\\tnetwork : %s\\n" "$( _get_conf_var "$_pname" network_type)"
	if [ "$( _get_conf_var "$_pname" network_type)" != "inherit" ]; then
		printf "\\tip : %s\\n" "$( _get_ip_var "$_pname" )"
	fi
	if _is_pot_running "$_pname" ; then
		printf "\\tactive : true\\n"
	else
		printf "\\tactive : false\\n"
	fi
	if _is_verbose ; then
		printf "\\tbase : %s\\n" "$( _get_conf_var "$_pname" pot.base)"
		printf "\\tlevel : %s\\n" "$_lvl"
		if [ "$_lvl" -eq 2 ]; then
			printf "\\tbase pot : %s\\n" "$( _get_conf_var "$_pname" pot.potbase)"
		fi
		printf "\\tdatasets:\\n"
		_print_pot_fscomp "$_cdir/fscomp.conf"
		printf "\\tsnapshot:\\n"
		_print_pot_snaps "$_pname"
	fi
	echo
}

_ls_pots()
{
	# shellcheck disable=SC2039
	local _pots _q
	_q=$1
	_pots=$( _get_pot_list )
	if [ -z "$_pots" ]; then
		if [ "$_q" != "quiet" ]; then
			echo "No pot created yet..."
		fi
		return
	fi
	for _p in $_pots; do
		if [ "$_q" = "quiet" ]; then
			echo "$_p"
		else
			_ls_info_pot "$_p"
		fi
	done
}

_ls_bases()
{
	# shellcheck disable=SC2039
	local _bdir _bases _q
	_q=$1
	_bdir="${POT_FS_ROOT}/bases/"
	# shellcheck disable=SC2011
	_bases=$(  ls -d "$_bdir"/*/ 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	if [ "$_q" = "quiet" ]; then
		for _b in $_bases; do
			 echo "$_b"
		done
	else
		for _b in $_bases; do
			 echo "bases: $_b"
		done
	fi
}

_ls_fscomp()
{
	# shellcheck disable=SC2039
	local _fscomps _q
	_q=$1
	_fscomps=$( zfs list -d 1 -Ho name "${POT_ZFS_ROOT}/fscomp" | sed '1d' | xargs -I {} basename {} | tr '\n' ' ' )
	if [ "$_q" = "quiet" ]; then
		for _f in $_fscomps; do
			 echo "$_f"
		done
	else
		for _f in $_fscomps; do
			 echo "fscomp: $_f"
		done
	fi
}

_ls_flavour()
{
	# shellcheck disable=SC2039
	local _flv1 _flv2 _flv _q
	_q=$1
	# shellcheck disable=SC2010
	_flv1=$( ls "${_POT_FLAVOUR_DIR}" | grep -v .sh$ | xargs basename )
	# shellcheck disable=SC2011
	_flv2=$( ls "${_POT_FLAVOUR_DIR}"/*.sh | xargs basename | sed 's/\.sh//' )
	# shellcheck disable=SC2086
	_flv=$( printf "%s\\n%s\\n" $_flv1 $_flv2 | sort -u | tr '\n' ' ' )
	if [ "$_q" = "quiet" ]; then
		for _f in $_flv ; do
			echo "$_f"
		done
	else
		for _f in $_flv ; do
			echo "flavour: $_f"
		done
	fi
}

_ls_bridges()
{
	# shellcheck disable=SC2039
	local _bridges _q
	_q=$1
	_bridges=$( _get_bridge_list )
	if [ "$_q" = "quiet" ]; then
		for _B in $_bridges; do
			 echo "$_B"
		done
	else
		for _B in $_bridges; do
			 echo "bridge: $_B"
		done
	fi
}

# shellcheck disable=SC3033
pot-list()
{
	# shellcheck disable=SC2039
	local _obj _q
	_obj="pots"
	_q=
	OPTIND=1
	while getopts "hvbfFapqB" _o ; do
		case "$_o" in
		h)
			list-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_q="quiet"
			;;
		p)
			if [ "$_obj" != "pots" ]; then
				_error "Options -b -p -f -F -B -a are mutually exclusive"
				list-help
				${EXIT} 1
			fi
			_obj="ppots"
			;;
		b)
			if [ "$_obj" != "pots" ]; then
				_error "Options -b -p -f -F -B -a are mutually exclusive"
				list-help
				${EXIT} 1
			fi
			_obj="bases"
			;;
		f)
			if [ "$_obj" != "pots" ]; then
				_error "Options -b -p -f -F -B -a are mutually exclusive"
				list-help
				${EXIT} 1
			fi
			_obj="fscomp"
			;;
		F)
			if [ "$_obj" != "pots" ]; then
				_error "Options -b -p -f -F -B -a are mutually exclusive"
				list-help
				${EXIT} 1
			fi
			_obj="flavour"
			;;
		B)
			if [ "$_obj" != "pots" ]; then
				_error "Options -b -p -f -F -B -a are mutually exclusive"
				list-help
				${EXIT} 1
			fi
			_obj="bridges"
			;;

		a)
			if [ "$_obj" != "pots" ]; then
				_error "Options -b -p -f -F -B -a are mutually exclusive"
				list-help
				${EXIT} 1
			fi
			_obj="all"
			;;
		*)
			list-help
			${EXIT} 1
			;;
		esac
	done
	if [ "$_obj" = all ] && [ "$_q" = "quiet" ]; then
		_error "Options -a and -q are incompatible"
		list-help
		${EXIT} 1
	fi
	case $_obj in
		"pots"|"ppots")
			_ls_pots "$_q"
			;;
		"bases")
			_ls_bases "$_q"
			;;
		"fscomp")
			_ls_fscomp "$_q"
			;;
		"flavour")
			_ls_flavour "$_q"
			;;
		"bridges")
			_ls_bridges "$_q"
			;;
		"all")
			_ls_bases
			_ls_pots
			_ls_fscomp
			_ls_flavour
			_ls_bridges
			;;
	esac
}
