#!/bin/sh

#download all the patches 
for i in `seq 1 105`; do
	patch_link="`cat bz726863_patch_links.txt | sed -n ''$i'p' | awk '{print $3}'`/raw"
	wget -P ./download_patch $patch_link
done

#pick up the keywords
cd download_patch;
for i in `seq 2 105`; do  #attention!!!
	patch=`ls -l | sed -n ''$i'p' | awk '{print $9}'`
	
	value=`cat $patch | grep '+' | grep "ppc64" -c`
	if [ $value -ge 1 ];then
		cat $patch | grep '+' | sed -n '3p' | awk '{print $2}' >> ../abi_ppc64.txt
	fi

	value=`cat $patch | grep '+' | grep "s390x" -c`
	if [ $value -ge 1 ];then
		cat $patch | grep '+' | sed -n '3p' | awk '{print $2}' >> ../abi_s390x.txt
	fi

	value=`cat $patch | grep '+' | grep "x86_64" -c`
	if [ $value -ge 1 ];then
		cat $patch | grep '+' | sed -n '3p' | awk '{print $2}' >> ../abi_x86_64.txt
	fi

done
