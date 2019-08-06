#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/common.sh

test_is_natural_number_001()
{
	_is_natural_number 123
	assertTrue "number is not a number" "$?"
}

. shunit/shunit2
