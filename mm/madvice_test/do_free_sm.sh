#!/bin/bash
cat /proc/sysvipc/shm
for i in $(cat /proc/sysvipc/shm | grep 1073741824 | awk '{ print $2 }'); do ./free_sm.out $i; done
