Instruction to build man pages
==============================

Pre-requirements
----------------

you need to install sphinx and gmake

	pkg install py37-sphinx py37-recommonmark gmake

Build man page
--------------

	gmake man

Open the mang page
------------------

	man _build/man/pot.8
	man _build/man/pot.7
