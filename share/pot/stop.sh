#!/bin/sh

# supported releases
stop-help()
{
	echo "pot stop [-hv] [potname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  potname : the jail that has to start'
}

# $1 pot name
_js_stop()
{
	local _pname _jdir _epair _ip _pfrules
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	_epair=
	_ip=$( _get_conf_var $_pname ip4 )
	if _is_pot_running "$_pname" ; then
		if _is_pot_vnet "$_pname" ; then
			_epair=$(jexec $_pname ifconfig | grep ^epair | cut -d':' -f1)
		fi
		_debug "Stop the pot $_pname"
		jail -r "$_pname"
		if [ -n "$_epair" ]; then
			_debug "Remove ${_epair%b}[a|b] network interfaces"
			ifconfig "${_epair%b}"a destroy
		else
			if [ "$_ip" != inherit ]; then
				_debug "Remove the $_ip alias"
				ifconfig "${POT_EXTIF}" "$_ip" -alias
			fi
		fi
	fi
	# to be sure that I'm cleaning everything
	if [ -n "$( _get_pot_export_ports $_pname)" ]; then
		_debug "Remove redirection rules from the firewall"
		pfctl -a "pot-rdr/$_pname" -F nat
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
		exit 1
	fi

	set -- $args
	while true; do
		case "$1" in
		-h)
			stop-help
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
		esac
	done
	_pname=$1
	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		stop-help
		exit 1
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
		exit 1
	fi
	_js_rm_resolv $_pname
	_pot_umount "$_pname"
	_epair_cleanup
}
