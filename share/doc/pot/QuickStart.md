# QuickStart Guide on `pot`

This is an introduction at the usage of `pot`, a `jail(8)` wrapper based on ZFS and `pf(4)` that naively tries to emulate containerization on FreeBSD.

`pot` uses FreeBSD specific technologies, so you need a FreeBSD machine to run it.

**NOTE**: 99% of the operations needs `root` privileges. In this guide, we consider to be logged in as `root`

**NOTE2**: ZFS is mandatory, so if you don't know what it is or you don't have a ZFS pool, please consider to read this [quick guide](https://www.freebsd.org/doc/handbook/zfs-quickstart.html)

**NOTE3**: Some features, like memory limits and memory usage, rely on the resources limit framework, normally disabled. Even if it's not mandatory, it's suggested to enable it, with the following steps:
```shell
# echo kern.racct.enable=1 >> /boot/loader.cont
```
This settings will take effect at the next reboot.

**NOTE4**: One of the 3 network configuration need `VNET(9)`, the network subsystem virtualization infrastructure, enabled in the kernel.
On FreeBSD 12 and later, this kernel feature is already enabled and you don't need to do anything.
On FreeBSD 11.x, you have to rebuild the kernel, enabling the VIMAGE options, following the instruction reported [here](https://www.freebsd.org/doc/handbook/kernelconfig.html)
FreeBSD 10.x is not tested as host system.
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

All needed changes have to be stored in the `pot.conf` file. Please take your time to give a look to this file and to change configuration accordingly to your system

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
For instance, you can ran a FreeBSD 10.4 `pot` on a FreeBSD 11.2 host. You **cannot** run a FreeBSD 12 `pot` on a FreeBSD 11.2 host.

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
You can see a list of the `pot`s available on you local machine. The verbose output would look like this:
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
		no ports exported (static)
		no ports exported (dynamic)
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

If your `pot` is running, runtime information can be obtained via:
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
The revert command will automatically select the newest snapshot available.
## Attach a "volume" to your pot
Let's say that you want to attach a pre-existent "volume" to your `pot`.
To do that, there is one limitation and 2 possible ways.

### Limitation
The "volume" that you can attach to a `pot` has to be a ZFS dataset. You cannot attach a generic directory or a disk partition. You can attach ZFS dataset only.

### First way: fscomp
To support users managing ZFS datasets for `pot`, the concept of `fscomp` (AKA file system component) is introduced.
You can create a file system component in the `pot` ecosystem, that can be attached to one or more `pot`s.

When a `fscomp` is created, the underlaying ZFS dataset is created as well.

To create a `fscomp`, you can run:
```shell
# pot create-fscomp -f myfscomp
```
With this command, you have created an empty ZFS dataset, a "volume", that can be attached to one or more `pot`s

A list of available `fscomp`s can be obtained with the command:
```shell
# pot ls -f
```
To attach your new `fscomp` to a `pot`, you can use the command:
```shell
# pot add-fscomp -p mypot -f myfscomp -m /mnt
# pot info -p mypot -v
```
The `-m` mandatory option represents the mountpoint (absolute pathname) inside the `pot`.

The advantage of this approach, is that `fscomp` are recognized by the `pot` framework, and a set of features is provided, like snapshot, rollback and clone.

### Second way: an already existent dataset
It could happen that you want to attach to a `pot` a pre-existing ZFS dataset and you don't want to create an emtpy `fscomp` and move all data there.

To add and external ZFS dataset, the command would be:
```shell
# pot add-fscomp -p mypot -m /mnt -f zroot/mydataset -e
```
The main difference is the presence of the flag `-e` (external) and the argument of the option `-f` is not a `fscomp` name anymore, but a generic valid ZFS dataset.
### Common consideration
The `add-fscomp` command will change the configuration of the `pot`; the `fscomp` will be mounted when the `pot` starts and unmounted when the `pot` stops.
A `fscomp` can be used with multiple `pot`s. Potential problems, like concurrent access to the same files, cannot be managed by `pot` and are left to the user.

In order to mitigate concurrency access to the same `fscomp`, the option `-r` is introduced:
```shell
# pot add-fscomp -p mypot-ro -f myfscomp -m /mnt -r
# pot add-fscomp -p mypot-rw -f myfscomp -m /mnt
```
This option will inform the framework to mount `myfscomp` in `mypot-ro` in read-only mode, while in `mypot-rw` that same `myfscomp` is mounted in read-write mode.

## Network configuration
During the creation phase, it's possible to specify which type of network our `pot` should use.
`pot` supports three different type of network configurations:
* inherit
* IPv4 alias on the host network interface
* IPv4 address on the internal virtual network

By default, `inherit` is chosen.
### Network configuration: inherit
To use the `inherit` network type, a `pot` can be created with the following command:
```shell
# pot create -p mypot -t single -b 11.2 -i inherit
```
The option `-i` can be omitted, because `inherit` is the default value.
The `inherit` type means that `mypot` will reuse the same network stack of the host machine.
This network type works pretty well when your `pot` doesn't provide any network services, but it uses the network's host as client, like a `pot` created to build applications.

### Network configuration: IPv4 alias
If your host system has a static IP and you can use multiple static IP, you can assign one of those addition IP addresses to your `pot`s via the static/external IPv4.
**NOTE** Be sure that in the `pot` configuration file (`/usr/local/etc/pot/pot.conf`) you have correctly set the variable `POT_EXTIF`; this network interface will be used for the network activity and IP address assignment.
For example, your system has 192.168.178.20/24 as IP address and your network administrator reserved you the additional IP address 192.168.178.200.
To assing the latter IP address to your `pot` you can create it with the following command:
```shell
# pot create -p mypot -t single -b 11.2 -i 192.168.178.200
# pot start mypot
# pot info -vp mypot
```
The alias 192.168.178.200 will be assigned to the network interface during the start phase.
Now, your `pot` is bound to the address 192.168.178.200
When the `pot` is stopped, the alias will be automatically removed from the inferface.
More information about alias are available in the `man` page of `ifconfig(8)`

### Network configuration: IPv4 virtual network
Thanks to `VNET(9)`, `pot` supports an IPv4 virtual network. This network is configured in configuration file (`/usr/local/etc/pot/pot.conf`), so be sure to have it properly configured.
`pot` supports only one virtual network, so all `pot`s will share it.

To help `pot` and users to deal with the internal virtual network an additional package is required, installable via:
```shell
# pkg install potnet
```
To verify you virtual network configuration, this command can be used:
```shell
# potnet show
Network topology:
	network : 10.192.0.0
	min addr: 10.192.0.0
	max addr: 10.255.255.255

Addresses already taken:
	10.192.0.0	
	10.192.0.1	default gateway
	10.192.0.2	dns
```
The output is from my configuration, your addresses can differ, depending on the configuration values you have adopted.

Optionally, you can start the virtual network via the command:
```shell
# pot vnet-start
```
This command will create and configure the network interfaces properly and will activate `pf` to perform NAT on the virtual network.

**NOTE** This command is automatically executed when a `pot` needs the virtual network. There is no need to run it manually.

The following command will create a `pot` running on the internal network:
```shell
root@myhost# pot create -p mypot -t single -b 11.2 -i auto
root@myhost# pot run mypot
root@mypot:~ # ping 1.1.1.1
[..]
root@mypot:~ # exit
root@myhost# pot stop mypot
```
The `auto` keyword will automatically select an available address in the internal virtual network.
Commands like `pot info -p mypot` and `potnet show` will show you exactly which address has been assigned to your `pot`

If you prefer to assign a specific IP address of your virtual network, you can just do:
```shell
root@myhost# pot create -p mypot -t single -b 11.2 -i 10.192.0.10
```
`pot` will verify if the IP address is free to use.
#### Export services
The virtual network is not visible outside the host machine, becuase of the pf's NAT.
To make your network services running in your `pot` visible outside the TCP/UDP, desired ports have to be exported/redirected.
`pot` provides a command to tell which port has to be exported.
```shell
# pot export-ports -p mypot -e 80 -e 443
```
The `export-ports" command will make available the port 80 and 443 outside the virtual network. At start, `pot` look for an available host port that can be used to redirect the traffic from the host to the virtual network.

To know which port is used, you can use the `show` command:
```shell
# pot start mypot
# pot show -p mypot
pot mypot
	disk usage      : 274M
	virtual memory  : 13M
	physical memory : 4824K

	Network port redirection
		192.168.178.20 port 1024 -> 10.192.0.3 port 80
		192.168.178.20 port 1025 -> 10.192.0.3 port 443
```

