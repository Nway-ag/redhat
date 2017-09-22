#!/bin/bash
# config testcase
# use that many fake file based swap devs (any swap dev work, but those are cross platform for sure)
swapdevs=8
# size in MB of each swap dev
swapdevsize=100
# size in mb of each allocation step
mbperalloc=10
# gap in MB to max free memory before going slow AND gap to max swap+ram overall
gaptomax=40


function stats {
	cat /proc/meminfo | egrep 'Sw|Mem'
	cat /proc/swaps
}


# Tests with swapfiles work on every platform
swapoff -a
for i in `seq 1 ${swapdevs}`
do
	dd if=/dev/zero of=/testswap${i} bs=10240 count=$((${swapdevsize}*100 + 1 ))
	mkswap /testswap${i}
	swapon -p $(( ${swapdevs} - ${i} + 1 )) /testswap${i}
done

rm -f memeat
gcc -O0 -xc -o memeat - << ENDCODE
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <syslog.h>
#include <string.h>

#define MEM_SIZE ${mbperalloc}*1024*1024

int main(void) {
   pid_t pid, sid;

   /* alloc and fault in before fork to wait for mem being touched */
   void *buffer = malloc(MEM_SIZE);
   if (buffer == NULL) {
         perror("Malloc failed (alloc_malloc)\n");
         exit(2);
   }
   memset(buffer,0,MEM_SIZE);

   pid = fork();
   if (pid < 0) {
           exit(EXIT_FAILURE);
   }
   if (pid > 0) {
           exit(EXIT_SUCCESS);
   }
   umask(0);
           
   sid = setsid();
   if (sid < 0) {
           /* Log the failure */
           exit(EXIT_FAILURE);
   }
   
   if ((chdir("/")) < 0) {
           exit(EXIT_FAILURE);
   }
   
   close(STDIN_FILENO);
   close(STDOUT_FILENO);
   close(STDERR_FILENO);
   
   while (1) {
      sleep(6000000);
   }
   exit(EXIT_SUCCESS);
}
ENDCODE

ls -laF memeat
if [[ $? -ne 0 ]]; then
	echo "Failed to build test program"
	exit 2;
fi
ldd memeat

sync
echo 3 > /proc/sys/vm/drop_caches
sleep 2s

echo "## Initial statistics ##"
stats

i=0;
echo "## do a fast start of the free until swapping ##"
#steps=$(($(cat /proc/meminfo | awk --assign mbperalloc=${mbperalloc} '/MemFree:/ {printf("%d",$2/1024/mbperalloc)}') - ${gaptomax} ))
until [[ `awk '/SwapFree:/ {printf("%d",$2)}' /proc/meminfo` -lt `awk '/SwapTotal:/ {printf("%d",$2)}' /proc/meminfo` ]]
do
	i=$(( ${i} + 1 ))
	printf "Fast start #%ld, " "${i}"
	./memeat
done
echo "Fast start done ($i steps), wait to let the system settle"
stats
sleep 10s

#steps=$((${swapdevs}*${swapdevsize}/${mbperalloc}))
echo "## now iterating in ${mbperalloc}m steps into swap ##"
stats

i=0
# stop when less than one dev is left
until [[ `awk '/SwapFree:/ {printf("%d",$2)}' /proc/meminfo` -lt `awk '/testswap1/ {print $3}' /proc/swaps` ]]
do
	i=$(( ${i} + 1 ))
	echo "Step ${i}"
	./memeat
	# give it some time to e.g. cleanup / bg-swap
	sleep 2s
	stats
done

echo "Final stats before cleanup"
stats

killall memeat
rm -f memeat
swapoff -a
for i in `seq 1 ${swapdevs}`
do
        rm -f /testswap${i}
done

