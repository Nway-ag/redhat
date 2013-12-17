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

### compile the C program ###
#wget -p $(pwd) https://...
#wget -p $(pwd) https://...

if [ -f breakthp.c ]; then
	if [ -f usemem.c ]; then
		gcc -o breakthp breakthp.c
		gcc -o usemem usemem.c
	fi
else
	echo "sorry,$(pwd)breakthp.c or $(pwd)usemem.c not exist."; 
fi

### set the env for testing ###
echo 1 >/proc/sys/vm/zone_reclaim_mode
echo 3 >/proc/sys/vm/drop_caches
echo never >/sys/kernel/mm/transparent_hugepage/enabled

### download the numa-code required ###
mkdir numa && cd numa 
git init && git clone https://code.google.com/p/numa-maps/
cp numa-maps/* ..
cd ..; rm -rf numa/

### running the C program to testing ###
for i in 0 1 2 5 15; do
	numactl --physcpubind=$i ./breakthp 1024 2048 4 60 > /dev/null  &
done

echo "sleeping 15..."
sleep 15

for i in 0 1 2 5 15; do
	numactl --physcpubind=$i ./usemem 1024 10 > /dev/null &
done

### to check the numa-maps output ###
sleep 3
touch test_case_report.txt
./numa-maps -n usemem  >> test_case_report.txt

### to judgement the data###
MEM=(awk '{print $4}' test_case_report.txt | sed -n '2p')
if [ $MEM -nq 1.00G } ]; then
	FAIL_COUNT=$((FAIL_COUNT + 1));
fi

### here print the result of cases ###
if [ $FAIL_COUNT -ne 0 ]; then
	echo "Failed: there are $FAIL_COUNT cases failed."
else
	echo "Success: Test PASS!"
fi

exit 0
