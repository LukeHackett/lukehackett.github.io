---
layout: post

author: Luke Hackett
title:  "Upgrading an End-of-Life Ubuntu Server"
tags:
  - ubuntu
  - devops
---

I was recently tasked with updating a handful of Ubuntu 15.04 "Vivid" servers to Ubuntu 16.04 LTS "Xenial". At first this seemed pretty easy, but I quickly realised that  Ubuntu 15.04 reached it’s end of life in February 2016... and I was attempting to perform this upgrade in January 2020. Let the fun times roll!

<!--excerpt-->

When I initially ran `sudo apt-get update`, I noticed that there were a lot of 404 Not Found errors:

```shell
$ sudo apt-get update

Err http://security.ubuntu.com vivid-security/main Sources
  404  Not Found [IP: 91.189.91.15 80]
Err http://security.ubuntu.com vivid-security/universe Sources
  404  Not Found [IP: 91.189.91.15 80]
Err http://security.ubuntu.com vivid-security/main amd64 Packages
  404  Not Found [IP: 91.189.91.15 80]
Ign http://archive.ubuntu.com vivid-updates/main amd64 Packages/DiffIndex
Err http://security.ubuntu.com vivid-security/universe amd64 Packages
  404  Not Found [IP: 91.189.91.15 80]
```

After visiting the Ubuntu distribution lists `http://archive.ubuntu.com/ubuntu/dists` I noticed that all Vivid packages have been removed, while current supporting images, such as Trusty, Xenial and Bionic remained. This was also confirmed by visiting the [Ubuntu release website](https://wiki.ubuntu.com/Releases) which indicated which releases were supported and which were not.

After trailing through a few forums, I discovered that rather than removing the older packages from the Ubuntu distribution, they are archived as "Old Releases" here: `http://old-releases.ubuntu.com/ubuntu/dists/`. This archive list is essentially a list of unsupported and insecure packages.

In order to make apt-get update work, a small updated within the `/etc/apt/sources.list` is required. Essentially all references to security.ubuntu.com and archive.ubuntu.com should be altered to `old-releases.ubuntu.com`, as per the following `sed` command:

```shell
$ sudo sed -i.bak -r 's/(archive|security).ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
```

Once completed, running sudo apt-get update seems to complete without any problems. 

I then proceeded to perform the release upgrade using the `do-release-upgrade` command, but experienced another error:

```shell
$ sudo do-release-upgrade
Reading cache

Checking package manager

Cannot upgrade

An upgrade from 'vivid' to 'xenial' is not supported with this tool.
=== Command terminated with exit status 1 ===
```

The `do-release-upgrade` command only supports upgrading to the next Ubuntu version, but as the current server is not on the latest version of 15 (15.10 is the latest), the `do-release-upgrade` command refuses to perform the upgrade. To solve this problem, I needed to upgrade to 15.10 - this was also an end-of-life operating system!

Firstly, I modified `/etc/apt/sources.list` again, swapping out all references to vivid to wily (15.10): 

```shell
$ sudo sed -i.bak -r 's/vivid/wily/g' /etc/apt/sources.list
```

Once completed, I removed any cached packages and updated the latest packages with the following commands:

```shell
$ sudo apt-get clean
$ sudo apt-get update
```

Now I can upgrade from Ubuntu 15.04 to Ubuntu 15.10 with:

```shell
$ sudo apt-get dist-upgrade
```

After 10 minutes and a reboot, I was now running Ubuntu 15.10. This is progress, but I wasn’t at the end goal of having an Ubuntu 16.04 LTS install. Luckily the `do-release-upgrade` command supports upgrading from Ubuntu 15.10 to Ubuntu 16.04, so the upgrade was a simple as:

```shell
$ sudo do-release-upgrade
```

After another 10 minutes and another reboot, I was now running Ubuntu 16.04 LTS - a great success! 
