# pot

[![Test Status](https://travis-ci.org/pizzamig/pot.png?branch=master)](https://travis-ci.org/pizzamig/pot) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Another container framework based on jails, to run FreeBSD containers on FreeBSD.
Every running instance is called "pot", but less flexible than a VM.
It's heavily based on FreeBSD, in particular on jails, ZFS, pf and rctl.

Currently, pot is only a bunch of shell script enforcing the pot container model, but it relay only on the command line tools provided by FreeBSD to play with jails, ZFS and so on.
So, at the moment the only dependency is the operating system. That will change in the future, to provide more feature.

It is an educational/experimental project, so don't expect any production quality.

### Installation

A package is available, even if it could be a bit outdated. You can install it via:
```sh
# pkg install pot
```

Or you can install pot manually:
* clone the master repo
* add the bin directory to the PATH environment variable

### Initialization

Before to run any initialization, I suggest to copy `etc/pot/pot.defaul.conf` in `etc/pot/pot.conf` and set all variables in accord to your system.

When the pot'r configuration file is ready, the initialization can be performed (root privileges are needed):
```sh
# pot init
# pot create-base -r 11.1
```

The first command will initialize zfs datasets

The first command create a usable base, based on FreeBSD 11.1

**NOTE** You can use base versions that are less or equal of your host system versions.

Example: you can create a 11.1 or a 10.4 base on a FreeBSD 11.1 machine.

Example2: you can create a 10.4 base on a FreeBSD 10.4 machine, but not a 11.1 base.

### Create your first pot

Now you can create a pot using the command:
```sh
# pot create -p potname -b 11.1
```

To start and access it, you can used the command:
```sh
# pot run potname
```

This command will start the pot and spawn a `tcsh` shell in it
