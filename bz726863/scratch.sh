#!/bin/sh

for i in `seq 1 105`; do
	link="`cat bz726863_patch_links.txt | sed -n ''$i'p' | awk '{print $3}'`/raw"
	wget -P ./download_patch $link
#	ls -l | awk '{print $9}' |wc
done


cd download_patch;
for i in `seq 2 105`; do
	patch=`ls -l | sed -n ''$i'p' | awk '{print $9}'`
	cat $patch | grep '+'
	
	if [grep "x86_64" -eq " "];then
		cat $patch | grep '+' | sed -n '3p' | awk '{print $2}' >> ../abi_x86_64.txt
	fi

done
