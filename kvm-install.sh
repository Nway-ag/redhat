#!/bin/bash 
set -x

#------------------------------------------------------------#
# This script is just using for virtual-machine install #
# Author: Li Wang <liwang@redhat.com>			     #
#------------------------------------------------------------#


#setup the environment
egrep '(vmx|svm)' /proc/cpuinfo 2>&1 >/dev/null
if [ $? -ne 0 ];then
	echo "Sorry, this machine is not support kvm install."
	exit -1;
else
	yum install qemu-kvm qemu-img libvirt virt-manager libvirt-python libvirt-client virt-install -y

fi

#restart the libvertd service
egrep 7 /etc/redhat-release;
if [ $? -eq 0 ];then
	systemctl restart libvirtd.service	
else
	service libvirtd restart

fi

#install a new virtual machine
virt-install \
	--name RHEL-7.3	\
	--virt-type kvm		\
	--arch x86_64		\
	--ram 2048 		\
	--vcpus 2 		\
	--nographics		\
	--nonetwork		\
	--disk path=/var/lib/libvirt/images/RHEL-7.3.img,size=10 \
	--location http://download.devel.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os \
	--extra-args 'console=ttyS0,115200 ks=file:/SERVER.ks'	\
	--noreboot

set +x
exit 0;
