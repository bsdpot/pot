#!/bin/sh

if [ -z "$POT_MONITOR_TMP" ]; then
	local p
	if [ "$(uname)" = "Linux" ]; then
		p=/dev/shm
	else
		p="${TMPDIR:-/tmp}"
	fi
	POT_MONITOR_TMP=$(command mktemp \
	  "${p}/pot-monitor.XXXXXX") || exit 1
	export POT_MONITOR_TMP
fi

__mon_put()
{
	local k v
	k="$1"
	shift
	v="$*"
	echo "$k:$(echo "$v" | openssl base64 -A)" >>"$POT_MONITOR_TMP"
}

__mon_get()
{
	local k d r
	k="$1"
	d="$2"

	r="$(grep "^$k:" "$POT_MONITOR_TMP" | tail -n1 | \
		cut -d : -f 2 | openssl base64 -d)"

	if [ -n "$r" ]; then
		echo "$r"
	elif [ -n "$d" ]; then
		echo "$d"
	fi
}

__mon_export()
{
	local k v line

	while read -r line ; do
		k="$(echo "$line" | cut -d : -f 1)"
		v="$(echo "$line" | cut -d : -f 2)"
		if [ -n "$k" ]; then
			export "$k"="$(echo "$v" | openssl base64 -d)"
		fi
	done < "$POT_MONITOR_TMP"
}

__mon_init()
{
	: >"$POT_MONITOR_TMP" || exit 1
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
		command rm "$POT_MONITOR_TMP"
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
