#!/bin/bash
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# #
# #   test_case_953225.sh of /kernel/memory/bug_953225
# #   Description: common test for netconsole
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
FAIL_COUNT=0

function compile_tools()
{
	### compile the C program ###
	if [ -f breakthp.c ]; then
		if [ -f usemem.c ]; then
			gcc -o breakthp breakthp.c
			gcc -o usemem usemem.c
		fi
	else
		echo "sorry,$(pwd)breakthp.c or $(pwd)usemem.c not exist."; 
	fi
}

function setup_test_env()
{
	compile_tools

	### set the env for testing ###
	echo 1 >/proc/sys/vm/zone_reclaim_mode
	echo 3 >/proc/sys/vm/drop_caches
	echo never >/sys/kernel/mm/transparent_hugepage/enabled
}

function test_running()
{
	### running the C program to testing ###
	numa_node=`numactl -H | sed -n '2p' | cut -b 14-18 && numactl -H | sed -n '5p' | cut -b 14-18` 
	for i in $numa_node; do
		numactl --physcpubind=$i ./breakthp 1024 2048 4 60   &
	done

	echo "sleeping 1..."
	sleep 1

	for i in $numa_node; do
		numactl --physcpubind=$i ./usemem 1024 10  &
	done
}

function check_the_output()
{
	### to check the numa-maps output ###
	sleep 3
	./numa-maps -n usemem  > test_case_report.txt

	### to judge the data ###
	for i in 2 3 4 5 6; do

		N0=`awk '{print $6}' test_case_report.txt | sed -n ''$i'p'`

		if [ "$N0" = "1.00G" ]; then
			FAIL_COUNT=$((FAIL_COUNT + 1));
		else
			if [ "$N0" = "0" ]; then
				FAIL_COUNT=$((FAIL_COUNT + 1));
			fi
		fi
	done

	### here print the result of cases ###
	if [ $FAIL_COUNT -ne 5 ]; then
		echo "Failed:FAIL_COUNT is/are: $FAIL_COUNT, cases failed."
	else
		echo "Success: Test Pass!"

	fi
}

function main()
{
	setup_test_env
	test_running
	check_the_output

	return 0
}

main
