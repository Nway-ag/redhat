#!/bin/bash
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copyright (C) 2015 Linux Test Project.
#
# Licensed under the GNU GPLv2 or later.
# This program is free software;  you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY;  without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
# the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program;  if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description:
#
# This case measure the time consumption of test_memcmp process on 
# a system with Huge Zero Page on/off, then judge if the HZP function 
# well or not from the results comparison.
#
# Author: Li Wang <liwang@redhat.com>
# Reference: http://lwn.net/Articles/525301/
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#######cd $LTPROOT/testcases/bin

export TCID=huge_zero_page_test
export TST_TOTAL=1
export TST_COUNT=1

. test.sh

#######export TPATH="$PWD"
export DROP_CACHES="/proc/sys/vm/drop_caches"
export THP_ENABLED="/sys/kernel/mm/transparent_hugepage/enabled"
export USE_ZERO_PAGE="/sys/kernel/mm/transparent_hugepage/use_zero_page"

time_elapsed0=
time_elapsed1=
drop_caches=`cat $DROP_CACHES`
mem_total=`grep MemTotal: /proc/meminfo |awk '{print $2}'`
hzp=

# Testing value config
echo "mem_total= $mem_total kB"

if [ $mem_total -gt 16777216 ]; then 
{	MEM=10
	NUM=3
} elif [ $mem_total -gt 8388608 ]; then 
{	MEM=8
	NUM=3
} elif [ $MEM_TOTAL -gt 4194304 ]; then
{
	MEM=4
	NUM=3
} elif [ $MEM_TOTAL -gt 2097152 ]; then
{
	MEM=2
	NUM=3
} else {
	tst_brkm TCONF ignored "Sorry, the system RAM is too low to test."
}
fi

test_setup()
{
	tst_require_root

	tst_tmpdir

	# Check to see huge zero page feature is supported or not
	if [ ! -f $USE_ZERO_PAGE ];then
		tst_brkm TCONF ignored "The huge zero page is not supported. Skip the test..."
	fi

	hzp=`cat $USE_ZERO_PAGE`
	echo always >$THP_ENABLED
	echo 3 >$DROP_CACHES
}

test_cleanup()
{
	echo $hzp >$USE_ZERO_PAGE
	echo $drop_caches >$DROP_CACHES
	rm -fr *.log *~
	tst_rmdir
}

test_begin()
{
	# testing with use_zero_page disable
	echo 0 >$USE_ZERO_PAGE
	(time -p taskset -c 0 ./test_memcmp $MEM) 2> memcmp0.log
	time_elapse0=`grep real memcmp0.log|awk '{print $2}'`	
	echo "time_elapse0= $time_elapse0"

	# testing with use_zero_page enable
	echo 1 >$USE_ZERO_PAGE
	(time -p taskset -c 0 ./test_memcmp $MEM) 2> memcmp1.log
	time_elapse1=`grep real memcmp1.log|awk '{print $2}'`	
	echo "time_elapse1= $time_elapse1"
}

test_result()
{
	# compare the time cosumption with HZP on/off
	test_success=`echo "$time_elapse0 > $NUM*$time_elapse1" |bc`
	if [ $test_success -eq 1 ]; then
		tst_resm TPASS "Huge Zero Page works well."
	else
		tst_resm TFAIL "Huge Zero Page works bad."
	fi
}


#--------Test Start----------
test_setup

test_begin

test_result

test_cleanup
