#!/bin/sh

POT_FS_ROOT=/opt/carton
POT_NETWORK=127.1

# derived entries
POT_FS_JAIL=${POT_FS_ROOT}/jails

iplist()
{
	( cd ${POT_FS_JAIL} ;
		for j in $(ls -1) ; do
			ipaddr="$( grep ip4.addr $j/conf/jail.conf | sed 's/[ ;]//g' | awk -F "=" '{print $2}')"
			if [ -z "$ipaddr" ]; then
				continue
			fi
			if [ "${ipaddr##${POT_NETWORK}}" = "${ipaddr}" ]; then
				echo "$ipaddr is not in the jocker network" >& 2
			fi
			echo $ipaddr
		done
	)
}

main()
{
	iplist | sort -V
}

main
