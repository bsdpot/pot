# Quickstart about `pot`

This is an introduction at the usage of `pot`, a `jail(8)` wrapper based on ZFS and `pf(4)` that naively tries to emulate containerization on FreeBSD.
`pot`uses FreeBSD specific technologies, so you need a FreeBSD machine to run it.
**NOTE** 99% of the operations needs `root` privileges. In this guide, we consider to be logged in as `root`
[TODO] FreeBSD kernel + racct
## Install `pot`
The installation process is pretty straightforward:
```shell
# pkg install -y pot
```
That's it, `pot` is installed, but we're not yet ready.
#### [Optional] Configuration
[TODO]
### Initialization
```shell
# pot init
```
## Create a simple `pot`
We can now create the simplest `pot`
```shell
# pot create -p mypot -t single -b 11.2
```
[TODO] A note about version
So, we created a `pot`, named `mypot`, based on FreeBSD 11.2 consisting of one ZFS dataset.
Now you can start it or stop it, via:
```shell
# pot start mypot
# pot stop mypot
```
If you want to have a shell inside your pot:
```shell
# pot term mypot
# pot run mypot # an alias for start+term
```
## A bit of diagnostic
Via the command:
```shell
# pot ls
# pot ls -v # more information
```
You can see a list of the `pot`s available on you local machine. The verbose output would look like this
```shell
pot name : mypot
	ip4 : inherit
	active : true
	base : 11.2
	level : 0
	datasets:
	snapshot:
```
If you want to get some information on a specific `pot`, this command is more useful:
```shell
# pot info -v -p mypot
pot name : mypot
	type : single
	base : 11.2
	level : 0
	ip4 : inherit
		no ports exported
	active : true
	datasets:
		mypot/m
	snapshot:
```
Some explanation of this output:
* `type`: currently two type of `pot` are supported: single, based on one ZFS dataset, and multi, based on multiple ZFS dataset
* `base`: the FreeBSD version used to build this `pot`
* `level`: for single type `pot` the level is always `0`. Levels are explained for the multi type `pot`
* `ip4`: the IpV4 address of the `pot` or the keyword `inherit`. By default, `inherit` is chosen, that means that this `pot` is sharing the same network stack of the running machine.
* `active`: it's a boolean value, that tells you if your `pot` is running or not
* `datasets`: single type `pot`s have only one dataset
* `snapshot`: the list of snapshots of this `pot`; currently empty.

If your `pot` is running, dynamic information can be obtained via:
```shell
# pot start mypot
# pot show -p mypot
pot mypot
	disk usage      : 274M
	virtual memory  : 13M
	physical memory : 4820K
```
This command will show the current amount of resources used by this `pot`
## Take a snapshot of your `pot`
Thanks to ZFS, taking a snapshot of your stopped `pot` is easy and super fast:
```shell
# pot stop mypot
# pot snap mypot
# pot info -v -p mypot
[..]
	snapshot:
		zroot/pot/jails/mypot@1539804703
		zroot/pot/jails/mypot/m@1539804703
```
The snapshot's name is the Unix epoch and it's used to automatically determine the snapshot's chronological sequence. 
Now you can restart it and do some real damage:
```shell
root@mycomputer# pot run mypot
root@mypot:~ # rm -rf /*
[..]
root@mypot:~ # exit
root@mycomputer# pot stop mypot
```
We have deleted almost every file in the `pot`, the pot cannot start again (feel free to try!)
The snapshot can be used to revert all the modifications occurred between the time that the snapshot was taken and now, using the following command:
```shell
# pot revert -p mypot
# pot run mypot
```
The revert command will automatically select the newest snapshot.
