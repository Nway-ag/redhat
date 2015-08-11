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
#  #  Author: Li Wang <liwang@redhat.com>
#  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export TCID="hzp03"
export TST_TOTAL=1

. test.sh
. hzp_lib.sh

MAX_LOOP=2000
RC=0

hzp_stress_test()
{
	for ((i = 0; i < $MAX_LOOP; i++))
	{
		hzp_on || RC=$?
		hzp_off || RC=$?
	}

	if [ $RC -eq 0 ]; then
		tst_resm TPASS "finished running the stress test."
	else
		tst_resm TFAIL "please check log message."
	fi
}

#--------Test Start----------
hzp_setup

hzp_stress_test

hzp_cleanup

tst_exit
