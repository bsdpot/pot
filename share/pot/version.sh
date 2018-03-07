#!/bin/sh

version-help()
{
	echo 'pot version [-h][-v][-q]'
	echo '  -h -- print this help'
	echo '  -v verbose'
	echo '  -q quiet'
}


pot-version()
{
	local _quiet
	_quiet="NO"
	args=$(getopt hvq $*)
	if [ $? -ne 0 ]; then
		version-help
		exit 1
	fi
	set -- $args
	while true; do
		case "$1" in
		-h)
			version-help
			exit 0
			;;
		-v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			shift
			;;
		-q)
			_quiet="YES"
			shift
			;;
		--)
			shift
			break
			;;
		esac
	done

	if [ "$_quiet" = "YES" ]; then
		${ECHO} "${_POT_VERSION}"
		return 0
	fi
	_info "pot version: $_POT_VERSION"
}

