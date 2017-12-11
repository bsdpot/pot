#!/bin/sh

clone-help()
{
	echo "pot clone [-hv] -p potname -P basepot [-i ipaddr]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -P potname : the pot to be cloned'
	echo '  -p potname : the pot name (mandatory)'
	echo '  -i ipaddr : an ip address'
}

# $1 pot name
# $2 pot-base name
_cj_zfs()
{
	local _pname _potbase _jdset _pdir _pbdir
	local _node _mnt_p _opt _new_mnt_p
	_pname=$1
	_potbase=$2
	_jdset=${POT_ZFS_ROOT}/jails/$_pname
	_pdir=${POT_FS_ROOT}/jails/$_pname
	_pbdir=${POT_FS_ROOT}/jails/$_potbase
	if [ "0" = "$( _get_conf_var $_potbase pot.level )" ]; then
		_error "Clone of a level 0 pot is not supported"
		return 1 ## false
	fi
	# Create the main jail zfs dataset
	if ! _zfs_is_dataset $_jdset ; then
		zfs create $_jdset
	else
		_info "$_jdset exists already"
	fi
	# Create the conf directory
	if [ ! -d $_pdir/conf ]; then
		mkdir -p $_pdir/conf
	fi
	if [ -e "$_pdir/conf/fs.conf" ]; then
		rm -f $_pdir/conf/fs.conf
	fi
	# Create the root mountpoint
	if [ ! -d "$_pdir/m" ]; then
		mkdir -p $_pdir/m
	fi
	while read -r line ; do
		_node=$( echo $line | awk '{print $1}' )
		_mnt_p=$( echo $line | awk '{print $2}' )
		_opt=$( echo $line | awk '{print $3}' )
		# ro components are replicated "as is"
		if [ "$_opt" = ro ] ; then
			_debug $_node ${_pdir}/${_mnt_p##${_pbdir}/} $_opt
			echo $_node ${_pdir}/${_mnt_p##${_pbdir}/} $_opt >> $_pdir/conf/fs.conf
		else
			# managing potbase datasets
			if [ "$_node" != "${_node##${_pbdir}}" ]; then
				_dname="${_node##${_pbdir}/}"
				_dset=$( _get_zfs_dataset $_node )
				_snap=$( _zfs_last_snap $_dset )
				if [ -z "$_snap" ]; then
					_error "$_dset has no snap - please take a snapshot of $_pbase"
					return 1
				else
					if _zfs_exist $_jdset/$_dname $_pdir/$_dname ; then
						_debug "$_dname dataset already cloned"
					else
						_debug "clone $_dset@$_snap into $_jdset/$_dname"
						zfs clone -o mountpoint=$_pdir/$_dname $_dset@$_snap $_jdset/$_dname
						_debug "$_pdir/$_dname $_pdir/${_mnt_p##${_pbdir}/}"
						echo "$_pdir/$_dname $_pdir/${_mnt_p##${_pbdir}/}" >> $_pdir/conf/fs.conf
					fi
				fi
			# managing fscomp datasets - the simple way - no clone support for fscomp
			elif [ "$_node" != "${_node##${POT_FS_ROOT}/fscomp}" ]; then
				_debug "$_node $_pdir/${_mnt_p##${_pbdir}/}"
				echo "$_node $_pdir/${_mnt_p##${_pbdir}/}" >> $_pdir/conf/fs.conf
			else
				_error "not able to manage $_node"
			fi
		fi
	done < ${POT_FS_ROOT}/jails/$_potbase/conf/fs.conf

	return 0 # true
}

# $1 pot name
# $2 pot-base name
# $3 ip
_cj_conf()
{
	local _pname _potbase _ip
	_pname=$1
	_potbase=$2
	_ip=$3
	_pdir=${POT_FS_ROOT}/jails/$_pname
	_pbdir=${POT_FS_ROOT}/jails/$_potbase
	if [ ! -d $_jdir/conf ]; then
		mkdir -p $_jdir/conf
	fi
	grep -v ^host.hostname $_pbdir/conf/pot.conf | grep -v ^ip4 > $_pdir/conf/pot.conf
	(
		echo "host.hostname=\"${_pname}.$( hostname )\""
		echo "ip4=$_ip"
	) >> $_pdir/conf/pot.conf
}

pot-clone()
{
	local _pname _ipaddr _potbase _pb_ipaddr
	_pname=
	_base=
	_ipaddr=inherit
	_potbase=
	_pb_ipaddr=
	args=$(getopt hvp:i:P: $*)
	if [ $? -ne 0 ]; then
		clone-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			clone-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-p)
			_pname=$2
			shift 2
			;;
		-i)
			_ipaddr=$2
			shift 2
			;;
		-P)
			_potbase=$2
			shift 2
			;;
		--)
			shift
			break
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "pot name is missing (option -p)"
		clone-help
		exit 1
	fi
	if [ -z "$_potbase" ]; then
		_error "reference pot name is missing (option -P)"
		clone-help
		exit 1
	fi
	if ! _is_pot $_potbase ; then
		_error "reference pot $_potbase not found"
		clone-help
		exit 1
	fi
	_pb_ipaddr="$( _get_conf_var $_potbase ip4 )"
	# check ip4 configuration compatibility
	if [ "$_ipaddr" = "inherit" -a "$_pb_ipaddr" != "inherit" ]; then
		_error "$_potbase has IP $_pb_ipaddr Provide a new IP for $_pname with the option -i"
		clone-help
		exit 1
	fi
	if [ "$_pb_ipaddr" = "inherit" -a "$_ipaddr" != "inherit" ]; then
		_info "$_potbase has not IP, so $_pname ; ignoring -i $_ipaddr"
		_ipaddr="inherit"
	fi
	if [ "$_pb_ipaddr" = "$_ipaddr" -a "$_ipaddr" != "inherit" ]; then
		_error "$_ipaddr is areadly used by $_potbase, please use a different IP"
		clone-help
		exit 1
	fi
	if ! _cj_zfs $_pname $_potbase ; then
		exit 1
	fi
	if ! _cj_conf $_pname $_potbase $_ipaddr ; then
		exit 1
	fi
}
