#!/bin/sh

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
