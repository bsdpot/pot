#!/bin/sh

# system utilities stubs
. monitor.sh

# UUT
. ../share/pot/common-flv.sh

# app specific stubs

_get_flavour_cmd_file()
{
	case "$1" in
		test)
			echo test ;;
		testnoscript)
			echo testnoscript ;;
		*)
			;;
	esac
}

_get_flavour_script()
{
	case "$1" in
		test)
			echo test.sh ;;
		testnocmd)
			echo testnocmd.sh ;;
		*)
			;;
	esac
}

test_is_cmd_flavorable_01()
{
	_is_cmd_flavorable
	assertNotEquals "$?" "0"

	_is_cmd_flavorable help
	assertNotEquals "$?" "0"

	_is_cmd_flavorable help create
	assertNotEquals "$?" "0"

	_is_cmd_flavorable create -p help
	assertNotEquals "$?" "0"

	_is_cmd_flavorable add-fscomp
	assertNotEquals "$?" "0"

	_is_cmd_flavorable add-file
	assertNotEquals "$?" "0"
}

test_is_cmd_flavorable_02()
{
	_is_cmd_flavorable add-dep
	assertEquals "$?" "0"

	_is_cmd_flavorable add-dep -v -p me -P you
	assertEquals "$?" "0"

	_is_cmd_flavorable set-rss
	assertEquals "$?" "0"

	_is_cmd_flavorable copy-in
	assertEquals "$?" "0"

	_is_cmd_flavorable mount-in
	assertEquals "$?" "0"
}

test_is_flavour_001()
{
	assertTrue "_is_flavour test"
	assertTrue "_is_flavour testnoscript"
	assertTrue "_is_flavour testnocmd"
	assertFalse "_is_flavour notest"
}

setUp()
{
	__mon_init
	_POT_VERBOSITY=1
}

tearDown()
{
	__mon_tearDown
}

. shunit/shunit2
