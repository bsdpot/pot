#!/bin/sh
:

# shellcheck disable=SC2039
show-help()
{
	echo "pot show [-hvq] [-a|-r|-p potname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quiet'
	echo '  -a all pots'
	echo '  -r all running pots (default)'
	echo '  -p potname select the pot by name'
}

# show pot static information
_show_pot()
{
	# shellcheck disable=SC2039
	local _pname _bname line _dset
	_pname=$1
	printf "pot %s\\n" "$_pname"
	printf "\\tdisk usage      : %s\\n" "$( zfs list -o used -H "${POT_ZFS_ROOT}/jails/$_pname")"

	if _is_verbose ; then
		# TODO show external dataset usage
		_bname=$( _get_pot_base "$_pname" )
		printf "\\tbase usage      : %s\\n" "$( zfs list -o used -H "${POT_ZFS_ROOT}/bases/$_bname")"
		while read -r line ; do
			_dset=$( echo "$line" | awk '{print $1}' )
			if [ "$_dset" = "${_dset#${POT_ZFS_ROOT}/jails/$_pname}" ] &&
				[ "$_dset" = "${_dset#${POT_ZFS_ROOT}/bases/$_bname}" ]; then
				printf "\\tdataset %s usage  : %s\\n" "${_dset##${POT_ZFS_ROOT}/}" "$( zfs list -o used -H "$_dset")"
			fi
		done < "${POT_FS_ROOT}/jails/$_pname/conf/fscomp.conf"
	fi
	if _is_pot_running "$_pname" ; then
		_show_pot_run "$_pname"
	fi
}

# show pot runtime information
# $1 pot name
_show_pot_run()
{
	# shellcheck disable=SC2039
	local _pname _res _vm _pm _ip
	_pname=$1
	if ! _is_uid0 quiet; then
		_info "some runtime information requires root privileges"
		return
	fi
	if ! _is_rctl_available ; then
		_info "runtime memory usage require rctl enabled"
	else
		_res="$(rctl -hu jail:"$_pname" )"
		_vm="$(echo "$_res" | tr ' ' '\n' | grep ^vmemoryuse | cut -d'=' -f2)"
		_pm="$(echo "$_res" | tr ' ' '\n' | grep ^memoryuse | cut -d'=' -f2)"
		printf "\\tvirtual memory  : %s\\n" "$_vm"
		printf "\\tphysical memory : %s\\n" "$_pm"
	fi
	_ip="$( _get_conf_var "$_pname" ip4)"
	if [ "$_ip" != "inherit" ]; then
		if pfctl -s nat -P | grep -qF \ ${_ip}\  ; then
			printf "\\n\\tNetwork port redirection\\n"
			pfctl -s nat -P | grep -F \ ${_ip}\  | sed 's/rdr pass on .* inet proto tcp from any to //g' | sed 's/ =//g' | while read -r rule ; do
				printf "\\t\\t%s\\n" "$rule"
			done
		fi
	fi
}

_show_running_pots()
{
	# shellcheck disable=SC2039
	local _jdir _pots _p _q
	_q=$1
	_jdir="${POT_FS_ROOT}/jails/"
	_pots=$( ls -d $_jdir/*/ 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	for _p in $_pots; do
		if _is_pot_running "$_p" ; then
			if [ "$_q" = "YES" ]; then
				echo "$_p"
			else
				_show_pot "$_p"
			fi
		fi
	done
}

_show_all_pots()
{
	# shellcheck disable=SC2039
	local _jdir _pots _p _q
	_q=$1
	_jdir="${POT_FS_ROOT}/jails/"
	_pots=$( ls -d $_jdir/*/ 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	for _p in $_pots; do
		if [ "$_q" = "YES" ]; then
			echo "$_p"
		else
			_show_pot "$_p"
		fi
	done
}

# shellcheck disable=SC2039
pot-show()
{
	# shellcheck disable=SC2039
	local _pname _running _all
	_pname=
	_running=
	_all=
	_quiet="NO"
	OPTIND=1
	while getopts "hvp:arq" _o ; do
		case "$_o" in
		h)
			show-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		r)
			_running="YES2"
			;;
		a)
			_all="YES"
			;;
		q)
			_quiet="YES"
			;;
		*)
			show-help
			${EXIT} 1
			;;
		esac
	done
	if ( [ -n "$_pname" ] && [ -n "$_all" ] ) ||
		( [ -n "$_pname" ] && [ -n "$_running" ] ) ||
		( [ -n "$_all" ] && [ -n "$_running" ] ); then
		_error "-p -r -a are mutually exclusive"
		show-help
		${EXIT} 1
	fi
	if [ -z "$_pname" ] && 
		[ -z "$_all" ] && 
		[ -z "$_running" ]; then
		_running="YES"
	fi
	if [ -n "$_all" ]; then
		_show_all_pots $_quiet
	elif [ -n "$_running" ]; then
		_show_running_pots $_quiet
	else
		if ! _is_pot "$_pname" ; then
			_error "$_pname is not a valid pot"
			${EXIT} 1
		fi
		_show_pot "$_pname"
	fi
}
