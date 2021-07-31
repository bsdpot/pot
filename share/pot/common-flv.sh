#!/bin/sh

# $1 flavour name
_is_flavour()
{
    # shellcheck disable=SC3043
    local _flv_name
	_flv_name="$1"
	if [ -n "$( _get_flavour_script "$_flv_name" )" ] ||
		[ -n "$( _get_flavour_cmd_file "$_flv_name" )" ]; then
		return 0 # true
	fi
	return 1 # false
}

_get_flavour_script()
{
    # shellcheck disable=SC3043
    local _flv_name
	_flv_name="$1"
	if [ -f "$_flv_name" ] && [ -x "$_flv_name" ] && [ "$_flv_name" != "${_flv_name%%.sh}" ]; then ## it's a script path name
		echo "$_flv_name"
	elif [ -f "$_flv_name.sh" ] && [ -x "$_flv_name.sh" ];  then ## it's a path name
		echo "$_flv_name.sh"
	elif [ -f "./$_flv_name.sh" ] && [ -x "./$_flv_name.sh" ]; then
		echo "./$_flv_name.sh"
	elif [ -f "${_POT_FLAVOUR_DIR}/$_flv_name.sh" ] || [ -x "${_POT_FLAVOUR_DIR}/$_flv_name.sh" ]; then
		echo "${_POT_FLAVOUR_DIR}/$_flv_name.sh"
	fi
}

_get_flavour_cmd_file()
{
    # shellcheck disable=SC3043
    local _flv_name
	_flv_name="$1"
	if [ -f "$_flv_name" ] && [ -r "$_flv_name" ] && [ "$_flv_name" = "${_flv_name%%.sh}" ]; then ## it's a cmd file path name
		echo "$_flv_name"
	elif [ -f "./$_flv_name" ] && [ -r "./$_flv_name" ]; then
		echo "./$_flv_name"
	elif [ -f "${_POT_FLAVOUR_DIR}/$_flv_name" ] || [ -r "${_POT_FLAVOUR_DIR}/$_flv_name" ]; then
		echo "${_POT_FLAVOUR_DIR}/$_flv_name"
	fi
}

# $1 the cmd
# all other parameter will be ignored
# tested
_is_cmd_flavorable()
{
    # shellcheck disable=SC3043
    local _cmd
    _cmd=$1
    case $_cmd in
        add-dep|set-attribute|\
        copy-in|mount-in|\
        set-rss|export-ports|\
        set-cmd|set-env)
            return 0
            ;;
    esac
    return 1 # false
}

# Special version of set-cmd usable only for flavours
# $1 : pot name
# $2 : the set-cmd line in the file
_flv_set_cmd()
{
	# shellcheck disable=SC3043
	local _pname _line _cmd
	_pname="$1"
	_line="$2"
	_cmd="${_line#set-cmd -c }"
	if [ "$_line" = "$_cmd" ]; then
		_error "In flavour only 'set-cmd -c ' is supported"
		return 1
	fi
	_set_command "$_pname" "$_cmd"
}

_exec_flv()
{
	# shellcheck disable=SC3043
	local _pname _flv _pdir
	_pname=$1
	_flv=$2
	_pdir=${POT_FS_ROOT}/jails/$_pname
	_debug "Flavour: $_flv"
	if [ -r "${_POT_FLAVOUR_DIR}/${_flv}" ]; then
		_debug "Executing $_flv pot commands on $_pname"
		while read -r line ; do
			# shellcheck disable=SC2086
			if _is_cmd_flavorable $line ; then
				if [ "$line" != "${line#set-cmd}" ]; then
					# workaround for set-cmd / damn quoting and shell scripts
					if ! _flv_set_cmd "$_pname" "$line" ; then
						return 1
					fi
				else
					# shellcheck disable=SC2086
					pot-cmd $line -p "$_pname"
				fi
			else
				_error "Flavor $_flv: line $line not valid - ignoring"
			fi
		done < "${_POT_FLAVOUR_DIR}/${_flv}"
	fi
	if [ -x "${_POT_FLAVOUR_DIR}/${_flv}.sh" ]; then
		_debug "Starting $_pname pot for the initial bootstrap"
		pot-cmd start "$_pname"
		cp -v "${_POT_FLAVOUR_DIR}/${_flv}.sh" "$_pdir/m/tmp"
		_debug "Executing $_flv script on $_pname"
		if ! jexec "$_pname" "/tmp/${_flv}.sh" "$_pname" ; then
			_error "create: flavour $_flv failed (script)"
			return 1
		fi
		pot-cmd stop "$_pname"
	else
		_debug "No shell script available for the flavour $_flv"
	fi

}
