#!/bin/sh

de-init-help()
{
	echo 'pot de-init [-h][-v][-f]'
	echo '  -h -- print this help'
	echo '  -v verbose'
	echo '  -f force - stop all running pots'
}

pot-de-init()
{
	local _pots _p _force _zopt
	_force=
	_zopt=
	args=$(getopt hvf $*)
	if [ $? -ne 0 ]; then
		init-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			init-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-f)
			_force="force"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done

	if ! _is_uid0 ; then
		${EXIT} 1
	fi

	_pots=$( ls -d ${POT_FS_ROOT}/jails/*/ 2> /dev/null | xargs -I {} basename {} | tr '\n' ' ' )
	for _p in $_pots ; do
		if _is_pot_running $_p ; then
			if [ "$_force" = "force" ]; then
				_debug "Stop the pot $_p"
				pot-cmd stop $_p
			else
				_error "At least on pot is still running. Use -f to force the stop of all pots"
				${EXIT} 1
			fi
		fi
	done
	if _is_verbose ; then
		_zopt="-v"
	fi
	if ! _zfs_is_dataset ${POT_ZFS_ROOT} ; then
		_info "no root dataset found ($POT_ZFS_ROOT)"
	else
		_info "Deinstall pot ($POT_ZFS_ROOT)"
		zfs destroy -r $_zopt ${POT_ZFS_ROOT}
	fi
}
