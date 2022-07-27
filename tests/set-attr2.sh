#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/set-attribute.sh

# common stubs
. common-stub.sh

# app specific stubs
set-attribute-help()
{
	__monitor HELP "$@"
}

test_normalize_true_false_1()
{
	local rc
	if rc=$(_normalize_true_false YES) ; then
		assertEquals "YES" "$rc"
	else
		fail "it shouldn't be here"
	fi
}

test_normalize_true_false_2()
{
	local rc
	if rc=$(_normalize_true_false NO) ; then
		assertEquals "NO" "$rc"
	else
		fail "it shouldn't be here"
	fi
}

test_normalize_true_false_3()
{
	local rc
	if rc=$(_normalize_true_false asdfasdf) ; then
		fail "it shouldn't be here"
	else
		assertEquals "" "$rc"
	fi
}

setUp()
{
	common_setUp
}

. shunit/shunit2
