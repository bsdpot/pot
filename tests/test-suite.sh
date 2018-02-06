#!/bin/sh

DOIT=
SHL=sh
if [ "$(uname)" = "Linux" ]; then
	# using bash explicitely because of travis unkowns about /bin/sh
	DOIT=bash
	SHL=bash
fi

if ! $SHL -n ../bin/pot ../share/pot/*.sh ; then
	exit 1
else
	echo "Syntax check passed"
	echo
fi

suites=$(ls *.sh)
rc=0
for s in $suites ; do
	if [ "$s" = "test-suite.sh" ]; then
		continue
	elif [ "$s" = "common-stub.sh" ]; then
		continue
	elif [ "$s" = "monitor.sh" ]; then
		continue
	else
		echo "Running $s ..."
		$DOIT ./$s || rc=1
	fi
done
exit $rc
