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
	local _pname _jdir _epair _ip
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	_epair=
	_ip=$( _get_conf_var $_pname ip4 )
	if _is_pot_running $_pname ; then
		if _is_pot_vnet $_pname ; then
			_epair=$(jexec $_pname ifconfig | grep ^epair | cut -d':' -f1)
		fi
		jail -r $_pname
		if [ -n "$_epair" ]; then
			ifconfig ${_epair%b}a destroy
		else
			if [ "$_ip" != inherit ]; then
				ifconfig ${POT_EXTIF} $_ip -alias
			fi
		fi
		return $?
	fi
	return 0 # true
}

# $1 pot name
_js_umount()
{
	local _pname _tmpfile _jdir _node _mnt_p _opt _dset
	_pname=$1
	_tmpfile=$(mktemp -t ${_pname}.XXXXXX)
	if [ $? -ne 0 ]; then
		_error "not able to create temporary file - umount failed"
		return 1 # false
	fi
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	tail -r $_jdir/conf/fs.conf > $_tmpfile

	_umount $_jdir/m/tmp
	_umount $_jdir/m/dev
	while read -r line ; do
		_node=$( echo $line | awk '{print $1}' )
		_mnt_p=$( echo $line | awk '{print $2}' )
		_opt=$( echo $line | awk '{print $3}' )
		if [ "$_opt" = "zfs-remount" ]; then
			_dset="$( _get_zfs_dataset $_mnt_p )"
			if [ -n "$_dset" ]; then
				zfs set mountpoint=$_node $_dset
				# TODO - check the return value
			fi
		else
			_umount $_mnt_p
			# TODO - check the return value
		fi
	done < $_tmpfile
	rm $_tmpfile
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
	_js_umount $_pname
}
