#!/bin/sh

: ${EXIT:=exit}
: ${ECHO:=echo}

__POT_MSG_ERR=0
__POT_MSG_INFO=1
__POT_MSG_DBG=2
# $1 severity
_msg()
{
	local _sev
	_sev=$1
	shift
	if [ $_sev -gt $_POT_VERBOSITY ]; then
		return
	fi
	case $_sev in
		$__POT_MSG_ERR)
			echo "###> " $*
			;;
		$__POT_MSG_INFO)
			echo "===> " $*
			;;
		$__POT_MSG_DBG)
			echo "=====> " $*
			;;
		*)
			;;
	esac
}

_error()
{
	_msg $__POT_MSG_ERR $*
}

_info()
{
	_msg $__POT_MSG_INFO $*
}

_debug()
{
	_msg $__POT_MSG_DBG $*
}

# $1 quiet / no _error message is emitted
_qerror()
{
	if [ "$1" != "quiet" ]; then
		_error $*
	fi
}

# tested
_is_verbose()
{
	if [ $_POT_VERBOSITY -gt $__POT_MSG_INFO ]; then
		return 0 # true
	else
		return 1 # false
	fi
}

# $1 quiet / no _error messages are emitted (sometimes useful)
_is_uid0()
{
	if [ "$(id -u)" = "0" ]; then
		return 0 # true
	else
		_qerror $1"This operation needs 'root' privilegies"
		return 1 # false
	fi
}

# validate some values of the configuration files
# $1 quiet / no _error messages are emitted
_conf_check()
{
	if [ -z "${POT_ZFS_ROOT}" ]; then
		_qerror $1"POT_ZFS_ROOT is mandatory"
		return 1 # false
	fi
	if [ -z "${POT_FS_ROOT}" ]; then
		_qerror $1"POT_FS_ROOT is mandatory"
		return 1 # false
	fi
	return 0 # true
}

# it checkes that the pot environment is initialized
# $1 quiet / no _error messages are emitted
_is_init()
{
	if ! conf_check ; then
		_qerror $1"Configuration not valid, please verify it"
		return 1 # false
	fi
	if ! _zfs_exist "${POT_ZFS_ROOT}" "${POT_FS_ROOT}" ; then
		_qerror $1"Your system is not initialized, please run pot init"
		return 1 # false
	fi
	if ! _zfs_is_dataset "${POT_ZFS_ROOT}/bases" ||\
	   ! _zfs_is_dataset "${POT_ZFS_ROOT}/jails" ||\ 
	   ! _zfs_is_dataset "${POT_ZFS_ROOT}/fscomp" ; then
		_querror $1"Your system is not propery initialized, please run pot init to fix it"
	fi
}

# check if the dataset $1 exists
# $1 the dataset NAME
# tested
_zfs_is_dataset()
{
	[ -z "$1" ] && return 1 ## return false
	zfs list "$1" 2> /dev/null > /dev/null
	return $?
}

# check if the dataset $1 with the mountpoint $2 exists
# $1 the dataset NAME
# $2 the mountpoint
# tested
_zfs_exist()
{
	local _mnt_
	[ -z "$2" ] && return 1 # false
	zfs list "$1" 2> /dev/null > /dev/null
	[ $? -ne 0 ] && return 1 # false
	_mnt_=$(zfs list -H -o mountpoint $1 2> /dev/null)
	if [ "$_mnt_" != "$2" ]; then
		return 1 # false
	fi
	return 0 # true
}

_get_zfs_dataset()
{
	local _mnt_p _dset
	_mnt_p=$1
	_dset="$( zfs list -o name -H $_mnt_p )"
	echo $_dset
}

# take a zfs recursive snapshot of a pot
# $1 pot name
_pot_zfs_snap()
{
	local _pname _snaptag _dset
	_pname=$1
	_snaptag="$(date +%s)"
	_debug "Take snapshot of $_pname"
	zfs snapshot -r ${POT_ZFS_ROOT}/jails/${_pname}@${_snaptag}
}

# take a zfs snapshot of all rw dataset found in the fs.conf of a pot
# $1 pot name
_pot_zfs_snap_full()
{
	local _pname _node _opt _snaptag _dset
	_pname=$1
	_snaptag="$(date +%s)"
	_debug "Take snapshot of the full $_pname"
	while read -r line ; do
		_node=$( echo $line | awk '{print $1}' )
		_opt=$( echo $line | awk '{print $3}' )
		if [ "$_opt" = "ro" ]; then
			continue
		fi
		_dset=$( zfs list -H $_node | awk '{print $1}' )
		if [ -n "$_dset" ]; then
			_debug "snapshot of $_dset"
			zfs snapshot ${_dset}@${_snaptag}
		fi
	done < ${POT_FS_ROOT}/jails/$_pname/conf/fs.conf
}

# take a zfs snapshot of a fscomp
# $1 pot name
_fscomp_zfs_snap()
{
	local _fscomp _snaptag _dset
	_fscomp=$1
	_snaptag="$(date +%s)"
	_debug "Take snapshot of $_fscomp"
	zfs snapshot ${POT_ZFS_ROOT}/fscomp/${_pname}@${_snaptag}
}

# $1 the dataset name
_zfs_last_snap()
{
	local _dset _output
	_dset="$1"
	if [ -z "$_dset" ]; then
		return 1 # false
	fi
	_output="$(zfs list -d 1 -H -t snapshot $_dset | sort -r | cut -d'@' -f2 | cut -f1 | head -n1)"
	if [ -z "$_output" ]; then
		return 1 # false
	fi
	echo "${_output}"
	return 0 # true
}

# tested
_pot_bridge()
{
	local _bridges
	_bridges=$( ifconfig | grep ^bridge | cut -f1 -d':' )
	if [ -z "$_bridges" ]; then
		return
	fi
	for _b in $_bridges ; do
		_ip=$( ifconfig $_b inet | awk '/inet/ { print $2 }' )
		if [ "$_ip" = $POT_GATEWAY ]; then
			echo $_b
			return
		fi
	done
}

# $1 pot name
# $2 var name
_get_conf_var()
{
	local _pname _cdir _var _value
	_pname="$1"
	_cdir="${POT_FS_ROOT}/jails/$_pname/conf"
	_var="$2"
	_value="$( grep "$_var" $_cdir/pot.conf | tr -d ' \t"' | cut -f2 -d'=' )"
	echo $_value
}

# $1 pot name
_get_pot_base()
{
	local _pname
	_pname="$1"
	_get_conf_var $_pname pot.base
}

# $1 pot name
_is_ip_inherit()
{
	local _pname _val
	_pname="$1"
	_val="$( _get_conf_var $_pname ip4 )"
	if [ "$_val" = "inherit" ]; then
		return 0 # true
	else
		return 1 # false
	fi
}

# $1 pot name
_is_pot_vnet()
{
	local _pname _val
	_pname="$1"
	_val="$( _get_conf_var $_pname vnet )"
	if [ "$_val" = "true" ]; then
		return 0 # true
	else
		return 1 # false
	fi
}

_is_vnet_up()
{
	local _bridge
	_bridge=$(_pot_bridge)
	if [ -z "$_bridge" ]; then
		return 1 # false
	else
		return 0 # true
	fi
}

# $1 base name
# $2 quiet / no _error messages are emitted (sometimes usefult)
# tested
_is_base()
{
	local _base _bdir _bdset
	_base="$1"
	_bdir="${POT_FS_ROOT}/bases/$_base"
	_bdset="${POT_ZFS_ROOT}/bases/$_base"
	if [ ! -d "$_bdir" ]; then
		if [ "$2" != "quiet" ]; then
			_error "Base $_base not found"
		fi
		return 1 # false
	fi
	if ! _zfs_is_dataset $_bdset ; then
		if [ "$2" != "quiet" ]; then
			_error "zfs dataset $_bdset not found"
		fi
		return 2 #false
	fi
	return 0 # true
}

# $1 pot name
# $2 quiet / no _error messages are emitted (sometimes usefult)
# tested
_is_pot()
{
	local _pname _pdir
	_pname="$1"
	_pdir="${POT_FS_ROOT}/jails/$_pname"
	if [ ! -d $_pdir ]; then
		if [ "$2" != "quiet" ]; then
			_error "Pot $_pname not found"
		fi
		return 1 # false
	fi
	if ! _zfs_is_dataset "${POT_ZFS_ROOT}/jails/$_pname" ; then
		if [ "$2" != "quiet" ]; then
			_error "zfs dataset $_pname not found"
		fi
		return 2 # false
	fi

	if [ ! -d $_pdir/m -o \
		 ! -r $_pdir/conf/pot.conf -o \
		 ! -r $_pdir/conf/fs.conf ]; then
		if [ "$2" != "quiet" ]; then
			_error "Some component of the pot $_pname is missing"
		fi
		return 3 # false
	fi
	return 0
}

# $1 pot name
# tested
_is_pot_running()
{
	if [ -z "$1" ]; then
		return 1 ## false
	fi
	jls -j "$1" >/dev/null 2>/dev/null
	return $?
}

# $1 the element to search
# $2.. the list
# tested
_is_in_list()
{
	local _e
	if [ $# -lt 2 ]; then
		return 1 # false
	fi
	_e="$1"
	shift
	for e in $@ ; do
		if [ "$_e" = "$e" ]; then
			return 0 # true
		fi
	done
	return 1 # false
}

# $1 mountpoint
# tested
_is_mounted()
{
	local _mnt_p _mounted
	_mnt_p=$1
	if [ -z "$_mnt_p" ]; then
		return 1 # false
	fi
	_mounted=$( mount | grep -F $_mnt_p | awk '{print $3}')
	for m in $_mounted ; do
		if [ "$m" = "$_mnt_p" ]; then
			return 0 # true
		fi
	done
	return 1 # false
}

# $1 mountpoint
# tested
_umount()
{
	local _mnt_p
	_mnt_p=$1
	if _is_mounted "$_mnt_p" ; then
		_debug "unmount $_mnt_p"
		umount -f $_mnt_p
	else
		_debug "$_mnt_p is already unmounted"
	fi
}

# $1 the cmd
# all other parameter will be ignored
# tested
_is_cmd_flavorable()
{
	local _cmd
	_cmd=$1
	case $_cmd in
		add-dep|add-fscomp|\
		set-rss)
			return 0
			;;
	esac
	return 1 # false
}

# tested
_is_rctl_available()
{
	local _racct
	_racct="$(sysctl -qn kern.racct.enable)"
	if [ "$_racct" = "1" ]; then
		return 0 # true
	fi
	return 1 # false
}

_is_vnet_available()
{
	local _vimage
	_vimage="$(sysctl kern.conftxt | grep -c VIMAGE)"
	if [ $_vimage -eq 0 ]; then
		return 1 # false
	else
		return 0 # true
	fi
}

pot-cmd()
{
	local _cmd _func
	_cmd=$1
	shift
	if [ ! -r "${_POT_INCLUDE}/${_cmd}.sh" ]; then
		_error "Fatal error! $_cmd implementation not found!"
		exit 1
	fi
	. ${_POT_INCLUDE}/${_cmd}.sh
	_func=pot-${_cmd}
	$_func $@
}
