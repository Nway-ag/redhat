#!/bin/bash
#filename: checkword.sh

word=$1
grep "^$1$" /usr/share/dict/american-english -q
if [ $? -eq 0 ];then
	echo $word is a dictionary word;
else
	echo $word is not a dictionary word;
fi
