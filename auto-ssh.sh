#!/bin/bash
# ------------------------------------
# A simple tool for quick login system
# Usage: ./autoshell.sh  your-hostname
# ------------------------------------

HOST=$1

case ${HOST} in
	# my workstation
	wangli) ssh -l wangli 10.66.12.104;;
	
	# openstack system 
	fedora) ssh -l fedora 10.3.13.202;;

	# raspberry pi3
	pi) ssh -l root 10.66.13.219;;

	# kg-team data server psswd: redhat
	kg) ssh -l kernelqe ibm-x3250m4-03.rhts.eng.pek2.redhat.com;;
esac
