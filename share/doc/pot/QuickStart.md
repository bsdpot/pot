# Quickstart about `pot`

This is an introduction at the usage of `pot`, a `jail(8)` wrapper based on ZFS and `pf(4)` that naively tries to emulate containerization on FreeBSD.
`pot`uses FreeBSD specific technologies, so you need a FreeBSD machine to run it.

**NOTE**: 99% of the operations needs `root` privileges. In this guide, we consider to be logged in as `root`

**NOTE2**: ZFS is mandatory, so if you don't know what it is or you don't have a ZFS pool, please consider to read this [quick guide](https://www.freebsd.org/doc/handbook/zfs-quickstart.html)

**NOTE3**: Some features, like memory limits and memory usage, rely on the resources limit framework, normally disabled. Even if it's not mandatory, it's suggested to enable it, with the following steps:
```shell
# echo kern.racct.enable=1 >> /boot/loader.cont
```
This settings will take effect at the next reboot.

**NOTE4**: One of the 3 network configuration need VNET(9), the network subsystem virtualization infrastructure, enabled in the kernel.
On FreeBSD > 12, this kernel feature is already enabled and you don't need to do anything.
On FreeBSD <= 11.x, you have to rebuild the kernel, enabling the VIMAGE options, following the instruction reported [here](https://www.freebsd.org/doc/handbook/kernelconfig.html)
## Install `pot`
The installation process is pretty straightforward:
```shell
# pkg install -y pot
```
That's it, `pot` is installed, but we're not yet ready.
#### Configuration [Optional]
Under the folder `/usr/local/etc/pot` you'll find two files:
* `pot.default.conf`
* `pot.conf`

The `pot.default.conf` contains all the default values and it shouldn't be touched.
If you want to change something, please modify `pot.conf` instead.
### Initialization
When you are happy with your configuration file, especially with the location of `POT_ZFS_ROOT`, you can run:
```shell
# pot init
```
This command will just create the needed ZFS datasets.
## Create a simple `pot`
We can now create the simplest `pot`
```shell
# pot create -p mypot -t single -b 11.2
```
**NOTE** The FreeBSD machine doesn't have to be the same version of your `pot` (jail). However, the hosting machine's version has to be greater or equal than the `pot`'s one.
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
