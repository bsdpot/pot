#!/bin/sh

# system utilities stubs

if [ "$(uname)" = "Linux" ]; then
	TEST=/usr/bin/[
else
	TEST=/bin/[
fi

[()
{
	if ${TEST} "$1" = "!" ]; then
		if ${TEST} "$2" = "-r" ]; then
			if ${TEST} "$3" = "/tmp/11.1_base.txz" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/tmp/12.0_base.txz" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/tmp/8.1_base.txz" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/tmp/2.1_base.txz" ]; then
				return 0 # true
			fi
		fi
	elif ${TEST} "$1" = "-r" ]; then
		if ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-11.1-RELEASE" ]; then
			return 0 # true
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-12.0-RELEASE" ]; then
			return 0 # true
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-8.1-RELEASE" ]; then
			return 1 # false
		fi
	fi
	${TEST} "$@"
	return $?
}

fetch()
{
	__monitor FETCH "$@"
}

sha256()
{
	if [ "$2" = /tmp/11.1_base.txz ]; then
		echo "0123456789abcdef"
	elif [ "$2" = /tmp/12.0_base.txz ]; then
		echo "fedcba9876543210"
	else
		echo ""
	fi
}

cat()
{
	if [ "$1" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-12.0-RELEASE" ]; then
		echo "base.txz 0123456789abcdef"
	elif [ "$1" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-11.1-RELEASE" ]; then
		echo "base.txz 0123456789abcdef"
	else
		/bin/cat "$@"
	fi
}

# UUT
. ../share/pot/create-base.sh

# common stubs
. common-stub.sh

test_fetch_freebsd_001()
{
	_fetch_freebsd 2.1
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/2.1_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

test_fetch_freebsd_002()
{
	_fetch_freebsd 8.1
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/8.1_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "1" "$ERROR_CALLS"
}

test_fetch_freebsd_003()
{
	_fetch_freebsd 12.0
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/12.0_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "1" "$ERROR_CALLS"
}

test_fetch_freebsd_004()
{
	_fetch_freebsd 11.1
	assertEquals "return code" "0" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/11.1_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

setUp()
{
	common_setUp
	FETCH_CALLS=0
}

. shunit/shunit2
