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
	sed -i \'\' -e "s%/jails/$_pname/%/jails/$_newname/%g" $_cdir/fs.conf
	sed -i '' -e "s%host.hostname=\"${_pname}%host.hostname=\"${_newname}%g" $_cdir/pot.conf
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
	if _zfs_is_dataset $_dset/usr.local ; then
		zfs umount -f $_dset/usr.local
		zfs set mountpoint=${POT_ZF_ROOT}/jails/$_newname/usr.local $_dset/usr.local
	fi
	if _zfs_is_dataset $_dset/custom ; then
		zfs umount -f $_dset/custom
		zfs set mountpoint=${POT_ZF_ROOT}/jails/$_newname/custom $_dset/custom
	fi
	if _zfs_is_dataset $_dset; then
		zfs umount -f $_dset
	fi
#sudo zfs rename zroot/pot/jails/dns1 zroot/pot/jails/dns2
	zfs rename $_dset $_nset

#sudo zfs mount zroot/pot/jails/dns2
	zfs mount $_nset
#sudo zfs mount zroot/pot/jails/dns2/custom
#sudo zfs mount zroot/pot/jails/dns2/usr.local
	zfs mount $_nset/custom
	zfs mount $_nset/usr.local
}

pot-rename()
{
	local _pname _newname
	_pname=
	_newname=
	args=$(getopt hvp:n: $*)
	if [ $? -ne 0 ]; then
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
	if ! _is_pot $_pname ; then
		_error "$_pname is not a valid pot"
		${EXIT} 1
	fi
	if _is_pot $_newname ; then
		_error "pot $_newname exists already"
		${EXIT} 1
	fi
	if _is_pot_running $_pname ; then
		_error "pot $_pname is still running"
		${EXIT} 1
	fi
	_rn_conf $_pname $_newname
	_rn_zfs $_pname $_newname
	# look for lvl 2 pot based on $_pname
	return 0
}
