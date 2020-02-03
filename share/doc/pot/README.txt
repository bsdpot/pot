Instruction to build man pages
==============================

Pre-requirements
----------------

you need to install sphinx and gmake

	pkg install py37-sphinx py37-recommonmark

Build man page
--------------

	make

Open the man page
------------------

To view the pot.8 page:
	make view
or
	man _build/man/pot.8

To view the pot.7 page:
	make view7
or
	man _build/man/pot.7
