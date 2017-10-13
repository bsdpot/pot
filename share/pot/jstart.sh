#!/bin/sh

# supported releases
jstart-help()
{
	echo "pot jstart [-h] [jailname]"
	echo '  -h print this help'
	echo '  jailname : the jail that has to start'
}

# $1 jail name
_js_is_jail()
{
	local _jname _jdir
	_jname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_jname"
	if [ ! -d $_jdir ]; then
		echo "Jail $_jname not found"
		return 1 # false
	fi
	if ! _zfs_is_dataset "${POT_ZFS_ROOT}/jails/$_jname" ]; then
		echo "Jail $_jname not found"
		return 1 # false
	fi

	if [ ! -d $_jdir/m -o \
		 ! -r $_jdir/conf/jail.conf -o \
		 ! -r $_jdir/conf/fs.conf ]; then
		echo "Some component of the jail $_jname is missing"
		return 1 # false
	fi
	return 0
}

# $1 jail name
_js_mount()
{
	local _jname _node _mnt_p _opt
	_jname=$1
	while read -r line ; do
		_node=$( echo $line | awk '{print $1}' )
		_mnt_p=$( echo $line | awk '{print $2}' )
		_opt=$( echo $line | awk '{print $3}' )
		mount_nullfs -o {_opt:-rw} $_node $_mnt_p
		# TODO - check the return value
	done < ${POT_FS_ROOT}/jails/$_jname/conf/fs.conf

	mount -t tmpfs tmpfs ${POT_FS_ROOT}/jails/$_jname/m/tmp
}

# $1 jail name
_js_resolv()
{
	local _jname _jdir
	_jname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_jname"
	if [ ! -r /etc/resolv.conf ]; then
		echo "No resolv.conf found in /etc"
		return
	fi
	if [ -d $_jdir/custom/etc ]; then
		cp /etc/resolv.conf $_jdir/custom/etc
	else
		if [ -d $_jdir/m/etc ]; then
			cp /etc/resolv.conf $_jdir/m/etc
		else
			echo "No custom etc directory found, resolv.conf not loaded"
		fi
	fi
}

# $1 jail name
_js_start()
{
	local _jname _jdir
	_jname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_jname"
	jail -c -f $_jdir/conf/jail.conf
}

pot-jstart()
{
	local _jname
	args=$(getopt h $*)

	set -- $args
	while true; do
		case "$1" in
		-h)
			jstart-help
			exit 0
			;;
		--)
			shift
			break
			;;
		*)
			jstart-help
			exit 1
		esac
	done
	_jname=$1
	if [ -z "$_jname" ]; then
		echo "A jail name is mandatory"
		jstart-help
		exit 1
	fi
	if ! _js_is_jail $_jname ; then
		exit 1
	fi
	_js_mount $_jname
	_js_resolv $_jname
	_js_start $_jname
	echo "Start the jail "${_jname}" "
}
