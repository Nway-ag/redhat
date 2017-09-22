#!/bin/bash
#set -e
virt_use_nfs_status=`getsebool -a|grep virt_use_nfs|awk '{print $3}'`
host_release=`cat /etc/redhat-release|awk '{print $7}'`
nfs_status=`mount |egrep "/vol/s3images"`
argc=$#
if [ $argc -eq 0 ]
then 
 echo "please specify the options for the guest you want to install:

    e.g.: qinstall.sh rhel6.4 [kvm] [x86_86] [qcow2] [virtio]

    USAGES:
	./qinstall.sh name [hypervisor] [arch] [format] [diskdriver]
    OPTIONS:	
	name:         the guest name you want to install, e.g. rhel6.4, rhel5.9, rhel7.0
	hypervisor:   kvm or xen, the default is kvm
	arch:         x86_64 or i386, the default is x86_64
	format:       qcow2 or raw or qed, the default is qcow2
	diskdriver:   virtio or ide, the default is virtio"	

 exit 0
fi
name=$1
case $argc in 
	2)
echo
	            case $2 in
                        kvm|xen)
                                hypervisor=$2
                                arch=x86_64
                                format=qcow2
				diskdriver=virtio
;;
                        x86_64|i386)
                                hypervisor=kvm
                                arch=$2
                                format=qcow2
				diskdriver=virtio
;;
                        qcow2|qed|raw)
                                hypervisor=kvm
                                arch=x86_64
                                format=$2
				diskdriver=virtio
;;
			virtio|ide)
				diskdriver=$2
				hypervisor=kvm
				arch=x86_64
				format=qcow2
;;
			*)
				echo "the second Parameter is error, please specify the right options"
				exit 1
;;
                esac
;;
	3)
	echo 
        if [[ $2 == kvm||$2 == xen ]];
        	then
         	hypervisor=$2
                if [[ $3 == qcow2||$3 == qed||$3 == raw ]];
                  then
                        arch=x86_64
                        format=$3
			diskdriver=virtio
                elif [[ $3 == x86_64||$3 == i386 ]];
                  then
			arch=$3
                        format=qcow2
			diskdriver=virtio
		elif [[ $3==virtio||$3==ide ]]
		  then 
			arch=x86_64
			format=qcow2
			diskdriver=$3	
                else
			echo "the third Parameter is error, please specify the right options"
                        exit 1
		fi
         elif [[ $2 == x86_64||$2 == i386 ]];
                then
                        hypervisor=kvm
			arch=$2
		if [[ $3 == qcow2||$3 == raw || $3 == qed ]];
		then
			format=$3
			diskdriver=virtio
		elif [[ $3 == virtio||$3 == ide ]]
		then
			format=qcow2
			diskdriver=$3
		else
			echo "the third Parameter is error, please specify the right options"

                        exit 1
		fi
	elif [[ $2 == qcow2||$2 == raw ]];
		then
			hypervisor=kvm
			arch=x86_64
			format=$2
		if [[ $3 == virtio||$3 == ide ]];
		  then
			diskdriver=$3
		else
			echo "the third Parameter is error, please specify the right options"

                        exit 1
		fi
	else
			echo "the second Parameter is error, please specify the right options"

			exit 1
        fi
;;
	4)
	echo
	if [[ $2 == kvm||$2 == xen ]];
	then 	
	  hypervisor=$2
		if [[ $3 == x86_64||$3 == i386 ]]
			then
			  arch=$3
				if [[ $4 == qcow2||$4 == raw|| $4 == qed  ]]
				  then
					format=$4
					diskdriver=virtio
				elif [[ $4 == virtio||$4 == ide ]]
				  then
					format=qcow2
					diskdriver=$4
				else	
				  echo "the fourth Parameter is error, please specify the right options"

                        exit 1
				fi
  		elif [[ $3 == qcow2||$3 == raw ]]
			then
			  arch=x86_64
			  format=$3
				if [[ $4 == virtio||$4 == ide ]]
				then
			 	 diskdriver=$4
				else	
				  echo "the fourth Parameter is error, please specify the right options"
                        	  exit 1
				fi
		else
			echo "Please input the right Parameter"
                	exit 1
		fi		 
	elif [[ $2 == x86_64||$2 == i386 ]]
	  then	
	    hypervisor=kvm
	    arch=$2
	    format=$3
	    diskdriver=$4
	else
		echo "Please input the right Parameter"
		exit 1 
	fi
;;
	5)
	if [[ $2 == xen||$2 == kvm ]] && [[ $3 == i386||$3 == x86_64 ]] && [[ $4 == qcow2||$4 == raw||$4 == qed ]] && [[ $5 == ide||$5 == virtio ]]

	then
		hypervisor=$2
        	arch=$3
		format=$4
		diskdriver=$5
	else
		echo "Please input the right options"
                exit 1
	fi
;;
	1)
	hypervisor=kvm
        arch=x86_64
        format=qcow2
        diskdriver=virtio
;;
	*)

	echo "Please input the right options"
        exit 1
;;
esac
if [[ $name == help || $name == --help ]]
  then
	echo "please specify the options for the guest you want to install:

    for example: install.sh rhel6.4 [kvm] [x86_86] [qcow2] [virtio]

    USAGES:
	./qinstall.sh name [hypervisor] [arch] [format] [diskdriver]
    OPTIONS:	
	name:         the guest name you want to install, e.g. rhel6.4, rhel5.9,
 rhel7.0
	hypervisor:   kvm or xen, the default is kvm
	arch:         x86_64 or i386, the default is x86_64
	format:       qcow2 or raw or qed, the default is qcow2
	diskdriver:   virtio or ide, the default is virtio"	
 	 exit 0
else
	echo
fi
	if [[ $name == win2008||$name == win2003||$name == win8|| $name == win2008r2||$name == win7||$name == winxp||$name == rhel6.1|| $name == rhel6.2||$name == rhel6.3||$name == rhel6.4||$name == rhel7.0||$name == rhel5.9||$name == rhel5.9.z||$name == rhel4.9||$name == rhel4.9.z||$name == rhel3.9||$name  == rhel3.9.z|| $name == rhel6.* ]]
	  then
		echo "  you will install $hypervisor-$name-$arch-$format-$diskdriver guest"
	if [[ $virt_use_nfs_status = "off" ]]
		then 
		   setsebool virt_use_nfs on
	fi
	echo "		mount the nfs if you has not mount"
	echo "		*******************************"
	
	if [ ${#nfs_status} -eq 0 ]
	  then
	    echo "		it will be mounded later"
	    mount 10.66.90.115:/vol/s3images/ /mnt/
	else
	    echo "	cong,you has nfs mounted" 
	fi

	if [ -e /mnt/guest/$name/$hypervisor-$name-$arch-$format-$diskdriver.xml ]
 	  then
		cp /mnt/guest/$name/$hypervisor-$name-$arch-$format-$diskdriver.xml	/var/lib/libvirt/images/
		sed -i -e s#/mnt/guest/$name/#/var/lib/libvirt/images/# /var/lib/libvirt/images/$hypervisor-$name-$arch-$format-$diskdriver.xml
	  else
 		echo "the guest is not exist on the NFS, please try to install another one"
  		exit 1
	fi
	
	if [ $format == raw ]
	  then
		echo " you need wait about 5 Minutes to download the $hypervisor-$name-$arch-$format.img, so you can do other thing first, after download the img, the guest will be started itself ~ "
		cp /mnt/guest/$name/$hypervisor-$name-$arch-$format.img /var/lib/libvirt/images/
	else
		qemu-img create -f $format /var/lib/libvirt/images/$hypervisor-$name-$arch-$format.img -b /mnt/guest/$name/$hypervisor-$name-$arch-$format.img  >/dev/null
	fi
	if [[ $host_release == 7.0 ]]
	  then
		sed -i -e s#machine\=\'rhel6\.*\.0\'#machine\=\'pc-i440fx-1.4\'# /var/lib/libvirt/images/$hypervisor-$name-$arch-$format-$diskdriver.xml
	else
	  	echo
	fi
chown qemu:qemu /var/lib/libvirt/images/$hypervisor-$name-$arch-$format.img
virsh define /var/lib/libvirt/images/$hypervisor-$name-$arch-$format-$diskdriver.xml >/dev/null 

virsh start $hypervisor-$name-$arch-$format-$diskdriver
	else 
		echo "please specify the right guest name, such as rhel5.9 rhel6.2"
fi
