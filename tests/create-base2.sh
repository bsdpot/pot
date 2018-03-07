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
			elif ${TEST} "$3" = "/tmp/11.0_base.txz" ]; then
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
		elif ${TEST} "$2" = "/usr/local/share/freebsd/MANIFESTS/amd64-amd64-11.0-RELEASE" ]; then
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
	__monitor SHA "$@"
	if [ "$2" = /tmp/11.1_base.txz ]; then
		echo "0123456789abcdef"
	elif [ "$2" = /tmp/11.0_base.txz ]; then 
		echo "fedcba9876543210"
	else
		echo ""
	fi
}

awk()
{
	__monitor AWK "$@"
	echo "0123456789abcdef"
}

# UUT
. ../share/pot/create-base.sh

# common stubs
. common-stub.sh

test_cb_fetch_001()
{
	_cb_fetch 2.1
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/2.1_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

test_cb_fetch_002()
{
	_cb_fetch 8.1
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/8.1_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "1" "$ERROR_CALLS"
}

test_cb_fetch_003()
{
	_cb_fetch 11.0
	assertEquals "return code" "1" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/11.0_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "1" "$ERROR_CALLS"
}

test_cb_fetch_004()
{
	_cb_fetch 11.1
	assertEquals "return code" "0" "$?"
	assertEquals "fetch calls" "1" "$FETCH_CALLS"
	assertEquals "fetch arg4" "/tmp/11.1_base.txz" "$FETCH_CALL1_ARG4"
	assertEquals "error calls" "0" "$ERROR_CALLS"
}

setUp()
{
	common_setUp
	FETCH_CALLS=0
	SHA_CALLS=0
	AWK_CALLS=0
}

. shunit/shunit2
