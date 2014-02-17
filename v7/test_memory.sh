#!/bin/sh

# Copyright (c) 2011 Red Hat, Inc. All rights reserved. This copyrighted material 
# is made available to anyone wishing to use, modify, copy, or
# redistribute it subject to the terms and conditions of the GNU General
# Public License v.2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# Author: Zhouping Liu <zliu@redhat.com>
# Update: Li Wang <liwan@redhat.com>

SYS_VERSION=`cat /etc/redhat-release | cut -d ' ' -f 7 | cut -d '.' -f 1`
if [ -f /etc/yum.repos.d/v7.repo ]; then
	echo "the system has already v7 repo"
else
	cat << EOF > /etc/yum.repos.d/v7.repo
[hwcer-client]
name=hwcert-client
baseurl=http://qafiler.bos.redhat.com/testkits/V7/RHEL${SYS_VERSION}
enabled=1
gpgcheck=0
EOF
fi

rpm -q hwcert-client
if [ $? -ne 0 ]; then
	yum makecache
	yum install -y hwcert-client-*.el6.noarch
fi

# We can set the REPEAT_NUMS variable to specify how many times
# the command 'hwcert-backend run --test=memory' run.
NUM=1
if [ "CHK"${REPEAT_NUMS} != "CHK" ]; then
	while [ ${REPEAT_NUMS} -gt 0 ]; do
		echo "the ${NUM}th run 'hwcert-backend run --test=memory --mode=auto' command"
		hwcert-backend run --test=memory --mode=auto
		if [ $? -ne 0 ]; then
			echo "FAIL: Test memory using hwcert-client test suite failed"
			exit -1
		fi

		echo y | hwcert clean
		REPEAT_NUMS=$((REPEAT_NUMS-1))
		NUM=$((NUM+1))
	done
else
	REPEAT_NUMS=`numactl -H | awk '{print $2}' | sed -n '1p'`
        while [ ${REPEAT_NUMS} -gt 0 ]; do
		echo "the ${NUM}th run 'hwcert-backend run --test=memory --mode=auto' command"
                hwcert-backend run --test=memory --mode=auto
		if [ $? -ne 0 ]; then
			echo "FAIL: Test memory using hwcert-client test suite failed"
			exit -1
		fi

		echo y | hwcert clean
                REPEAT_NUMS=$((REPEAT_NUMS-1)) 
		NUM=$((NUM+1))
        done
fi

echo "PASS: Test memory using hwcert-client test suite successed!"
