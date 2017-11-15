#!/bin/sh

# supported releases
start-help()
{
	echo "pot start [-h] [potname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -s take a snapshot before to start'
	echo '     snapshots are identified by the epoch'
	echo '     all zfs datasets under the jail dataset are considered'
	echo '  -S take a snapshot before to start'
	echo '     snapshots are identified by the epoch'
	echo '     all zfs datasets mounted in rw are considered (full)'
	echo '  potname : the jail that has to start'
}

# $1 jail name
_js_mount()
{
	local _pname _node _mnt_p _opt
	_pname=$1
	while read -r line ; do
		_node=$( echo $line | awk '{print $1}' )
		_mnt_p=$( echo $line | awk '{print $2}' )
		_opt=$( echo $line | awk '{print $3}' )
		mount_nullfs -o {_opt:-rw} $_node $_mnt_p
		# TODO - check the return value
	done < ${POT_FS_ROOT}/jails/$_pname/conf/fs.conf

	mount -t tmpfs tmpfs ${POT_FS_ROOT}/jails/$_pname/m/tmp
}

# $1 jail name
_js_resolv()
{
	local _pname _jdir
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	if [ ! -r /etc/resolv.conf ]; then
		_error "No resolv.conf found in /etc"
		return 1 # false
	fi
	if [ -d $_jdir/custom/etc ]; then
		cp /etc/resolv.conf $_jdir/custom/etc
	else
		if [ -d $_jdir/m/etc ]; then
			cp /etc/resolv.conf $_jdir/m/etc
		else
			_info "No custom etc directory found, resolv.conf not loaded"
		fi
	fi
	return 0
}

_js_vnet()
{
	local _pname _bridge _epair _epairb _ip
	_pname=$1
	if ! _is_vnet_up ; then
		_info "No pot bridge found! Calling vnet-start to fix the issue"
		pot-cmd vnet-start
	fi
	_bridge=$(_pot_bridge)
	_epair=$(ifconfig epair create)
	_epairb="${_epair%a}b"
	if [ -z "${_epair}" ]; then
		return 1 # false
	fi
	ifconfig ${_epair} up
	ifconfig $_bridge addm ${_epair}
    _ip="$( awk '/^# ip4.addr/ {print $3}' ${POT_FS_ROOT}/jails/$_pname/conf/jail.conf )"
	#ifconfig ${_epairb} inet $_ip netmask $POT_NETMASK
	#ifconfig ${_epairb} vnet $_pname
	sed -i '.orig' "s/vnet;/vnet; vnet.interface=${_epairb};/" ${POT_FS_ROOT}/jails/$_pname/conf/jail.conf
	sed -i '' '/ifconfig_epair/d' ${POT_FS_ROOT}/jails/$_pname/custom/etc/rc.conf
	echo "ifconfig_${_epairb}=\"inet $_ip netmask $POT_NETMASK\"" >> ${POT_FS_ROOT}/jails/$_pname/custom/etc/rc.conf
	sysrc -f ${POT_FS_ROOT}/jails/$_pname/custom/etc/rc.conf defaultrouter="$POT_GATEWAY"
}

# $1 jail name
_js_start()
{
	local _pname _jdir _iface
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	if grep -q vnet $_jdir/conf/jail.conf ; then
		_js_vnet $_pname
		jail -c -f $_jdir/conf/jail.conf
	else
		jail -c -f $_jdir/conf/jail.conf
	fi
}

pot-start()
{
	local _pname _snap
	_snap=none
	args=$(getopt hvsS $*)
	if [ $? -ne 0 ]; then
		start-help
		exit 1
	fi

	set -- $args
	while true; do
		case "$1" in
		-h)
			start-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-s)
			_snap=normal
			shift
			;;
		-S)
			_snap=full
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
		_error "A jail name is mandatory"
		start-help
		exit 1
	fi
	if ! _is_pot $_pname ; then
		exit 1
	fi
	case $_snap in
		normal)
			_pot_zfs_snap $_pname
			;;
		full)
			_pot_zfs_snap_full $_pname
			;;
		none|*)
			;;
	esac
	if ! _js_mount $_pname ; then
		_error "Mount failed"
		exit 1
	fi
	_js_resolv $_pname
	if ! _js_start $_pname ; then
		_error "$_pname failed to start"
		exit 1
	else
		_info "Start the jail "${_pname}" "
	fi
}
