#!/bin/sh

DOIT=

if [ "$(uname)" = "Linux" ]; then
	# using bash explicitely because of travis unkowns about /bin/sh
	DOIT=bash
fi

suites=$(ls *.sh)
rc=0
for s in $suites ; do
	if [ "$s" = "test-suite.sh" ]; then
		continue
	else
		echo "Running $s ..."
		$DOIT ./$s || rc=1
	fi
done
exit $rc
