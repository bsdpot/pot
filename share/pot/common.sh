#!/bin/sh

pot-cmd()
{
	local _cmd _func
	_cmd=$1
	shift
	if [ ! -r "${_POT_INCLUDE}/${_cmd}.sh" ]; then
		echo "Fatal error! $_cmd implementation not found!"
		exit 1
	fi
	. ${_POT_INCLUDE}/${_cmd}.sh
	_func=pot-${_cmd}
	$_func $@
}
