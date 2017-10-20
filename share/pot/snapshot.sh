#!/bin/sh

# supported releases
snapshot-help()
{
	echo "pot jstop [-h][-v][-f] [jailname]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f full'
	echo '  jailname : the jail that has to start'
}

pot-snapshot()
{
	local _pname _full
	args=$(getopt hvf $*)
	if [ $? -ne 0 ]; then
		snapshot-help
		exit 1
	fi
	_full="NO"
	set -- $args
	while true; do
		case "$1" in
		-h)
			snapshot-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-f)
			_full="YES"
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
		snapshot-help
		exit 1
	fi
	if [ "$_full" = "YES" ]; then
		_pot_zfs_snap_full $_pname
	else
		_pot_zfs_snap $_pname
	fi
}
