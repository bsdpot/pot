#!/bin/sh

_set_pipefail()
{
	local _major _version
	if [ "$(uname)" = "Linux" ]; then
		set -o pipefail
		return
	fi
	_major="$(sysctl -n kern.osrelease | cut -f 1 -d '.')"
	_version="$(sysctl -n kern.osrelease | cut -f 1 -d '-')"
	if [ "$_major" -ge "13" ]; then
		set -o pipefail
		return
	fi
	case "$_version" in
		"12.1")
			set -o pipefail
			;;
	esac
}

