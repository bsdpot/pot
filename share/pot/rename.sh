#!/bin/sh

# supported releases
rename-help()
{
	echo "pot rename [-h][-v][-a] [-p potname|-f fscomp]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p oldname : the previous pot name'
	echo '  -n newname : the new pot name'
}

_rn_conf()
{
	local _pname _newname _cdir
	_pname=$1
	_newname=$2
	_cdir=${POT_FS_ROOT}/jails/$_pname/conf
	sed -i '' -e "s%/jails/$_pname/%/jails/$_newname/%g" "$_cdir/fscomp.conf"
	sed -i '' -e "s%host.hostname=\"${_pname}%host.hostname=\"${_newname}%g" "$_cdir/pot.conf"
	if [ -w /usr/local/etc/syslog.d/"${_pname}".conf ]; then
		mv /usr/local/etc/syslog.d/"${_pname}".conf /usr/local/etc/syslog.d/"${_newname}".conf
		sed -i '' "s/$_pname.log/$_newname.log/" /usr/local/etc/syslog.d/"${_newname}".conf
		touch /var/log/pot/$_newname.log
		service syslogd reload
	fi
	if [ -w /usr/local/etc/newsyslog.conf.d/"${_pname}".conf ]; then
		mv /usr/local/etc/newsyslog.conf.d/"${_pname}".conf /usr/local/etc/newsyslog.conf.d/"${_newname}".conf
		sed -i '' "s%pot/$_pname.log%pot/$_newname.log%" /usr/local/etc/newsyslog.conf.d/"${_newname}".conf
	fi
}

_rn_zfs()
{
	local _pname _newname _cdir
	_pname=$1
	_newname=$2
	_dset=${POT_ZFS_ROOT}/jails/$_pname
	_nset=${POT_ZFS_ROOT}/jails/$_newname
#sudo zfs umount zroot/pot/jails/dns1/usr.local 
#sudo zfs set mountpoint=/opt/pot/jails/dns2/usr.local zroot/pot/jails/dns2/usr.local
#sudo zfs umount zroot/pot/jails/dns1/custom   
#sudo zfs set mountpoint=/opt/pot/jails/dns2/custom zroot/pot/jails/dns2/custom
#sudo zfs umount zroot/pot/jails/dns1       
	if _zfs_dataset_valid "$_dset/usr.local" ; then
		_debug "Preparing $_dset/usr.local"
		zfs umount -f "$_dset/usr.local"
		zfs set mountpoint="${POT_FS_ROOT}/jails/$_newname/usr.local" "$_dset/usr.local"
	fi
	if _zfs_dataset_valid "$_dset/custom" ; then
		_debug "Preparing $_dset/custom"
		zfs umount -f "$_dset/custom"
		zfs set mountpoint="${POT_FS_ROOT}/jails/$_newname/custom" "$_dset/custom"
	fi
	if _zfs_dataset_valid "$_dset" ; then
		_debug "Preparing $_dset"
		zfs umount -f "$_dset"
	fi
#sudo zfs rename zroot/pot/jails/dns1 zroot/pot/jails/dns2
	_debug "Renaming $_dset in $_nset"
	zfs rename "$_dset" "$_nset"

#sudo zfs mount zroot/pot/jails/dns2
	_debug "Mount $_nset"
	zfs mount "$_nset"
#sudo zfs mount zroot/pot/jails/dns2/custom
#sudo zfs mount zroot/pot/jails/dns2/usr.local
	zfs mount "$_nset/custom"
	if _zfs_dataset_valid "$_nset/usr.local" ; then
		zfs mount "$_nset/usr.local"
	fi
}

# rename also on all lvl2 and dependencies
_rn_recursive()
{
	local _pname _newname _pots _cdir
	_pname=$1
	_newname=$2
	_pots=$( ls -d "${POT_FS_ROOT}"/jails/*/ 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	for _p in $_pots ; do
		_cdir=${POT_FS_ROOT}/jails/$_p/conf
		sed -i '' -e "s%/jails/$_pname/%/jails/$_newname/%g" "$_cdir/fscomp.conf"
		sed -i '' -e "s/^pot.potbase=$_pname$/pot.potbase=$_newname/" "$_cdir/pot.conf"
		sed -i '' -e "s/^pot.depend=$_pname$/pot.depend=$_newname/" "$_cdir/pot.conf"
	done
}

pot-rename()
{
	local _pname _newname
	_pname=
	_newname=
	if ! args=$(getopt hvp:n: "$@") ; then
		rename-help
		${EXIT} 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			rename-help
			${EXIT} 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-p)
			_pname="$2"
			shift 2
			;;
		-n)
			_newname="$2"
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done
	if [ -z "$_pname" ]; then
		_error "pot name is missing (-p)"
		rename-help
		$EXIT 1
	fi
	if [ -z "$_newname" ]; then
		_error "new name is missing (-n)"
		rename-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pname is not a valid pot"
		${EXIT} 1
	fi
	if _is_pot "$_newname" quiet ; then
		_error "pot $_newname exists already"
		${EXIT} 1
	fi
	if _is_pot_running "$_pname" ; then
		_error "pot $_pname is still running"
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_rn_conf "$_pname" "$_newname"
	_rn_zfs "$_pname" "$_newname"
	_rn_recursive "$_pname" "$_newname"
	return 0
}
