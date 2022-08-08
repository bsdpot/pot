#!/bin/sh

DOIT=
SHL="sh"
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

if ! command -v flock >/dev/null; then
	echo "flock not found." 1>&2
	if [ "$(uname)" = "FreeBSD" ]; then
		echo "Consider installing sysutils/flock" 1>&2
		echo "(pkg install flock)" 1>&2
	fi
	exit 1
fi

suites=$(ls ./*.sh)
rc=0
for s in $suites ; do
	if [ "$s" = "./test-suite.sh" ]; then
		continue
	elif [ "$s" = "./common-stub.sh" ]; then
		continue
	elif [ "$s" = "./conf-stub.sh" ]; then
		continue
	elif [ "$s" = "./pipefail-stub.sh" ]; then
		continue
	elif [ "$s" = "./monitor.sh" ]; then
		continue
	else
		echo "Running $( basename $s ) ..."
		$DOIT "./$s" || rc=1
	fi
done
exit $rc
