# VitalPBX - Raspberry PI
Script and resources to install VitalPBX on Raspberry PI Machines

 ![VitalPBX & Raspberry PI](https://github.com/VitalPBX/raspberry/blob/master/resources/RasperiPI.jpg?raw=true)

- **[Requirements](#requirements)**
- **[How to Install](#how-to-used)**
- **[Troubleshooting](#troubleshooting)**
- **[Important Note](#important-note)**

## Requirements
You must to have installed the Centos 7 image for Raspberry PI Minimal. You can download it in the following link.
http://mirror.math.princeton.edu/pub/centos-altarch/7.6.1810/isos/armhfp

a.- Unzip the .xz image and we will have a .raw file

b.- Use the balenaEtcher program to burn it in an SD memory of at least 16 GB

c.- Finally, enter the SD memory in the Raspberry and the boot starts, the credentials to enter are the following:
User: root
Password: centos

d.-Now let's expand to the maximum capacity the SD
<pre>
[root@localhost ~]# /usr/bin/rootfs-expand
</pre>

## How to Install
1. If you don't have installed __wget__ command, install it in the following way:
<pre>
yum install wget -y
</pre>
2. Download the script:
<pre>
wget https://raw.githubusercontent.com/VitalPBX/raspberry/master/install.sh
</pre>
3. Set correct permissions to script:
<pre>
chmod +x install.sh
</pre>
4. Excute the script to install VitalPBX:
<pre>
./install.sh
</pre>

## Troubleshooting

## Important Note
