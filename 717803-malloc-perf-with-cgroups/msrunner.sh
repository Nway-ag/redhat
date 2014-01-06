#!/bin/bash -x
cpus=`cat /proc/cpuinfo | grep "processor" | sort -u | wc -l`
for i in `seq 1 $cpus`; do
        ./malloc_seq -s 1024 -n 1000&
done;

wait
