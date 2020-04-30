#!/bin/sh

export PAGER=/bin/cat
freebsd-update --not-running-from-cron fetch install
