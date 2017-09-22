#!/bin/bash
#
# Description: kpatch setup bare mental
# Author: Li Wang <liwang@redhat.com>
# ---------------------------------------

set -o pipefail

ARCH=$(uname -m)
KVRX=$(uname -r | cut -f1 -d-)
KVRY=$(uname -r | cut -f2 -d- | sed "s/.${ARCH}//")

function __kpatch_build()
{
	local RC=0

	rpm -q kpatch;
	if [ $? -eq 0 ]; then
		echo "kpatch has been installed.";
		return $RC;
	fi

	echo "kpatch building & installing..."
	wget -q https://github.com/dynup/kpatch/archive/v0.2.2.tar.gz;
	tar xvf v0.2.2.tar.gz 2>&1 >/dev/null;
	pushd  kpatch-0.2.2;
	make 2>&1 >/dev/null && make install 2>&1 >/dev/null	 || RC=1
	popd;

	if [ $RC -ne 0 ]; then
		echo "package build/install fail, please try again.";
		return $RC;
	fi
}

function kpatch_pre()
{
	local RC=0

	echo "  "
	yum -y install gcc kernel-devel elfutils elfutils-devel   || RC=1

	echo "  "
	yum-config-manager --enable rhel-7-server-optional-rpms   || RC=1
	
	echo "  "
	yum install -y rpmdevtools pesign yum-utils zlib-devel \
		binutils-devel newt-devel python-devel \
		perl-ExtUtils-Embed  audit-libs-devel \
		numactl-devel pciutils-devel bison ncurses-devel  || RC=1

	# config ccache
	echo "  "
	rpm -q ccache;
	[ $? -eq 0 ] || yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/c/ccache-3.1.9-3.el7.x86_64.rpm;
	ccache --max-size=5G	|| RC=1

	echo "  "
	__kpatch_build		|| RC=1

	# fetch the kernel-src
	echo "  "
	echo "fetching the kernel source code..."
	wget http://download.eng.bos.redhat.com/brewroot/packages/kernel/$KVRX/$KVRY/src/kernel-$KVRX-$KVRY.src.rpm
	yum-builddep -y kernel-$KVRX-$KVRY.src.rpm	|| RC=1
	echo "  "
	debuginfo-install kernel			|| RC=1

	if [ $RC -ne 0 ]; then
		echo "package install fail, please try again.";
		exit $RC;
	fi
}

# ----- start ------
kpatch_pre

kpatch-build -r kernel-$KVRX-$KVRY.src.rpm -t vmlinux  $1 --skip-gcc-check
