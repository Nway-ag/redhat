#!/bin/bash
#  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

trap tst_exit INT

export TPATH="$PWD"
export THP_ENABLED="/sys/kernel/mm/transparent_hugepage/enabled"
export USE_ZERO_PAGE="/sys/kernel/mm/transparent_hugepage/use_zero_page"

hzp=-1

hzp_on()
{
	echo 1 >$USE_ZERO_PAGE
	if [ $? -ne 0 ]; then
		tst_brkm TBROK "turn on hzp failed."
	fi
}

hzp_off()
{
	echo 0 >$USE_ZERO_PAGE
	if [ $? -ne 0 ]; then
		tst_brkm TBROK "turn off hzp failed."
	fi
}

hzp_setup()
{
	tst_require_root

	# Check to see huge zero page feature is supported or not
	if [ ! -f $USE_ZERO_PAGE ];then
		tst_brkm TCONF "The huge zero page is not supported. Skip the test..."
	fi

	echo always >$THP_ENABLED
	if [ $? -ne 0 ]; then
		tst_brkm TBROK "Enable the THP option failed."
	fi

	# Save the original value of $USE_ZERO_PAGE
	hzp=`cat $USE_ZERO_PAGE`

	tst_tmpdir
}

hzp_cleanup()
{
	tst_resm TINFO "hzp cleanup."

	# Reset the $USE_ZERO_PAGE to original value
	echo $hzp >$USE_ZERO_PAGE
	rm -f *.log

	tst_rmdir
}
