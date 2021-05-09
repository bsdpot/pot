#!/bin/sh

# system utilities stubs

if [ "$(uname)" = "Linux" ]; then
	TEST=/usr/bin/[
else
	TEST=/bin/[
fi

[()
{
	#echo test: "$@" >&2

	if ${TEST} "$1" = "!" ]; then
		if ${TEST} "$__didfetch" != "1" ]; then
			# pretend these files don't exist yet
			return 0 # false
		fi

		if ${TEST} "$2" = "-r" ]; then
			if ${TEST} "$3" = "/tmp/11.1-RELEASE_base.txz" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/tmp/12.0-RC3_base.txz" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/tmp/12.0-RELEASE_base.txz" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/tmp/8.1-RELEASE_base.txz" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/tmp/2.1-RELEASE_base.txz" ]; then
				return 0 # true
			fi
		fi
	elif ${TEST} "$1" = "-r" ]; then
		if ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-11.1-RELEASE" ]; then
			return 0 # true
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-12.0-RELEASE" ]; then
			return 0 # true
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-12.0-RC3" ]; then
			return 0 # true
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-8.1-RELEASE" ]; then
			return 1 # false
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/arm64-aarch64-11.1-RELEASE" ]; then
			return 0 # true
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/arm64-aarch64-12.0-RELEASE" ]; then
			return 0 # true
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/arm64-aarch64-12.0-RC3" ]; then
			return 0 # true
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/arm64-aarch64-8.1-RELEASE" ]; then
			return 1 # false
		fi
	fi
	${TEST} "$@"
	return $?
}

fetch()
{
	__didfetch="1"
	#echo fetch: "$@" >&2

	__monitor FETCH "$@"
}

sha256()
{
	if [ "$__arch" = "amd64" ]; then
		if [ "$2" = /tmp/11.1-RELEASE_base.txz ]; then
			echo "0123456789abcdef"
		elif [ "$2" = /tmp/12.0-RELEASE_base.txz ]; then
			echo "fedcba9876543210"
		elif [ "$2" = /tmp/12.0-RC3_base.txz ]; then
			echo "aaaaaaaaaaaaaaaa"
		else
			echo ""
		fi
	else
		if [ "$2" = /tmp/11.1-RELEASE_base.txz ]; then
			echo "other0123456789abcdef"
		elif [ "$2" = /tmp/12.0-RELEASE_base.txz ]; then
			echo "otherfedcba9876543210"
		elif [ "$2" = /tmp/12.0-RC3_base.txz ]; then
			echo "otheraaaaaaaaaaaaaaaa"
		else
			echo ""
		fi
	fi
}

sysctl()
{
	if [ "$2" = "hw.machine_arch" ]; then
		echo "$__arch"
	elif [ "$2" = "hw.machine" ]; then
		echo "$__machine"
	else
		return 1        # failure
	fi
}

cat()
{
	if [ "$1" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-12.0-RELEASE" ]; then
		echo "base.txz 0123456789abcdef"
	elif [ "$1" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-11.1-RELEASE" ]; then
		echo "base.txz 0123456789abcdef"
	elif [ "$1" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-12.0-RC3" ]; then
		echo "base.txz aaaaaaaaaaaaaaaa"
	elif [ "$1" = "/usr/local/share/freebsd/MANIFESTS/arm64-aarch64-12.0-RELEASE" ]; then
		echo "base.txz other0123456789abcdef"
	elif [ "$1" = "/usr/local/share/freebsd/MANIFESTS/arm64-aarch64-11.1-RELEASE" ]; then
		echo "base.txz other0123456789abcdef"
	elif [ "$1" = "/usr/local/share/freebsd/MANIFESTS/arm64-aarch64-12.0-RC3" ]; then
		echo "base.txz otheraaaaaaaaaaaaaaaa"
	else
		/bin/cat "$@"
	fi
}

rm()
{
	__monitor RM "$@"
}

# UUT
. ../share/pot/create-base.sh

# common stubs
. common-stub.sh

test_fetch_freebsd_001()
{
	# not downloaded
	_fetch_freebsd 2.1
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "2" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/2.1-RELEASE_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

test_fetch_freebsd_002()
{
	# No Manifest file
	_fetch_freebsd 8.1
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "0" "$FETCH_CALLS"
	assertEquals "error calls" "2" "$ERROR_CALLS"
}

test_fetch_freebsd_003()
{
	# Wrong sha
	_fetch_freebsd 12.0
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "0" "$FETCH_CALLS"
	assertEquals "error calls" "2" "$ERROR_CALLS"
}

test_fetch_freebsd_004()
{
	# Everything fine
	_fetch_freebsd 11.1
	assertEquals "return code" "0" "$?"
	assertEquals "fetch calls" "0" "$FETCH_CALLS"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

test_fetch_freebsd_005()
{
	# Everything fine
	_fetch_freebsd 12.0-RC3
	assertEquals "return code" "0" "$?"
	assertEquals "fetch calls" "0" "$FETCH_CALLS"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

test_fetch_freebsd_006()
{
	# Need fetch first
	__didfetch="0"
	_fetch_freebsd 12.0-RC3
	assertEquals "return code" "0" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg1" "-m" "$FETCH_CALL1_ARG1"
	assertEquals "fetch arg2" "https://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/12.0-RC3/base.txz" "$FETCH_CALL1_ARG2"
	assertEquals "fetch arg3" "-o" "$FETCH_CALL1_ARG3"
	assertEquals "fetch arg4" "/tmp/12.0-RC3_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

test_fetch_freebsd_007()
{
	# Need fetch first
	__machine="arm64"
	__arch="aarch64"
	__didfetch="0"
	_fetch_freebsd 12.0-RC3
	assertEquals "return code" "0" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg2" "https://ftp.freebsd.org/pub/FreeBSD/releases/arm64/aarch64/12.0-RC3/base.txz" "$FETCH_CALL1_ARG2"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

setUp()
{
	__machine="amd64"	# default to amd64
	__arch="amd64"
	__didfetch="1"
	common_setUp
	POT_CACHE="/tmp"
	FETCH_CALLS=0
	RM_CALLS=0
}

. shunit/shunit2
