#!/bin/sh
:
# TODO
# Add a way to directly upload the compressed file
# Add a way to change compression utility

# shellcheck disable=SC3033
export-help() {
	echo "pot export [-hv] -p pot [-s snapshot] [-t tag] [-D directory] [-l level]"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -t tag : the tag to be used as suffix in the filename'
	echo '           if no tag is specified, tha snapshot will be used as suffix'
	echo '  -c : Treat tags as versions and check if they are decreasing'
	echo '  -D directory : where to store the compressed file with the pot'
	echo '  -l compression-level : from 0 (fast) to 9 (best). Defaul level 6. (man xz for more information)'
	echo '  -F : force exports of multiple snapshot (only 1 snapshot should be allowed)'
	echo '  -A : auto-fix snapshots number (exactly 1 snapshot is allowed)'
}

# $1 : pot name
# $2 : snapshot
# $3 : tag name
# $4 : target directory - where to write the file
# $5 : compression level
_export_pot()
{
	# shellcheck disable=SC3043
	local _pname _dset _snap _tag _check_tag _prev_tag _prev_snap
	# shellcheck disable=SC3043
	local  _dir _file _clvl _meta _origin _origin_pname_snapshot
	# shellcheck disable=SC3043
	local _origin_pname _origin_snapshot _origin_tag _highest_version
	_pname="$1"
	_snap="$2"
	_tag="$3"
	_check_tag="$4"
	_dir="$5"
	_clvl="$6"
	_file="${_dir}/${_pname}_${_tag}.xz"
	_dset="${POT_ZFS_ROOT}/jails/$_pname"
        _meta="-"

	_prev_tag=$(zfs get -H :pot.tag "${_dset}" | awk '{ print $3 }')
	_prev_snap=$(zfs get -H :pot.snap "${_dset}" | awk '{ print $3 }')
	if [ "$_check_tag" = "YES" ] && \
	   [ -n "$_prev_tag" ] && [ "$_prev_tag" != "-" ]; then
		if [ "$_prev_tag" = "$_tag" ] && [ "$_prev_snap" != "$_snap" ]; then
			_error "Already exported a different snapshot tagged as this version"
			exit 1
		fi
		_highest_version="$( \
		  (echo "$_tag"; echo "$_prev_tag") | sort -V | tail -n1)"
		if [ "$_tag" != "$_highest_version" ]; then
			_error "Tag version lower than the previously exported one"
			exit 1
		fi
	fi

	_origin=$(zfs get -H origin "${_dset}/m" | awk '{ print $3 }')
	if [ -n "$_origin" ] && [ "$_origin" != "-" ]; then
		#_origin_dset=$(echo ${_origin} | awk -F@ '{ print $1 }')
		_origin=$(echo "${_origin}" | sed 's|/m@|@|g')
		_origin_pname_snapshot=$(basename "${_origin}")
		_origin_pname=$(echo "${_origin_pname_snapshot}" | awk -F\@ '{ print $1 }')
		_origin_snapshot=$(echo "${_origin_pname_snapshot}" | awk -F@ '{ print $2 }')
		_origin_tag=$(zfs get -H :pot.tag "${_origin}" | awk '{ print $3 }')
		if [ -z "$_origin_tag" ] || [ "$_origin_tag" = "-" ]; then
			_error "Origin ${_origin_pname} has no :pot.tag, please export first"
			return 1 # false
		fi
		_meta="${_origin_pname}:${_origin_tag}@${_origin_snapshot}"
		#_origin=$(zfs get -H origin "${_origin_dset}" | awk '{ print $3 }')
	fi

	if ! zfs send -R "${_dset}"@"${_snap}" | xz -"${_clvl}" -T 0 > "${_file}" ; then
		rm -f "${_file}"
		return 1 # false
	elif [ ! -r "${_file}" ]; then
		return 1 # false
	else
		echo "$_meta" > "${_file}.meta"
		(cat "${_file}" "${_file}.meta") | skein1024 -q > "${_file}.skein"
		zfs set :pot.tag="${_tag}" "${_dset}"
		zfs set :pot.snap="${_snap}" "${_dset}"
		return 0 # true
	fi
}

# shellcheck disable=SC3033
pot-export()
{
	# shellcheck disable=SC3043
	local _pname _snap _tag _dir _auto_purge _force _check_tag
	_pname=
	_snap=
	_tag=
	_dir="."
	_clvl=6
	_auto_purge=
	_force=
	_check_tag=
	OPTIND=1
	while getopts "hvcp:t:D:l:FA" _o ; do
		case "$_o" in
		h)
			export-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		c)
			_check_tag="YES"
			;;
		p)
			_pname="$OPTARG"
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

	_snap="$(_zfs_last_snap "${POT_ZFS_ROOT}/jails/$_pname" )"
	if [ -z "$_snap" ]; then
		if [ "$_auto_purge" = "YES" ]; then
			_info "Taking a snapshot of $_pname"
			if ! pot-cmd snapshot -p "$_pname" ; then
				_error "Failed to take a snapshot of pot $_pname"
				${EXIT} 1
			else
				_snap="$(_zfs_last_snap "${POT_ZFS_ROOT}/jails/$_pname" )"
				_debug "A snapshot of $_pname has been automatically taken (@$_snap)"
			fi
		else
			_error "Pot $_pname has no snapshots - please use pot snapshot for that"
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
	_export_pot "$_pname" "$_snap" "$_tag" "$_check_tag" "${_dir}" "${_clvl}"
	return $?
}
