#!/bin/sh
:

# shellcheck disable=SC3033
version-help()
{
	echo 'pot version [-h][-v][-q]'
	echo '  -h -- print this help'
	echo '  -v verbose'
	echo '  -q quiet'
}


# shellcheck disable=SC3033
pot-version()
{
	# shellcheck disable=SC2039
	local _quiet
	_quiet="NO"
	OPTIND=1
	while getopts "hvq" _o ; do
		case "$_o" in
		h)
			version-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_quiet="YES"
			;;
		?)
			version-help
			${EXIT} 1
			;;
		*)
			;;
		esac
	done

	if [ "$_quiet" = "YES" ]; then
		${ECHO} "${_POT_VERSION}"
		${EXIT} 0
	fi
	echo "pot version: $_POT_VERSION"
}
