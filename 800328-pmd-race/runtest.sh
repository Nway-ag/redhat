#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /kernel/vm/regression/800328-pmd-race
#   Description: Bug 800328 - CVE-2012-1179 kernel: thp:__split_huge_page() mapcount != page_mapcount BUG_ON() [rhel-6.3]
#   Author: Zhiyou Liu <zhiliu@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh

REBOOT_TAG="GOT_HERE_WE_REBOOTED"
FILES='do_race_panic.c do_race_2_panic.c'
duration="60m"
rlJournalStart
    rlPhaseStartSetup
        if [ -f "$REBOOT_TAG" ]; then
            rlFileSubmit "/var/log/dmesg"
            for msgfile in `ls /var/log/messages*`; do
                rlFileSubmit $msgfile
            done
            rlReport "Test" FAIL 1000
            rlLogFatal "rebooted when running test, crashed"
            rlDie "rebooted when running test, crashed"
        fi
        touch ${REBOOT_TAG}

        param=$(free -m |awk '{if (NR==2) print int($4/2/1.5)}')
        rlRun -t 'free -m'
        rlLogInfo "param: $param"
        for file in $FILES; do
            sed "s/@param/$param/" $file >$file.sed.c
            rlRun -t 'grep "#define  MEM_ALLOC_SIZE" $file.sed.c'
            gcc -o $file.run -lpthread $file.sed.c
        done
    rlPhaseEnd

    rlPhaseStart FAIL "Try to make a panic"
        rlRun -t 'timeout $duration ./make-crash.sh' 124 "running $duration time for making a crash"
        # Usually the make-crash will make a panic, but we can do further check to make sure there is not `pmd bad`
        rlRun 'dmesg| grep -q "bad pmd"' 1 "Check \`pmd bad\` message"
    rlPhaseEnd

    rlPhaseStartCleanup
        rm -f $REBOOT_TAG
        rlFileSubmit "/var/log/dmesg"
        for msgfile in `ls /var/log/messages*`; do
            rlFileSubmit $msgfile
        done
    rlPhaseEnd
rlJournalEnd
