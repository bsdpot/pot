#!/bin/sh

DOIT=

if [ "$(uname)" = "Linux" ]; then
	# using bash explicitely because of travis unkowns about /bin/sh
	DOIT=bash
fi

suites=$(ls *.sh)
for s in $suites ; do
	if [ "$s" = "test-suite.sh" ]; then
		continue
	else
		$DOIT ./$s
	fi
done
