#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

list-help()
{
	cat <<-"EOH"
	pot list [-hpbfFa] [-qvo]
	  -h print this help
	  -v verbose
	  -q quiet
	  -p list pots (default)
	  -b list bases instead of pots
	  -f list fs components instead of pots
	  -F list available flavours
	  -B list available bridges (network type)
	  -a list everything (incompatible with -q)
	  -o format: output format, one of
		    text - textual (the default)
		    json - JSON format
	EOH
}

# $1 pot name
_ls_info_pot()
{
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
	local _pots _q _format _i
	_q=$1
	_format=$2
	_pots=$( _get_pot_list )
	if [ -z "$_pots" ]; then
		if [ "$_q" != "quiet" ]; then
			if [ "$_format" = "json" ]; then
				echo "[]"
			else
				echo "No pot created yet..."
			fi
		fi
		return
	fi
	if [ "$_format" = "json" ]; then
		printf "["
	fi
	_i=0
	set -- $_pots
	for _p do	
		if [ "$_q" = "quiet" ]; then
        	if [ "$_format" = "json" ]; then
				printf "{\"name\": \"%s\"}" "$_p"
			else
				echo "$_p"
			fi
		else
			_ls_info_pot "$_p" "$_format"
		fi
		_i=$(( _i + 1 ))
		# if not the last item add ,
		if [ "$_i" != "$#" -a "$_format" = "json" ]; then
			printf ","
		fi
	done
	if [ "$_format" = "json" ]; then
		printf "]\\n"
	fi
}

_ls_bases()
{
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

pot-list()
{
	local _obj _q _format
	_obj="pots"
	_format="text"
	_q=
	OPTIND=1
	while getopts "hvbfFapqBo:" _o ; do
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
		o)
			if [ "$OPTARG" = "text" ] || [ "$OPTARG" = "json" ]; then
				_format="$OPTARG"
			else
				_error "Format $OPTARG not supported"
				list-help
				${EXIT} 1
			fi
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
			_ls_pots "$_q" "$_format"
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
