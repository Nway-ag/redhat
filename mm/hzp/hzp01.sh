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
#  #  This THP case measure the RSS size of test process memcmp01 on a system with
#  #  Huge Zero Page on/off. The size of rss_off is absolutely larger than 100*rss_on,
#  #  eg. x86_64, the rss_on is about 400K, the rss_off is about 200M.
#  #
#  #  Author: Li Wang <liwang@redhat.com>
#  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export TCID="hzp01"
export TST_TOTAL=5

. test.sh
. hzp_lib.sh

rss_off=-1
rss_on=-1

hzp_off_test()
{
	# Testing with use_zero_page disable
	hzp_off

	# Running the process in background
	$TPATH/memcmp01 & >/dev/null
	if [ $? -ne 0 ]; then
		tst_brkm TBROK "failed to run the process in background."
	fi

	sleep 2
	# Check the RSS size of test_memcmp01
	local pid=`pidof "$TPATH/memcmp01"`
	rss_off=`pmap -x $pid | grep total | awk '{print $4}'`
	tst_resm TINFO "rss_off= $rss_off K"

	# Kill the test process
	kill $pid >/dev/null
	if [ $? -ne 0 ]; then
		tst_brkm TBROK "failed to kill the process."
	fi
}

hzp_on_test()
{
	# Testing with use_zero_page enable
	hzp_on

	# Running the process in background
	$TPATH/memcmp01 & >/dev/null
	if [ $? -ne 0 ]; then
		tst_brkm TBROK "failed to run the process in background."
	fi

	sleep 2
	# Check the RSS size of test_memcmp01
	local pid=`pidof "$TPATH/memcmp01"`
	rss_on=`pmap -x $pid | grep total | awk '{print $4}'`
	tst_resm TINFO "rss_on= $rss_on K"

	kill $pid >/dev/null
	if [ $? -ne 0 ]; then
		tst_brkm TBROK "failed to kill the process."
	fi
}

rss_cmp()
{
	hzp_off_test
	hzp_on_test

	# eg. rss_on is about 400k, rss_off is about 200M (arch: x86_64),
	# so the size of rss_off should be absolutely lager than 100*rss_on
	test_success=`echo "$rss_off > 100*$rss_on" |bc`
	if [ $test_success -eq 1 ]; then
		tst_resm TPASS "Huge Zero Page works well."
	else
		tst_resm TFAIL "Huge Zero Page works bad."
	fi
}

#--------Test Start----------
hzp_setup

rss_cmp

hzp_cleanup

tst_exit
