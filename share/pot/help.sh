#!/bin/sh

pot-help()
{
	local _cmd _func
	_cmd=$1
	shift
	case "${_cmd}" in
		ls)
			_cmd=list
			;;
		rollback)
			_cmd=revert
			;;
		snap)
			_cmd=snapshot
			;;
	esac
	if [ ! -r "${_POT_INCLUDE}/${_cmd}.sh" ]; then
		_error "Command ${_cmd} unkown"
		exit 1
	fi
	. ${_POT_INCLUDE}/${_cmd}.sh
	_func=${_cmd}-help
	$_func $@
}
