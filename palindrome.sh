#!/bin/bash

string="$1"
if [[ "$string" == "$(echo $string | rev)" ]];
then
	echo "Palindrome"
else
	echo "Not Palindrome"
fi
