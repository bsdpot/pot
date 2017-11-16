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

_js_create_epair()
{
	local _epair
	_epair=$(ifconfig epair create)
	if [ -z "${_epair}" ]; then
		_error "ifconfig epair failed"
		exit 1 # false
	fi
	echo ${_epair%a}
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
	_epair=${2}a
	_epairb="${2}b"
	ifconfig ${_epair} up
	ifconfig $_bridge addm ${_epair}
	_ip=$( _get_conf_var $_pname ip4 )
	# set the network configuration in the pot's rc.conf
	sed -i '' '/ifconfig_epair/d' ${POT_FS_ROOT}/jails/$_pname/custom/etc/rc.conf
	echo "ifconfig_${_epairb}=\"inet $_ip netmask $POT_NETMASK\"" >> ${POT_FS_ROOT}/jails/$_pname/custom/etc/rc.conf
	sysrc -f ${POT_FS_ROOT}/jails/$_pname/custom/etc/rc.conf defaultrouter="$POT_GATEWAY"
}

# $1 jail name
_js_start()
{
	local _pname _jdir _iface _hostname _osrelease _param
	_param="allow.set_hostname allow.mount allow.mount.fdescfs allow.raw_sockets allow.socket_af allow.sysvipc"
	_param="$_param mount.devfs persist exec.stop=sh,/etc/rc.shutdown"
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	_hostname="$( _get_conf_var $_pname host.hostname )"
	_osrelease="$( _get_conf_var $_pname osrelease )"
	_param="$_param name=$_pname host.hostname=$_hostname osrelease=$_osrelease"
	_param="$_param path=${_jdir}/m"
	if _is_pot_vnet $_pname ; then
		_iface="$( _js_create_epair )"
		_js_vnet $_pname $_iface
		_param="$_param vnet vnet.interface=${_iface}b"
		jail -c -J /tmp/${_pname}.jail.conf $_param command=sh /etc/rc.conf
	else
		_param="$_param ip4=inherit"
		jail -c -J /tmp/${_pname}.jail.conf $_param command=sh /etc/rc.conf
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
