#!/bin/sh

ifconfig lo1 create
ifconfig lo1 inet 127.1.0.0 netmask 0xffff0000
kldload -n pf
pfctl -f /opt/carton/conf/pf.conf
pfctl -e
