#!/bin/sh

# supported releases
jstart-help()
{
	echo "pot jstart [-h] [jailname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -s take a snapshot before to start'
	echo '     snapshots are identified by the epoch'
	echo '     all zfs datasets under the jail dataset are considered'
	echo '  -S take a snapshot before to start'
	echo '     snapshots are identified by the epoch'
	echo '     all zfs datasets mounted in rw are considered (full)'
	echo '  jailname : the jail that has to start'
}

# $1 jail name
_js_is_jail()
{
	local _jname _jdir
	_jname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_jname"
	if [ ! -d $_jdir ]; then
		_error "Jail $_jname not found"
		return 1 # false
	fi
	if ! _zfs_is_dataset "${POT_ZFS_ROOT}/jails/$_jname" ]; then
		_error "Jail $_jname not found"
		return 1 # false
	fi

	if [ ! -d $_jdir/m -o \
		 ! -r $_jdir/conf/jail.conf -o \
		 ! -r $_jdir/conf/fs.conf ]; then
		_error "Some component of the jail $_jname is missing"
		return 1 # false
	fi
	return 0
}

# $1 jail name
_js_snap()
{
	local _jname _node _opt _snaptag _dset
	_jname=$1
	_snaptag="$(date +%s)"
	echo "Take snapshot of $_jname"
	zfs snapshot -r ${POT_ZFS_ROOT}/jails/${_jname}@${_snaptag}
}

# $1 jail name
_js_snap_full()
{
	local _jname _node _opt _snaptag _dset
	_jname=$1
	_snaptag="$(date +%s)"
	echo "Take snapshot of the full $_jname"
	while read -r line ; do
		_node=$( echo $line | awk '{print $1}' )
		_opt=$( echo $line | awk '{print $3}' )
		if [ "$_opt" = "ro" ]; then
			continue
		fi
		_dset=$( zfs list -H $_node | awk '{print $1}' )
		if [ -n "$_dset" ]; then
			echo "==> snapshot of $_dset"
			zfs snapshot ${_dset}@${_snaptag}
		fi
	done < ${POT_FS_ROOT}/jails/$_jname/conf/fs.conf
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
	local _jname _snap
	_snap=none
	args=$(getopt hsS $*)

	set -- $args
	while true; do
		case "$1" in
		-h)
			jstart-help
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
		*)
			jstart-help
			exit 1
		esac
	done
	_jname=$1
	if [ -z "$_jname" ]; then
		_error "A jail name is mandatory"
		jstart-help
		exit 1
	fi
	if ! _js_is_jail $_jname ; then
		exit 1
	fi
	case $_snap in
		normal)
			_js_snap $_jname
			;;
		full)
			_js_snap_full $_jname
			;;
		none|*)
			;;
	esac
	if ! _js_mount $_jname ; then
		_error "Mount failed"
		exit 1
	fi
	_js_resolv $_jname
	if ! _js_start $_jname ; then
		_error "$_jname failed to start"
		exit 1
	else
		_info "Start the jail "${_jname}" "
		exit 0
	fi
}
