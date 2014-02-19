#!/bin/sh

for i in `seq 1 105`; do
	link=`cat bz726863_patch.txt | sed -n ''$i'p'`
	wget $link
	ls -l | awk '{print $9}' |wc

done
