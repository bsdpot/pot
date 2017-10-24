#!/bin/sh

destroy-help()
{
	echo "pot destroy [-hv] -p potname"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p potname : the pot name (mandatory)'
}

# $1 pot name
_pot_zfs_destroy()
{
	local _pname _zopt _jdset
	_pname=$1
	_jdset=${POT_ZFS_ROOT}/jails/$_pname
	if ! _zfs_is_dataset $_jdset ; then
		_error "$_pname not found"
		return 1 # false
	fi
	if [ $_POT_VERBOSITY -ge $__POT_MSG_DEBUG ]; then
		_zopt="-v"
	else
		_zopt=""
	fi
	zfs destroy -r $_zopt ${POT_ZFS_ROOT}/jails/$_pname
}

pot-destroy()
{
	local _pname 
	_pname=
	args=$(getopt hvp: $*)
	if [ $? -ne 0 ]; then
		destroy-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			destroy-help
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
		--)
			shift
			break
			;;
		esac
	done

	if [ -z "$_pname" ]; then
		_error "pot name is missing"
		destroy-help
		exit 1
	fi
	if _is_pot_running $_pname ; then
		_error "pot $_pname is running"
		exit 1
		# TODO stop it or add a --force option and stop it
	fi
	_pot_zfs_destroy $_pname
}
