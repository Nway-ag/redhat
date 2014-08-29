#!/bin/bash -x

large_file=ltp-full-20140828.bz2   ## the name of the file you want to copy
lookaside_cache=~/Development/lookaside  ## or any other suitable path
mkdir -p  $lookaside_cache
sshfs liwan@file.bos.redhat.com:/export/engineering_qa/rhts/lookaside $lookaside_cache  ## assuming your local user name matches your Red Hat login
## wait until the cache is mounted; note that you need not enter your Red Hat password if you have a valid Kerberos ticket

#cd $lookaside_cache
#rm -fr $large_file 
#echo $?
#ls -l $lookaside_cache |grep ltp-full
cp $large_file $lookaside_cache
sleep 15
#ls -l $lookaside_cache |grep ltp-full
fusermount -u $lookaside_cache
