#!/bin/sh

pkg install -y dnsmasq
pkg install -y consul
pkg clean -ayq

if [ ! -d /usr/local/etc/consul.d ]; then
	mkdir -p /usr/local/etc/consul.d
fi

_epair="$(ifconfig | egrep 'epair.*b' | cut -f 1 -d':')"
_ip="$( ifconfig $_epair inet | awk '/inet/ { print $2; }' )"
_ip1="$( echo $_ip | cut -f 1 -d'.' )"
_ip2="$( echo $_ip | cut -f 2 -d'.' )"
_domain="$( hostname | cut -f 2 -d'.' )"
echo "server=/${_domain}/127.0.0.1#8600" >> /usr/local/etc/dnsmasq.conf
echo "server=/0.${_ip2}.${_ip1}.in-addr.arpa/127.0.0.1#8600" >> /usr/local/etc/dnsmasq.conf
echo "listen-address=${_ip}" >> /usr/local/etc/dnsmasq.conf

sysrc dnsmasq_enable="YES"
sysrc consul_enable="YES"
sysrc consul_args="-server -dev -domain=${_domain} -bind=${_ip}"
