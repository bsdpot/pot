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
_js_is_running()
{
	local _pname _jlist
	_pname="$1"
	_jlist="$(jls -N | sed 1d | awk '{print $1}')"
	if _is_in_list $_pname $_jlist ; then
		return 0 # true
	fi
	return 1 # false
}

# $1 jail name
_js_stop()
{
	local _pname
	_pname="$1"
	if _js_is_running $_pname ; then
		jail -r $_pname
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
	args=$(getopt h $*)

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
		*)
			stop-help
			exit 1
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
