#!/bin/sh
if [ "$(uname)" = "Linux" ]; then
	# using bash explicitely because of travis unkowns about /bin/sh
	bash ./common1.sh
else
	./common1.sh
fi
