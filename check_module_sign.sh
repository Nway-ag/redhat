#!/bin/bash

#-------------------------------------------------------------------------
# This small process is just use for checking the kernel module sign_key
# Li Wang <liwan@redhat.com>
#-------------------------------------------------------------------------

sign_key=
module_id=
kernel_version=

function set_test_env
{

while true;do

	read -p "Enter the kernel version(example:kernel-3.7.0-0.32.el7.x86_64):" kernel_version;
	kernel_arch=`echo $kernel_version|cut -d. -f6`
	kernel_id1=`echo $kernel_version |cut -d- -f2`
	kernel_id2=`echo $kernel_version |sed "s/\.*.$kernel_arch//" |cut -d- -f3`

	echo 
	echo "LOG_INFO: Download the kernel pakeage, plese wait..."	
	wget http://download.devel.redhat.com/brewroot/packages/kernel/${kernel_id1}/${kernel_id2}/${kernel_arch}/${kernel_version}.rpm  
	if [ $? -eq 0 ];then
		break;
	fi
done

	echo 
	echo "LOG_INFO: Decompressing the kernel packages..."
	rpm2cpio ${kernel_version}.rpm | cpio -di 2>&1 >/dev/null

	kernel_name=`echo $kernel_version |cut -d- -f2-3`

	echo
	echo "LOG_INFO: Saving all the kernel modules name in local file..."
	find lib/modules/${kernel_name}/ -name "*.ko" > all_the_kernel_modules.txt
}

function check_sign_modu
{
	echo
	echo "LOG_INFO: Saving the modules_sign_key to signed_modules_key.txt"
	for i in `cat all_the_kernel_modules.txt`; do
		modinfo $i |grep sig_key    2>&1 >/dev/null;
		if [ $? -eq 0 ];then
			modinfo $i |grep sig_key | awk '{print $2}' >> signed_modules_key.txt;
		else
			echo $i >> not_signed_modules.txt;
		fi
	done
}

function verify_sign_key
{
	sign_key=`tail -n 1 signed_modules_key.txt`
	echo
	echo "LOG_INFO: Checking the signed_modules key right or not..."
	for i in `cat signed_modules_key.txt`; do
		if [[ $sign_key = $i ]]; then
			echo "sign_key right" >> key_test_result.txt

		else
			echo
			echo $i >> wrong_signed_key.txt
		fi
	done
}

function modu_sign_test
{
	# this function checking the kernel modules sig_key results
	# if modules were not been signed or signed with error signature, process will be exit with -1.
	# if all of the signatures are right, process will be PASS.
	if [ -f not_signed_modules.txt ];then
		echo -e "`cat not_signed_modules.txt` \nThese module is/are not been signed."
		echo "LOG_INFO: Test FAIL."
		exit -1;
	elif [ -f wrong_signed_key.txt ];then
		echo -e "`cat wrong_signed_key.txt` \nThese sign_key is/are not right."
		echo "LOG_INFO: Test FAIL."
		exit -1;
	else 
		echo
		echo "LOG_INFO: All of these  modules were signed correctly, Test PASS!"
	fi
}

function cleanup
{
	rm -fr *.txt boot/ etc/ lib/ *.rpm;
}

function main
{
	set_test_env
	check_sign_modu
	verify_sign_key
	modu_sign_test
	cleanup

	return 0
}

main

#find lib/modules/3.7.0-0.32.el7.x86_64/ -name "*.ko" |xargs modinfo |grep "sig_key" |awk '{print $2}' > sign_module_key.txt
