#!/bin/sh
:
# TODO
# Add a way to directly upload the compressed file
# Add a way to change compression utility

# shellcheck disable=SC2039
export-help() {
	echo "pot export [-hv] -p pot [-s snapshot] [-t tag] [-D directory] [-l level]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -t tag : the tag to be used as suffix in the filename'
	echo '           if no tag is specified, tha snapshot will be used as suffix'
	echo '  -s snapshot : by default, the last snapshot is taken. [ DEPRECATED ]'
	echo '                this option allows to use a different snapshot'
	echo '  -D directory : where to store the compressed file with the pot'
	echo '  -l compression-level : from 0 (fast) to 9 (best). Defaul level 6. (man xz for more information)'
	echo '  -F : force exports of multiple snapshot (only 1 snapshot should be allowed)'
	echo '  -A : auto-purge older snapshots (only 1 snapshot should be allowed)'
}

# $1 : pot name
# $2 : snapshot
# $3 : tag name
# $4 : target directory - where to write the file
# $5 : compression level
_export_pot()
{
	# shellcheck disable=SC2039
	local _pname _dset _snap _tag _dir _file _clvl
	_pname="$1"
	_snap="$2"
	_tag="$3"
	_dir="$4"
	_clvl="$5"
	_file="${_dir}/${_pname}_${_tag}.xz"
	_dset="${POT_ZFS_ROOT}/jails/$_pname"
	if ! zfs send -R "${_dset}"@"${_snap}" | xz -"${_clvl}" -T 0 > "${_file}" ; then
		rm -f "${_file}"
		return 1 # false
	elif [ ! -r "${_file}" ]; then
		return 1 # fasle
	else
		skein1024 -q "${_file}" > "${_file}.skein"
		return 0 # true
	fi
}

# shellcheck disable=SC2039
pot-export()
{
	local _pname _snap _tag _dir _auto_purge _force
	_pname=
	_snap=
	_tag=
	_dir="."
	_clvl=6
	_auto_purge=
	_force=
	OPTIND=1
	while getopts "hvp:s:t:D:l:FA" _o ; do
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
			echo '####################'
			echo '# -s is deprecated #'
			echo '####################'
			;;
		t)
			_tag="$OPTARG"
			;;
		D)
			_dir="$OPTARG"
			if [ ! -d "$_dir" ]; then
				_error "$_dir is not a directory"
				${EXIT} 1
			fi
			;;
		l)
			if echo "$OPTARG" | grep -q '^[0-9]$' ; then
				_clvl="$OPTARG"
			else
				_error "$OPTARG is an invalid compression level"
				export-help
				${EXIT} 1
			fi
			;;
		F)
			_force="YES"
			;;
		A)
			_auto_purge="YES"
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
			_error "no snap $_snap for pot $_pname found"
			export-help
			${EXIT} 1
		fi
	else
		_snap="$(_zfs_last_snap "${POT_ZFS_ROOT}/jails/$_pname" )"
		if [ -z "$_snap" ]; then
			_error "pot $_pname has no snapshots - please use pot snapshot for that"
			${EXIT} 1
		fi
	fi
	if [ "$( _zfs_count_snap "${POT_ZFS_ROOT}/jails/$_pname" )" -gt 1 ]; then
		if [ "$_force" = "YES" ]; then
			_info "Pot $_pname has multiple snapshots and they all will be exported"
		elif [ "$_auto_purge" = "YES" ]; then
			_info "Pot $_pname has more than 1 snapshot - auto-purge will delete older snapshots"
			if ! pot-cmd purge-snapshots -p "$_pname" ; then
				_error "purge-snapshots failed"
				${EXIT} 1
			fi
		else
			_error "Pot $_pname has more than 1 snapshot - use -A to auto-purge old snapshots or -F to force exporting"
			return 1 # false
		fi
	fi
	if [ -z "$_tag" ]; then
		_tag="$_snap"
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_info "exporting $_pname @ $_snap to ${_dir}/${_pname}_${_tag}.xz"
	_export_pot "$_pname" "$_snap" "$_tag" "${_dir}" "${_clvl}"
	return $?
}
