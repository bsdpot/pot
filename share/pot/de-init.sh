#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

de-init-help()
{
	cat <<-"EOH"
	pot de-init [-hvf]
	  -h print this help
	  -v verbose
	  -f force : stop all running pots
	EOH
}

pot-de-init()
{
	local _pots _p _force _zopt
	_force=
	_zopt=
	OPTIND=1
	while getopts "hvf" _o ; do
		case "$_o" in
		h)
			de-init-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			_zopt="-v"
			;;
		f)
			_force="force"
			;;
		?)
			de-init-help
			${EXIT} 1
			;;
		esac
	done
	_pots=_get_pot_list
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	for _p in $_pots ; do
		if _is_pot_running $_p ; then
			if [ -n "$_force" ]; then
				_debug "Stop the pot $_p"
				pot-cmd stop $_p
			else
				_error "At least on pot is still running. Use -f to force the stop of all pots"
				${EXIT} 1
			fi
		fi
	done
	# Remove pot dataset
	if ! _zfs_dataset_valid "${POT_ZFS_ROOT}" ; then
		_info "no root dataset found ($POT_ZFS_ROOT)"
	else
		_info "Deinstall pot ($POT_ZFS_ROOT)"
		zfs destroy -r $_zopt "${POT_ZFS_ROOT}"
	fi
	# Remove pf entries
	pf_file="$(sysrc -n pf_rules)"
	sed -i '' '/^nat-anchor pot-nat$/d' "$pf_file"
	sed -i '' '/^rdr-anchor "pot-rdr\/\*"$/d' "$pf_file"
	# Final message
	echo "zfs datasets have been removed"
	echo "pf configuration file should be clean (please check $pf_file)"
	echo "check your rc.conf for potential leftovers variable like:"
	echo '  syslogd_flags'
	echo '  pot_enable'
	echo "Please, consider to write a feedback email to pizzamig at FreeBSD dot org"
	echo "It gives us the opportunity to learn and improve"
}
