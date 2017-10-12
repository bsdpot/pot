#!/bin/sh

create-jail-help()
{
	echo "pot create-jail [-h] -j jailname [-i ipaddr] [-l lvl]"
	echo '  -h print this help'
	echo '  -j jailname : the jail name (mandatory)'
	echo '  -i ipaddr : an ip address'
	echo '  -l lvl : jail level'
}

# $1 jail name
# $2 base name
# $3 level
_cj_zfs()
{
	local _jname _base _jdset _snap
	_jname=$1
	_base=$2
	_lvl=$3
	_jdset=${POT_ZFS_ROOT}/jails/$_jname
	# Create the main jail zfs dataset
	if ! _zfs_is_dataset $_jdset ; then
		zfs create $_jdset
	else
		echo "$_jdset exists already"
	fi
	# Create the root mountpoint
	if [ ! -d "${POT_FS_ROOT}/jails/$_jname/m" ]; then
		mkdir -p ${POT_FS_ROOT}/jails/$_jname/m
	fi
	# lvl 0 images mount directly usr.local and custom
	if [ $_lvl -eq 0 ]; then
		return 0 # true
	fi
	# Clone the usr.local dataset
	if ! _zfs_is_dataset $_jdset/usr.local ; then
		_snap=$(_zfs_last_snap ${POT_ZFS_ROOT}/bases/$_base/usr.local)
		if [ -n "$_snap" ]; then
			echo "Clone zfs snapshot ${POT_ZFS_ROOT}/bases/$_base/usr.local@$_snap"
			zfs clone -o mountpoint=${POT_FS_ROOT}/jails/$_jname/usr.local ${POT_ZFS_ROOT}/bases/$_base/usr.local@$_snap $_jdset/usr.local
		else
			echo "no snapshot found for ${POT_ZFS_ROOT}/bases/$_base/usr.local"
			return 1 # false
		fi
	else
		echo "$_jdset/usr.local exists already"
	fi
	# Clone the custom dataset
	if ! _zfs_is_dataset $_jdset/custom ; then
		_snap=$(_zfs_last_snap ${POT_ZFS_ROOT}/bases/$_base/custom)
		if [ -n "$_snap" ]; then
			echo "Clone zfs snapshot ${POT_ZFS_ROOT}/bases/$_base/custom@$_snap"
			zfs clone -o mountpoint=${POT_FS_ROOT}/jails/$_jname/custom ${POT_ZFS_ROOT}/bases/$_base/custom@$_snap $_jdset/custom
		else
			echo "no snapshot found for ${POT_ZFS_ROOT}/bases/$_base/custom"
			return 1 # false
		fi
	else
		echo "$_jdset/custom exists already"
	fi
	return 0 # true
}

# $1 jail name
# $2 base name
# $3 ip
# $4 level
_cj_conf()
{
	local _jname _base _ip _lvl _jdir _bdir
	_jname=$1
	_base=$2
	_ip=$3
	_lvl=$4
	_jdir=${POT_FS_ROOT}/jails/$_jname
	_bdir=${POT_FS_ROOT}/bases/$_base
	if [ ! -d $_jdir/conf ]; then
		mkdir -p $_jdir/conf
	fi
	(
		if [ $lvl -eq 0 ]; then
			echo "$_bdir ${jdir}/m"
			echo "$_bdir/usr.local ${jdir}/m/usr/local"
			echo "$_bdir/custom ${jdir}/m/opt/custom"
		else
			echo "$_bdir ${jdir}/m ro"
			echo "$_jdir/usr.local ${jdir}/m/usr/local"
			echo "$_jdir/custom ${jdir}/m/opt/custom"
		fi
	) > $_jdir/conf/fs.conf
	(
		echo "${_jname} {"
		echo "  host.hostname = \"${_jname}.$( hostname )\";"
		echo "  path = ${_jdir}/m ;"
		echo "  osrelease = \"${_base}-RELEASE\";"
		echo "  mount.devfs;"
		echo "  allow.set_hostname;"
		echo "  allow.mount;"
		echo "  allow.mount.fdescfs;"
		echo "  allow.raw_sockets;"
		echo "  allow.socket_af;"
		echo "  allow.sysvipc;"
		echo "  exec.start = \"sh /etc/rc\";"
		echo "  exec.stop = \"sh /etc/rc.shutdown\";"
		echo "  persist;"
		if [ "$_ip" = "inherit" ]; then
			echo "  ip4 = inherit;"
		else
			echo "  interface = lo1;"
			echo "  ip4.addr = ${_ipaddr};"
		fi
		echo "}"
	) > $_jdir/conf/jail.conf
}

pot-create-jail()
{
	local _jname _ipaddr _lvl
	_jname=
	_ipaddr=inherit
	_lvl=1
	args=$(getopt hj:i:l: $*)
	set -- $args
	while true; do
		case "$1" in
		-h)
			create-jail-help
			exit 0
			;;
		-j)
			_jname=$2
			shift 2
			;;
		-i)
			_ipaddr=$2
			shift 2
			;;
		-l)
			_lvl=$2
			shift 2
			;;
		--)
			shift
			break
			;;
		*)
			create-jail-help
			exit 1
		esac
	done

	if [ -z "$_jname" ]; then
		echo "jail name is missing"
		create-jail-help
		exit 1
	fi
	if ! _cj_zfs $_jname 11.1 $_lvl ; then
		exit 1
	fi
}
