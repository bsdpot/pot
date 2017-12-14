#!/bin/sh

__monitor()
{
	local M i C
	i=0
	M=$1
	shift
	eval ${M}_CALLS=\$\(\( ${M}_CALLS + 1 \)\)
	eval C=\$${M}_CALLS
	while [ -n "$1" ]; do
		i=$(( i + 1 ))
		eval ${M}_CALL${C}_ARG${i}=\$1
		shift
	done
}

