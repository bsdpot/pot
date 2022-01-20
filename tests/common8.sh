#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/common.sh

test_is_natural_number_001()
{
	_is_natural_number 123
	assertTrue "number is not a number" "$?"
}

test_contains_spaces_001()
{
	_contains_spaces "no-spaces"
	assertFalse "found spaces in a string with no spaces" "$?"
}

test_contains_spaces_002()
{
	_contains_spaces "with spaces"
	assertTrue "not found spaces in a string with spaces" "$?"

	_contains_spaces "/mnt/with space"
	assertTrue "not found spaces in a string with spaces" "$?"

	_contains_spaces "/mnt/space "
	assertTrue "not found spaces in a string with spaces" "$?"
}
. shunit/shunit2
