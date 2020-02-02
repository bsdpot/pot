#!/bin/sh

# supported releases
stop-help()
{
	echo "pot stop [-hv] [potname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  potname : the jail that has to start'
}

_js_cpu_rebalance()
{
	if ! _tmpfile=$(mktemp -t "potcpu.XXXXXX") ; then
		_error "not able to create temporary file - umount failed"
		return
	fi
	potcpu rebalance > "$_tmpfile"
	while read -r cpuset_cmd ; do
		eval "$cpuset_cmd"
	done < "$_tmpfile"
}

# $1 pot name
_js_stop()
{
	local _pname _jdir _epair _ip _aname
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	_epair=
	_network_type=$( _get_pot_network_type "$_pname" )
	if _is_pot_running "$_pname" ; then
		if _is_pot_vnet "$_pname" ; then
			_epair=$(jexec $_pname ifconfig | grep ^epair | cut -d':' -f1)
		fi

		if [ -x "${POT_FS_ROOT}/jails/$_pname/conf/prestop.sh" ]; then
			_info "Executing the pre-stop script for the pot $_pname"
			(
				eval $( pot info -E -p "$_pname" )
				${POT_FS_ROOT}/jails/$_pname/conf/prestop.sh
			)
		fi
		_debug "Stop the pot $_pname"
		jail -q -r "$_pname"
		if [ -n "$_epair" ]; then
			_debug "Remove ${_epair%b}[a|b] network interfaces"
			sleep 1 # try to avoid a race condition in the epair driver, potentially causing a kernel panic
			ifconfig "${_epair%b}"a destroy
		else
			if [ "$_network_type" = "alias" ]; then
				_ip=$( _get_conf_var "$_pname" ip )
				_debug "Remove the $_ip alias"
				if potnet ip4check -H "$_ip" ; then
					ifconfig "${POT_EXTIF}" inet "$_ip" -alias
				else
					ifconfig "${POT_EXTIF}" inet6 "$_ip" -alias
				fi
			fi
		fi
	fi
	if [ -c "/dev/pf" ]; then
		_aname="$( _get_pot_rdr_anchor_name "$_pname" )"
		pfctl -a "pot-rdr/$_aname" -F nat -q
	fi

	if [ -r "$_jdir/ncat.pid" ]; then
		pkill -F "$_jdir/ncat.pid" -f "ncat-$_pname"
		rm -f "$_jdir/ncat.pid"
	elif pgrep -q -f "$_jdir/ncat-$_pname" ; then
		pkill -f "$_jdir/ncat-$_pname"
	fi

	if [ -x "${POT_FS_ROOT}/jails/$_pname/conf/poststop.sh" ]; then
		_info "Executing the post-stop script for the pot $_pname"
		(
			eval $( pot info -E -p "$_pname" )
			${POT_FS_ROOT}/jails/$_pname/conf/poststop.sh
		)
	fi
	return 0 # true
}

# $1 pot name
_js_rm_resolv()
{
	local _pname _jdir
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	if [ -f $_jdir/m/etc/resolv.conf ]; then
		rm -f $_jdir/m/etc/resolv.conf
	fi
}

_epair_cleanup()
{
	local _epairs_a _epairs_b
	_epairs_b="$(ifconfig | grep '^epair[0-9][0-9]*b' | sed 's/:.*$//' | sort)"
	_epairs_a="$(ifconfig | grep '^epair[0-9][0-9]*a' | sed 's/:.*$//' | sort)"
	for _e in $_epairs_b ; do
		if _is_in_list ${_e%b}a $_epairs_a ; then
			ifconfig $_e destroy
		fi
	done
}

pot-stop()
{
	local _pname
	args=$(getopt hv $*)
	if [ $? -ne 0 ]; then
		stop-help
		${EXIT} 1
	fi

	set -- $args
	while true; do
		case "$1" in
		-h)
			stop-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done
	_pname=$1
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		stop-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" quiet ; then
		_error "The pot $_pname is not a valid pot"
		stop-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	if ! _js_stop $_pname ; then
		_error "Stop the pot $_pname failed"
		${EXIT} 1
	fi
	_js_rm_resolv $_pname
	_pot_umount "$_pname"
	_epair_cleanup
}
