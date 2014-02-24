#!/bin/sh 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# #
# #   test_case_bz726863.sh 
# #   Description: common test for kabi-symbols
# #   Author: Li Wang <liwan@redhat.com>
# #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# #
# #   Copyright (c) 2014 Red Hat, Inc. All rights reserved.
# #
# #   This copyrighted material is made available to anyone wishing
# #   to use, modify, copy, or redistribute it subject to the terms
# #   and conditions of the GNU General Public License version 2.
# #
# #   This program is distributed in the hope that it will be
# #   useful, but WITHOUT ANY WARRANTY; without even the implied
# #   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# #   PURPOSE. See the GNU General Public License for more details.
# #
# #   You should have received a copy of the GNU General Public
# #   License along with this program; if not, write to the Free
# #   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
# #   Boston, MA 02110-1301, USA.
# #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

KERNEL=`uname -r | cut -b 1-13`
PATCH_NUMS=

function set_env
{
	rpm -qa kernel-abi-whitelists
	if [ $? -ne 0 ];then
		wget http://download.devel.redhat.com/brewroot/packages/kernel/`uname -r | cut -b 1-6`/`uname -r | cut -b 8-13`/noarch/kernel-abi-whitelists-"$KERNEL".noarch.rpm;
		rpm -ivh kernel-abi-whitelists-"$KERNEL".noarch.rpm
	fi

	mkdir download_patch download_patch_old results results_old
}

function fetch_patch
{
	###download all the patches### 
	echo "LOGINFO: Patches Donwloading ..."
	PATCH_NUMS=`cat ./bz726863_patch_links.txt | wc -l`
	for i in `seq 1 $PATCH_NUMS`; do
		patch_link="`cat bz726863_patch_links.txt | sed -n ''$i'p' | awk '{print $3}'`/raw"
		wget -P ./download_patch $patch_link 2&>>1 > /dev/null 
	done
}

function pick_up_keywords
{
	###pick up the keywords###
	echo "LOGINFO: Pick up all the keywords from patch..."
	PATCH_NUMS=`cat ./bz726863_patch_links.txt | wc -l`
	cd ./download_patch;
	row=`expr $PATCH_NUMS + 1`
	for i in `seq 2 $row`; do  #attention!!!
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
	###print the compare resul###
	if [ -f ./results/kabi_whitelist_ppc64_omit.txt ] || [ -f ./results/kabi_whitelist_s390x_omit.txt ] || [ -f ./results/kabi_whitelist_s390x_omit.txt ];then
		echo "LOGINFO: Test FAIL"
	else
		echo "LOGINFO: Test PASS"
	fi
}

function cleanup
{
	cp  ./download_patch/* ./download_patch_old;
	rm -rf ./download_patch/*;
	cp ./results/* ./results_old;
	rm -rf ./results/*;
	rm -fr 1 2;
}

function main
{
	set_env
	fetch_patch
	pick_up_keywords
	test_running
	check_output
	cleanup

	return 0;
}

main
