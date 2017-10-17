#!/bin/sh

# supported releases
jstop-help()
{
	echo "pot jstop [-h] [jailname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  jailname : the jail that has to start'
}

# $1 jail name
_js_is_running()
{
	local _jname _jlist
	_jname="$1"
	_jlist="$(jls -N | sed 1d | awk '{print $1}')"
	if _is_in_list $_jname $_jlist ; then
		return 0 # true
	fi
	return 1 # false
}

# $1 jail name
_js_stop()
{
	local _jname
	_jname="$1"
	if _js_is_running $_jname ; then
		jail -r $_jname
		return $?
	fi
	return 0 # true
}

# $1 jail name
_js_umount()
{
	local _jname _tmpfile _jdir _mnt_p
	_jname=$1
	_tmpfile=$(mktemp -t ${_jname}.XXXXXX)
	if [ $? -ne 0 ]; then
		_error "not able to create temporary file - umount failed"
		return 1 # false
	fi
	_jdir="${POT_FS_ROOT}/jails/$_jname"
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
	local _jname _jdir
	_jname="$1"
	_jdir="${POT_FS_ROOT}/jails/$_jname"
	if [ -f $_jdir/m/etc/resolv.conf ]; then
		rm -f $_jdir/m/etc/resolv.conf
	fi
}

pot-jstop()
{
	local _jname
	args=$(getopt h $*)

	set -- $args
	while true; do
		case "$1" in
		-h)
			jstop-help
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
			jstop-help
			exit 1
		esac
	done
	_jname=$1
	if [ -z "$_jname" ]; then
		_error "A jail name is mandatory"
		jstop-help
		exit 1
	fi
	if ! _js_stop $_jname ; then
		_error "Stop the jail $_jname failed"
		exit 1
	fi
	_js_rm_resolv $_jname
	_js_umount $_jname

}
