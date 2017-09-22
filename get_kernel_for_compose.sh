#!/bin/bash

# This scripts helps with identifying kernel available in distro specified as
# first argument. Script also keeps simple cache of queried data so that it can
# reuse them again or even offline, the cache is stored in ~/distro_kernel_table
# The script looks both in rel-eng and released directories
#
# Example:
# ./get_kernel_for_compose.sh RHEL-6.6




# FIXME: choose closest download
# WARNING: keep the exact url as this differs between labs

#download="http://download.eng.bos.redhat.com/"
#download="http://download.eng.rdu.redhat.com/"
#download="http://download.eng.nay.redhat.com/pub/rhel/"
#download="http://download.eng.pnq.redhat.com/pub/rhel/"
#download="http://download.eng.blr.redhat.com/pub/rhel/"
download="http://download.eng.brq.redhat.com/pub/rhel/"

get_kernel_from_metadata()
{
    wget -q -O /tmp/repomd.xml $1/repodata/repomd.xml
    rc=$?
    [ $rc -eq 4 ] && echo "Exiting wget($rc)" >&2 && rm -f /tmp/repomd.xml && return
    [ $rc -eq 8 ] && echo "Skipping wget($rc)" >&2 && rm -f /tmp/repomd.xml && return

    primary=`xmllint --xpath "string(/*[local-name()='repomd']/*[local-name()='data'][@type='primary']/*[local-name()='location']/@href)" /tmp/repomd.xml`

    wget -q -O /tmp/primary.xml.gz $1/$primary
    rc=$?
    [ $rc -eq 4 ] && echo "Exiting wget($rc)" >&2 && rm -f /tmp/primary.xml.gz && return
    [ $rc -eq 8 ] && echo "Skipping wget($rc)" >&2 && rm -f /tmp/primary.xml.gz && return

    gunzip /tmp/primary.xml.gz

    kernel_ver=`xmllint --xpath "string(/*[local-name()='metadata']/*[local-name()='package']/*[local-name()='name'][text()='kernel']/parent::node()/*[local-name()='version']/@ver)" /tmp/primary.xml`
    kernel_rel=`xmllint --xpath "string(/*[local-name()='metadata']/*[local-name()='package']/*[local-name()='name'][text()='kernel']/parent::node()/*[local-name()='version']/@rel)" /tmp/primary.xml`

    rm -f /tmp/primary.xml.gz

    if [ -n "$kernel_ver" ]; then
        kernel="$kernel_ver-$kernel_rel"
        echo $kernel
    fi
}

echo "Checking distro $1" >&2

# check cached stuff
kernel=`sed -n "s/$1 \(.*\)/\1/p" ~/distro_kernel_table`

if [ -n "$kernel" ]; then
    echo "$kernel"
    exit
fi

rm -f /tmp/repomd.xml
rm -f /tmp/primary.xml
rm -f /tmp/primary.xml.gz

echo "Trying rel-eng trees ..." >&2

# rel-eng directories
# RHEL7: http://download.eng.brq.redhat.com/pub/rhel/rel-eng/RHEL-7.1-20141204.2/compose/Server/x86_64/os/
# RHEL6: http://download.eng.brq.redhat.com/pub/rhel/rel-eng/RHEL-6.7-20150304.0/6/Server/x86_64/os/

distro_base=`echo $1 | sed 's/RHEL-\([0-9]\)\.[0-9].*/\1/'`

echo "Distro base: $distro_base" >&2

if [ $distro_base -eq 6 ]; then
    compose_path="6/Server/x86_64/os/"
elif [ $distro_base -eq 7 ]; then
    compose_path="compose/Server/x86_64/os/"
else
    echo "Don't know distro base $distro_base"
    exit 1
fi

base_url="$download/rel-eng/$1/$compose_path/"

kernel=`get_kernel_from_metadata $base_url`

if [ -n "$kernel" ]; then
    echo "$kernel"
    # save in the cache
    echo "$1 $kernel" >> ~/distro_kernel_table
    exit
fi

echo "Could not get kernel version in rel-eng, trying released ..." >&2

# released directories ...
# http://download.eng.brq.redhat.com/pub/rhel/released/RHEL-6/6.6/Server/x86_64/os/repodata/
# http://download.eng.brq.redhat.com/pub/rhel/released/RHEL-7/7.1/Server/x86_64/os/repodata/

distro_version=`echo $1 | cut -f2 -d-`

if [ $distro_base -eq 6 -o $distro_base -eq 7 ]; then
    compose_path="RHEL-$distro_base/$distro_version/Server/x86_64/os/"
else
    echo "Don't know distro base $distro_base"
    exit 1
fi

base_url="$download/released/$compose_path"

kernel=`get_kernel_from_metadata $base_url`

if [ -n "$kernel" ]; then
    echo "$kernel"
    # save in the cache
    echo "$1 $kernel" >> ~/distro_kernel_table
    exit
else
    echo "Could not find even in /released, exiting" >&2
    exit 1
fi

