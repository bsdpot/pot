#!/bin/sh
# shellcheck disable=SC3043

if [ -z "$POT_MONITOR_TMP" ]; then
	if [ "$(command uname)" = "Linux" ]; then
		POT_MONITOR_TMP=/dev/shm
	else
		POT_MONITOR_TMP="${TMPDIR:-/tmp}"
	fi
	POT_MONITOR_TMP=$(command mktemp -d \
	  "${POT_MONITOR_TMP}/pot-monitor.XXXXXX") || exit 1
	export POT_MONITOR_TMP
fi

__mon_put()
{
	local k v
	k="$1"
	shift
	v="$*"
	printf %s "$v" >"$POT_MONITOR_TMP/$k"
}

__mon_get()
{
	local k d r
	k="$1"
	d="$2"

	if [ -e "$POT_MONITOR_TMP/$k" ]; then
		r=$(command cat "$POT_MONITOR_TMP/$k")
	fi

	if [ -n "$r" ]; then
		echo "$r"
	elif [ -n "$d" ]; then
		echo "$d"
	fi
}

__mon_export()
{
	local k v

	for k in "$POT_MONITOR_TMP"/*; do
		v=$(command cat "$k")
		export "$k"="$v"
	done
}

__mon_init()
{
	command mkdir -p "$POT_MONITOR_TMP" || exit 1
	command rm -f "$POT_MONITOR_TMP"/* || exit 1
}

__monitor_int()
{
	local M i C
	i=0
	M=$1
	shift
	C="$(__mon_get "${M}_CALLS" 0)"
	C=$(( C + 1 ))
	__mon_put "${M}_CALLS" "$C"
	while [ -n "$1" ] || [ -n "$2" ] || [ -n "$3" ]; do
		i=$(( i + 1 ))
		__mon_put "${M}_CALL${C}_ARG${i}" "$1"
		shift
	done
}

__monitor()
{
	# requires "pkg install flock" on FreebSD
	(
		command flock -x -w 10 9
		__monitor_int "$@"
	) 9>"$POT_MONITOR_TMP.lock"
}

__mon_tearDown()
{
	if [ -e "$POT_MONITOR_TMP" ]; then
		command rm -rf "$POT_MONITOR_TMP"
	fi
	if [ -e "$POT_MONITOR_TMP.lock" ]; then
		command rm "$POT_MONITOR_TMP.lock"
	fi
}

# $1 name
# $2 left hand
# $3 key of right hand mon var
# $4 default value to compare to
#    "" defaults to 0 in case key ends on "_CALLS"
assertEqualsMon()
{
	local n l k d
	n="$1"
	l="$2"
	k="$3"
	d="$4"
	if [ -z "$d" ] && [ "$k" != "${k%%_CALLS}" ]; then
		d="0"
	fi
	assertEquals "$n" "$l" "$(__mon_get "$k" "$d")"
}

# $1 name
# $2 left hand
# $3 key of right hand mon var
# $4 default value to compare to
#    "" defaults to 0 in case key ends on "_CALLS"
assertNotEqualsMon()
{
	local n l k d
	n="$1"
	l="$2"
	k="$3"
	d="$4"
	if [ -z "$d" ] && [ "$k" != "${k%%_CALLS}" ]; then
		d="0"
	fi
	assertNotEquals "$n" "$l" "$(__mon_get "$k" "$d")"
}
