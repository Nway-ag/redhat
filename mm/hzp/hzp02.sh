#!/bin/bash
#  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  #  Copyright (C) 2015 Linux Test Project.
#  #
#  #  Licensed under the GNU GPLv2 or later.
#  #  This program is free software;  you can redistribute it and/or modify
#  #  it under the terms of the GNU General Public License as published by
#  #  the Free Software Foundation; either version 2 of the License, or
#  #  (at your option) any later version.
#  #
#  #  This program is distributed in the hope that it will be useful,
#  #  but WITHOUT ANY WARRANTY;  without even the implied warranty of
#  #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
#  #  the GNU General Public License for more details.
#  #
#  #  You should have received a copy of the GNU General Public License
#  #  along with this program;  if not, write to the Free Software
#  #  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#  #
#  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  #  Description:
#  #
#  #  This case measure the time consumption of test program memcmp02 on
#  #  a system with Huge Zero Page on/off, then judge if the HZP performance
#  #  well or not from the results comparison.
#  #
#  #  Author: Li Wang <liwang@redhat.com>
#  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export TCID="hzp02"
export TST_TOTAL=5

. test.sh
. hzp_lib.sh

time_elapsed_off=-1
time_elapsed_on=-1

mem_total=`grep MemTotal: /proc/meminfo |awk '{print $2}'`
mem_free=`grep MemFree: /proc/meminfo |awk '{print $2}'`

tst_resm TINFO "mem_total= $mem_total kB, mem_free= $mem_free kB."

# Configure Memory testing size
if [ $mem_total -gt 16777216 ]; then
	MEM=10
elif [ $mem_total -gt 8388608 ]; then
	MEM=$(( $mem_free / 1024 / 1000 - 1 ))
elif [ $mem_total -gt 2097152 ]; then
	MEM=2
else
	tst_brkm TCONF "Sorry, the system RAM is too low to test."
fi

test_begin()
{
	# Testing with use_zero_page disable
	hzp_off
	(time -p taskset -c 0 $TPATH/memcmp02 $MEM) 2> memcmp_off.log
	time_elapse_off=`grep real memcmp_off.log|awk '{print $2}'`
	tst_resm TINFO "time_elapse_off= $time_elapse_off"

	# Testing with use_zero_page enable
	hzp_on
	(time -p taskset -c 0 $TPATH/memcmp02 $MEM) 2> memcmp_on.log
	time_elapse_on=`grep real memcmp_on.log|awk '{print $2}'`
	tst_resm TINFO "time_elapse_on= $time_elapse_on"
}

test_result()
{
	# Compare the time cosumption with HZP on/off
	test_success=`echo "$time_elapse_off > 2*$time_elapse_on" |bc`
	if [ $test_success -eq 1 ]; then
		tst_resm TPASS "Huge Zero Page performance well."
	else
		tst_resm TFAIL "Huge Zero Page performance bad."
	fi
}

#--------Test Start----------
hzp_setup

test_begin

test_result

hzp_cleanup

tst_exit
