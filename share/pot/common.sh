#!/bin/sh

pot-cmd()
{
	local _cmd
	_cmd=$1

	if [ ! -r "${_POT_INCLUDE}/${_cmd}.sh" ]; then
		echo "Fatal error! $_cmd implementation not found!"
		exit 1
	fi
}
