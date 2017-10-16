#!/bin/sh

pot-help()
{
	local _cmd _func
	_cmd=$1
	shift
	if [ ! -r "${_POT_INCLUDE}/${_cmd}.sh" ]; then
		echo "Command ${_cmd} unkown"
		exit 1
	fi
	. ${_POT_INCLUDE}/${_cmd}.sh
	_func=${_cmd}-help
	$_func $@
}
