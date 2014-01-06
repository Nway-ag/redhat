#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Author: Zhiyou Liu <zhiliu@redhat.com>
#   Update: Li Wang <liwan@redhat.com>
#   Description: Bug 817719 - tmpfs: fix races around umount, swapoff, truncate & writepage
#   Notes: Make sure libcgroup installed first, if there is something wrong with `service cgconfig start` failed
#          please check SELinux or disable selinux by `echo 0 > /selinux/enforce`
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2010 Red Hat, Inc. All rights reserved.
#
#   RedHat Internal.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/lib/beakerlib/beakerlib.sh


# Source the common test script helpers
. /usr/bin/rhts_environment.sh


calctime()
{
    costlist=$(grep "Time for Allocating Buffers" "$1"|awk '{print $6}')
    runtime=0
    for cost in $costlist; do
        runtime=$(echo "$runtime + $cost"|bc)
    done
}

# ---------- Start Test -------------

rlJournalStart
    rlPhaseStartSetup
        echo "- Setup cgroups"
        rlRun 'echo y | yum install libcgroup' 0 'install libcgroup'
        rlRun 'restorecon -v /etc/cgconfig.conf' 0 'restore the correct SELinux labels for each of the files'
        rlRun 'service cgconfig restart' 0 'Start cgconfig'
        rlRun 'mkdir /cgroup/memory/1' 0 'Create new memory cgroup'
        rlRun 'gcc -o malloc_seq malloc_seq.c -lrt' 0 'Build reproducer'
    rlPhaseEnd
    rlPhaseStartTest
        rlLogInfo "- Without cgroups"
        ./msrunner.sh > without-cgroup.log
        rlFileSubmit without-cgroup.log
        calctime "without-cgroup.log"
        without_cgroup_time=$runtime
        rlLogInfo "- Within cgroups"
        echo $$ > /cgroup/memory/1/tasks
        ./msrunner.sh > within-cgroup.log
        rlFileSubmit within-cgroup.log
        calctime "within-cgroup.log"
        within_cgroup_time=$runtime
        rlLogInfo "Within cgroup cost: $within_cgroup_time sec"
        rlLogInfo "Without cgroup cost: $without_cgroup_time sec"
        rlAssert0 $(echo "$within_cgroup_time > $without_cgroup_time * 2" |bc)
    rlPhaseEnd
    rlPhaseStartCleanup
        rlRun 'echo $$> /cgroup/memory/tasks' 0 'Exiting memory cgroup'
    rlPhaseEnd
rlJournalEnd
