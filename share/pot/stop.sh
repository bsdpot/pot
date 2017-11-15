#!/bin/sh

# supported releases
stop-help()
{
	echo "pot stop [-h] [potname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  potname : the jail that has to start'
}

# $1 jail name
_js_stop()
{
	local _pname _jdir _epair
	_pname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_pname"
	_epair=
	if _is_pot_running $_pname ; then
		if grep -q vnet $_jdir/conf/jail.conf ; then
			_epair=$(jexec $_pname ifconfig | grep ^epair | cut -d':' -f1)
			cp -v $_jdir/conf/jail.conf.orig $_jdir/conf/jail.conf
		fi
		jail -r $_pname
		if [ -n "$_epair" ]; then
			ifconfig ${_epair%b}a destroy
		fi
		return $?
	fi
	return 0 # true
}

# $1 jail name
_js_umount()
{
	local _pname _tmpfile _jdir _mnt_p
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
		_mnt_p=$( echo $line | awk '{print $2}' )
		_umount $_mnt_p
		# TODO - check the return value
	done < $_tmpfile
	rm $_tmpfile
}

# $1 jail name
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
		_error "A jail name is mandatory"
		stop-help
		exit 1
	fi
	if ! _js_stop $_pname ; then
		_error "Stop the jail $_pname failed"
		exit 1
	fi
	_js_rm_resolv $_pname
	_js_umount $_pname
}
