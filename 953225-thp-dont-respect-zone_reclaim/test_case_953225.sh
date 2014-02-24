#!/bin/bash
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# #
# #   test_case_953225.sh of /kernel/memory/bug_953225
# #   Description: common test for MM_test 
# #   Author: Wang Li <liwan@redhat.com>
# #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# #
# #   Copyright (c) 2013 Red Hat, Inc. All rights reserved.
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

cur_path=$(pwd)
zone_reclaim_mode=
drop_caches=
thp_enabled="always"
function compile_tools()
{
	### compile the C program ###
	if [ -f breakthp.c ] && [ -f usemem.c ]; then
		gcc -o breakthp breakthp.c
		gcc -o usemem usemem.c
	else
		echo "LOGINFO: Sorry,$(pwd)breakthp.c or $(pwd)usemem.c not exist."; 
	fi
}

function setup_test_env()
{
	compile_tools

	### set the env for testing ###
	zone_reclaim_mode=`cat /proc/sys/vm/zone_reclaim_mode`
	echo 1 > /proc/sys/vm/zone_reclaim_mode

	drop_caches=`cat /proc/sys/vm/drop_caches`
	echo 3 > /proc/sys/vm/drop_caches

	echo never > /sys/kernel/mm/transparent_hugepage/enabled
}

function cleanup()
{
	echo "$zone_reclaim_mode" > /proc/sys/vm/zone_reclaim_mode
	echo "$drop_caches" > /proc/sys/vm/drop_caches
	echo "$thp_enabled" > /sys/kernel/mm/transparent_hugepage/enabled
}

function test_running()
{
	### running the C program to testing ###
	numa_node=`numactl -H | sed -n '2p' | cut -b 14-18 && numactl -H | sed -n '5p' | cut -b 14-18` 

	for i in $numa_node; do
		echo "LOGINFO: Start to run $ numactl --physcpubind=$i ./breakthp 1024 2048 4 60"
		numactl --physcpubind=$i ./breakthp 1024 2048 4 60  2&>1 > /dev/null &
	done

	echo "LOGINFO: sleeping 1..."
	sleep 1

	echo
	for i in $numa_node; do
		echo "LOGINFO: Start to run $numactl --physcpubind=$i ./usemem 1024 "
		numactl --physcpubind=$i ./usemem 1024  2&>1 > /dev/null &
	done
}

function check_the_output()
{
	### to check the numa-maps output ###
	echo
	echo "LOGINFO: Sleeping 5s to wait usemem"
	sleep 5

	echo "LOGINFO: The output of ./numa-maps -n usemem"
	./numa-maps -n usemem  | tee test_case_report.txt

	### to judge the data ###
	for i in `seq 2 7`; do

		N0=`awk '{print $6}' test_case_report.txt | sed -n ''$i'p'`

		if [[ "$N0" = "1.00G" ]]; then
			continue
		elif [[ "$N0" = "0" ]]; then
			continue
		else
			echo "FAIL: Test case failed."
			cleanup
			exit -1
		fi
	done

	echo "LOGINFO: Test case PASS!"
}

function main()
{
	setup_test_env
	test_running
	check_the_output
	cleanup

	return 0
}

main
