#!/bin/sh
:

# shellcheck disable=SC2039
export-help() {
	echo "pot export [-hv] -p pot [-s snapshot]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -s snapshot : by default, the last snapshot is taken.'
	echo '                this option allows to use a different snapshot'
}

_export_pot()
{
	# shellcheck disable=SC2039
	local _pname _dset _snap
	_pname="$1"
	_snap="$2"
	_dset="${POT_ZFS_ROOT}/jails/$_pname"
	if [ -z "$_snap" ]; then
		_snap="$(_zfs_last_snap "$_dset" )"
	fi
	if ! zfs send -R "${_dset}"@"${_snap}" | xz > "${_pname}@${_snap}.xz" ; then
		rm -f "${_pname}@${_snap}.xz"
		return 1 # false
	else
		return 0 # true
	fi
}

# shellcheck disable=SC2039
pot-export()
{
	local _pname _snap
	_pname=
	_snap=
	OPTIND=1
	while getopts "hvp:s:" _o ; do
		case "$_o" in
		h)
			export-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		s)
			_snap="$OPTARG"
			;;
		*)
			export-help
			${EXIT} 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		export-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		export-help
		${EXIT} 1
	fi
	if  [ "$(_get_pot_type "$_pname")" != "single" ]; then
		_error "pot $_pname not supported - only single type pot can be exported"
		${EXIT} 1
	fi
	if [ -n "$_snap" ]; then
		if _is_zfs_pot_snap "$_pname" "$_snap" ; then
			_error "pot $_pname is not valid"
			export-help
			${EXIT} 1
		fi
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_export_pot "$_pname" "$_snap"
	return $?
}
