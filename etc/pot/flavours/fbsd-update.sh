#!/bin/sh

export PAGER=/bin/cat
freebsd-update fetch
freebsd-update install
