#!/bin/sh 

function fetch_patch
{
	###download all the patches### 
	echo "LOGINFO: Patches Donwloading ..."
	for i in `seq 1 105`; do
		patch_link="`cat bz726863_patch_links.txt | sed -n ''$i'p' | awk '{print $3}'`/raw"
		wget -P ./download_patch $patch_link
	done
}

function pick_up_keywords
{
	#pick up the keywords
	echo "LOGINFO: Pick up all the keywords from patch..."
	cd ./download_patch;

	for i in `seq 2 106`; do  #attention!!!
		patch=`ls -l | sed -n ''$i'p' | awk '{print $9}'`
	
		value=`cat $patch | grep '+' | grep "ppc64" -c`
		if [ $value -ge 1 ];then
			cat $patch | grep '+' | sed -n '3p' | awk '{print $2}' >> ../results/kabi_ppc64.txt
		fi

		value=`cat $patch | grep '+' | grep "s390x" -c`
		if [ $value -ge 1 ];then
			cat $patch | grep '+' | sed -n '3p' | awk '{print $2}' >> ../results/kabi_s390x.txt
		fi

		value=`cat $patch | grep '+' | grep "x86_64" -c`
		if [ $value -ge 1 ];then
			cat $patch | grep '+' | sed -n '3p' | awk '{print $2}' >> ../results/kabi_x86_64.txt
		fi
	done
	cd ..
}

function test_running
{
	###checking the keywords in new kabi###
	echo "LOGINFO: compare the results in kernel-89-el7 ..."
	for i in `cat ./results/kabi_ppc64.txt`; do
		value=`cat /lib/modules/kabi-rhel70/kabi_whitelist_ppc64 | grep $i -c`
		if [ $value -eq 0 ];then
			echo "$i" >> ./results/kabi_whitelist_ppc64_omit.txt	
		fi
	done

	for i in `cat ./results/kabi_s390x.txt`; do
		value=`cat /lib/modules/kabi-rhel70/kabi_whitelist_s390x | grep $i -c`
		if [ $value -eq 0 ];then
			echo "$i" >> ../results/kabi_whitelist_s390x_omit.txt	
		fi
	done

	for i in `cat ./results/kabi_x86_64.txt`; do
		value=`cat /lib/modules/kabi-rhel70/kabi_whitelist_x86_64 | grep $i -c`
		if [ $value -eq 0 ];then
			echo "$i" >> ./results/kabi_whitelist_x86_64_omit.txt	
		fi
	done
}

function check_output
{
	###print the compare resul###t
	if [ -f ./results/kabi_whitelist_ppc64_omit.txt ] || [ -f ./results/kabi_whitelist_s390x_omit.txt ] || [ -f ./results/kabi_whitelist_s390x_omit.txt ];then
		echo "LOGINFO: Test FAIL"
	else
		echo "LOGINFO: Test PASS"
	fi
}

function cleanup
{
	cp -r ./download_patch/* ./download_patch_old;
	rm -fr ./download_patch/*;
	cd ./results;
	cp * ../results_old;
	rm -fr *;
	cd ..
}

function main
{
	fetch_patch
	pick_up_keywords
	test_running
	check_output
	cleanup

	return 0;
}

main
