#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

# TODO
# Add a way to directly upload the compressed file
# Add a way to change compression utility

export-help() {
	cat <<-"EOH"
	pot export [-hv] -p pot [-S seckey] [-t tag] [-D dir] [-l level]
	  -h print this help
	  -v verbose
	  -p pot : the working pot
	  -t tag : the tag to be used as suffix in the filename
	           if not specified, the snapshot name will be used as suffix
	  -c : treat tags as versions and check if they are decreasing
	  -D dir : where to store the compressed file with the pot
	  -l level : compression level from 0 (fast) to 9 (best).
	             Default level 6. (see `man xz` for more information)
	  -F : force export of multiple snapshot
	       (by default, only one snapshot is allowed)
	  -A : auto-fix number of snapshots (only one snapshot is allowed)
	  -S : sign with secure key 'seckey' using signify(1)
	EOH
}

# $1 : pot name
# $2 : snapshot
# $3 : tag name
# $4 : check tag - if 'YES', make sure tags are not decreasing
# $5 : target directory - where to write the file
# $6 : compression level
# $7 : key to sign with signify
_export_pot()
{
	local _pname _dset _snap _tag _check_tag _prev_tag _prev_snap
	local _dir _file _clvl _sign_seckey _meta _origin _origin_pname_snapshot
	local _origin_pname _origin_snapshot _origin_tag _highest_version
	local _noerr
	_pname="$1"
	_snap="$2"
	_tag="$3"
	_check_tag="$4"
	_dir="$5"
	_clvl="$6"
	_sign_seckey="$7"
	_file="${_dir}/${_pname}_${_tag}.xz"
	_dset="${POT_ZFS_ROOT}/jails/$_pname"
	_meta="-"

	_prev_tag=$(zfs get -H -o value :pot.tag "${_dset}")
	_prev_snap=$(zfs get -H -o value :pot.snap "${_dset}")
	if [ "$_check_tag" = "YES" ] && \
	   [ -n "$_prev_tag" ] && [ "$_prev_tag" != "-" ]; then
		if [ "$_prev_tag" = "$_tag" ] && [ "$_prev_snap" != "$_snap" ]; then
			_error "Already exported a different snapshot tagged as this version"
			return 1 # false
		fi
		_highest_version="$( \
		  (echo "$_tag"; echo "$_prev_tag") | sort -V | tail -n1)"
		if [ "$_tag" != "$_highest_version" ]; then
			_error "Tag version lower than the previously exported one"
			return 1 # false
		fi
	fi

	_origin=$(zfs get -H -o value origin "${_dset}/m")
	if [ -n "$_origin" ] && [ "$_origin" != "-" ]; then
		_origin=$(echo "${_origin}" | sed 's|/m@|@|g')
		_origin_pname_snapshot=$(basename "${_origin}")
		_origin_pname=$(echo "${_origin_pname_snapshot}" | awk -F\@ '{ print $1 }')
		_origin_snapshot=$(echo "${_origin_pname_snapshot}" | awk -F@ '{ print $2 }')
		_origin_tag=$(zfs get -H -o value :pot.tag "${_origin}")
		if [ -z "$_origin_tag" ] || [ "$_origin_tag" = "-" ]; then
			_error "Origin ${_origin_pname} has no :pot.tag, please export first"
			return 1 # false
		fi
		_meta="${_origin_pname}:${_origin_tag}@${_origin_snapshot}"
	fi

	if ! zfs send -R "${_dset}"@"${_snap}" | xz -"${_clvl}" -T 0 > "${_file}" ; then
		rm -f "${_file}"
		return 1 # false
	elif [ ! -r "${_file}" ]; then
		return 1 # false
	else
		_noerr=0
		echo "$_meta" > "${_file}.meta"
		# shellcheck disable=SC2320
		_noerr=$((_noerr+$?))
		(cat "${_file}" "${_file}.meta") | skein1024 -q > "${_file}.skein"
		_noerr=$((_noerr+$?))
		if [ -n "$_sign_seckey" ]; then
			signify -S -s "$_sign_seckey" -m "${_file}.skein"
			_noerr=$((_noerr+$?))
		fi
		if [ "$_noerr" != 0 ]; then
			_error "Export failed"
			rm -f "${_file}" "${_file}.meta" "${_file}.skein" "${_file}.skein.sig"
		fi
		zfs set :pot.tag="${_tag}" "${_dset}"
		zfs set :pot.snap="${_snap}" "${_dset}"
		return 0 # true
	fi
}

pot-export()
{
	local _pname _snap _tag _dir _auto_purge _force _check_tag _sign_seckey
	_pname=
	_snap=
	_tag=
	_dir="."
	_clvl=6
	_auto_purge=
	_force=
	_check_tag=
	_sign_seckey=
	OPTIND=1
	while getopts "hvcp:t:D:l:FAS:" _o ; do
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
		S)
			_sign_seckey="$OPTARG"
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

	if [ -n "$_sign_seckey" ]; then
		if [ ! -r "$_sign_seckey" ]; then
			_error "Signature key $_sign_seckey not found"
			${EXIT} 1
		fi
		if ! type "signify" >/dev/null 2>&1; then
			_error "Could not find 'signify',"\
			       "try 'pkg install signify'"
			${EXIT} 1
		fi
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
	_export_pot "$_pname" "$_snap" "$_tag" "$_check_tag" "${_dir}" "${_clvl}" "$_sign_seckey"
	return $?
}
