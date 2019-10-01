# Using `pot` images

This guide has the ambitious goal of explain how to create `pot` images, a feature that allows `pot` to be used with nomad, but it can be useful in other use cases.
This guide assumes that you have already installed `pot` and you are already familiar with it (installation and quickstart guide).

## What is a `pot` image?

A `pot` image is a binary blob representing the `pot` configuration file and it's file system.
In more detail, it's a compressed archive containing a ZFS snapshot of a file system.

## Create an images `pot`

The fundamental steps to create an image of a `pot` container are:
* create a `pot`
* "customize" the `pot` as needed
* take a snapshot
* export the image

**NOTE** `export` and `import` support `single` type `pot`s. Multi-dataset `pot` are not supported yet.

#### Create a `pot`

A `pot` named `test` can be created using the command `pot create`:
```console
# pot create -p test -b 12.0 -N public-bridge -t single`
```
* `-p test` : the `pot` name
* `-b 12.0` : the FreeBSD release version to be used
* `-t single` : the `pot` type. Only `single` type are supported at the moment for `import`/`export`
* `-N public-bridge` : the network type (it can be changed during `import`, but it can be useful to use a network type that is relevant for the use case)

Once the `pot` named `test` is created, it's possible to :
* customize its configuration (attributes, starting command, and so on)
* enter in it and do whatever is needed, for instance install `nginx`
```console
# pot run test
[...]
root@test:~ # pkg install nginx
[...]
root@test:~ # exit
exit
# pot set-cmd -p test -c "nginx -g 'daemon off;'"
# pot set-attr -p test -A no-rc-script -V ON
# pot set-attr -p test -A persistent -V NO
# pot set-rss -p test -C 1
```

Once you're satisfied with your `pot`, you can stop it and take a snapshot:
```console
# pot stop test
# pot snapshot -p test
```

The snapshot can be now exported as an image, with the command `export`
```console
# pot export -p test -t 1.0
```
* `-t 1.0`: the same image can have multiple version. The option `-t` allows to provide a tag to the image

The `export` command can take quite some time, because of the compression step.
Once the `export` command ends, it generates 2 files:
```console
test_1.0.xz
test_1.0.xz.skein
```
The first file is the image, the second file is a hash file, used by the `import` command to verify the integrity.

### Images creation automated with flavours

Flavour is the way we currently provide to automate the customization of a `pot`.
With flavour, it's possible to automatically:
* apply configuration parameters to your `pot`
* execute a bootstrap script

just putting some files in flavour folder (`/usr/local/etc/pot/flavours`).

In the example above, we customized the `pot` `test` via:
```console
# pot run test
[...]
root@test:~ # pkg install nginx
[...]
root@test:~ # exit
exit
# pot set-cmd -p test -c "nginx -g 'daemon off;'"
# pot set-attr -p test -A no-rc-script -V ON
# pot set-attr -p test -A persistent -V NO
# pot set-rss -p test -C 1
```

Now we automate those commands in a flavour, called `nginx-test`.
In the flavour folder we create one file for the `pot` configuration:
```console
# cat /usr/local/etc/pot/flavours/nginx-test
set-cmd -p test -c "nginx -g 'daemon off;'"
set-attribute -p test -A no-rc-script -V YES
set-attribute -p test -A persistent -V NO
set-rss -C 1
```

The bootstrap script, that will be executed inside the jail, would look like this:
```console
# chmode a+x /usr/local/etc/pot/flavours/nginx-test.sh
# cat /usr/local/etc/pot/flavours/nginx-test.sh
#!/bin/sh

[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap
touch /etc/rc.conf
sysrc sendmail_enable="NONE"
pkg install -y nginx
pkg clean -y
```

The flavour `nginx-test` can now be used with the `create` command:
```console
# pot create -p test-flavour -b 12.0 -N public-bridge -t single -f nginx-test
```

An important note: while the bootstrap script is a shell script, where you can do whatever you want, the `pot` command usable in a flavour are a small subset:
* `add-dep`
* `copy-in`
* `mount-in`
* `set-attribute` (the abbreviated form `set-attr` is not recognized here)
* `set-rss`
* `export-ports`

**NOTE** the `mount-in` command has to be used carefully. If the `pot` will be migrated to a different machine, the folders or the ZFS datasets has to be manually migrated as well

### Images registry and import
Once an image is created, we've seen it can be exported:
```console
# pot export -p test -t 1.0
# ls
test_1.0.xz  
test_1.0.xz.skein
```
The image freshly created can now be used to create new `pot` via the command `import`:
```console
# pot import -p test -t 1.0 -U file:///path/to/images
===>  importing test @ 1.0 as test_1_0
/var/cache/pot/test_1.0.xz                     174 MB  527 MBps    00s
/var/cache/pot/test_1.0.xz.skein               257  B  598 kBps    00s
===>  Assigning new IP: 10.192.0.15
```
* `-p potname` : the name of the pot to be imported
* `-t tag`: the version of the image to be imported
* `-U URL`: the base URL to be used to download the `pot` image

The command, when executed, will download the image from the URL (caching them to `/var/cache/pot` and create a new `pot` called `test_1_0` using that image as file system:
```console
# pot info -vp test_1_0
pot name : test_1_0
	type : single
	base : 12.0
	level : 0
	network_type : public-bridge
	ip : 10.192.0.15
		no ports exported
	active : false
	datasets:
		test_1_0/m
	snapshots:
		zroot/pot/jails/test_1_0@1569922467
		zroot/pot/jails/test_1_0/m@1569922467
	attributes:
		start-at-boot: NO
		persistent: NO
		no-rc-script: YES
		procfs: NO
		fdescfs: NO
		prunable: NO
		localhost-tunnel: NO
		to-be-pruned: NO
	resource limits:
		max amount cpus: 1
```
The `import` process automatically recognizes that the `pot` uses the `prublic-bridge` and assigns a new available IP to the imported `pot`


