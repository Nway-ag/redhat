#!/bin/bash 
set -x

#------------------------------------------------------------#
# This script is just using for virtual-machine install #
# Author: Li Wang <liwan@redhat.com>			     #
#------------------------------------------------------------#


#setup the environment
egrep '(vmx|svm)' /proc/cpuinfo 2>&1 >/dev/null
if [ $? -ne 0 ];then
	echo "Sorry, this machine is not support kvm install."
	exit -1;
else
	yum install qemu-kvm qemu-img libvirt virt-manager libvirt-python python-virtinst libvirt-client virt-install -y

fi

#general a virtual disk for the os
dd if=/dev/urandom of=123.img bs=1024 count=1024
echo y | mkfs.ext2 -c 123.img 2048
mkdir /mnt/task
mount -o loop 123.img /mnt/task/;

#restart the libvertd service
egrep 7 /etc/redhat-release;
if [ $? -eq 0 ];then
	systemctl restart libvirtd.service	
else
	service libvirtd restart

fi

#install a new virtual machine
virt-install \
	--name RHEL-6.5 	\
	--virt-type kvm		\
#	--arch x86_64		\
	--ram 2048 		\
	--vcpus 2 		\
	--nographics		\
	--nonetwork		\
	--disk path=/var/lib/libvirt/images/RHEL-6.5.img,size=10 \
#	--location http://download.devel.redhat.com/rel-eng/RHEL-7.0-20140326.0/compose/Server/x86_64/os  --noreboot
	--location http://download.eng.rdu2.redhat.com/rel-eng/latest-RHEL6.5/6.5/Server/x86_64/os/ 

set +x
exit 0;
