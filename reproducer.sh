#!/bin/sh -x
while ! mount -o loop SERVER_task.img /mnt/task
	do sleep 1
	done
