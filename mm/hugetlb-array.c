/*
 * This program use Huge TLB is by using special shared memeory region.
 *
 * Usage:
 * 	1. echo 4 >/proc/sys/vm/nr_hugepages 
 * 	2. gcc hugetlb-array.c -o hugetlb-array -Wall
 * 	3. ./hugetlb-array
 * 	4. cat /proc/meminfo |grep -i huge
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdlib.h>

#define KB (1<<10L)
#define MB (1<<20L)
#define SIZE (8*MB)

#if __i386__ || __x86_64__
#define PAGE_SIZE (4 * KB)
#define HPAGE_SIZE (2 * MB)

#elif __powerpc__ || __powerpc64__
#define PAGE_SIZE (64 * KB)
#define HPAGE_SIZE (16 * MB)

#elif __s390__ || __s390x__
#define PAGE_SIZE (4 * KB)
#define HPAGE_SIZE (1 * MB)

#else
#define PAGE_SIZE (4 * KB)
#define HPAGE_SIZE (2 * MB)
#endif

char  *a;
int shmid1;

void init_hugetlb_seg()
{
	shmid1 = shmget(2, SIZE, SHM_HUGETLB | IPC_CREAT | SHM_R | SHM_W);
				/*^^^^^^^^^^*/
	if ( shmid1 < 0 ) {
		perror("shmget");
		exit(1);
	}
	printf("HugeTLB shmid: 0x%x\n", shmid1);
	a = shmat(shmid1, 0, 0);
	if (a == (char *)-1) {
		perror("Shared memory attach failure");
		shmctl(shmid1, IPC_RMID, NULL);
		exit(2);
	}
}

void wr_to_array()
{
	int i;
	for( i=0 ; i<SIZE ; i++) {
		a[i] = 'A';
	}
}

void rd_from_array()
{
	int i, count = 0;
	for( i=0 ; i<SIZE ; i++)
		if (a[i] == 'A') count++;
	if (count==i)
		printf("HugeTLB read success! :-)\n");
	else
		printf("HugeTLB read failed :-(\n");
}

int main(int argc, char *argv[])
{
	printf("-------------------------------\n");
	system("grep Huge /proc/meminfo");
	printf("-------------------------------\n");
	printf("Press any key to HugeTLB initialize...\n");
	getchar();

	init_hugetlb_seg();
	printf("HugeTLB memory segment initialized !\n");
	printf("-------------------------------\n");
	system("grep Huge /proc/meminfo");
	printf("-------------------------------\n\n");

	printf("Press any key to write to memory area...\n");
	getchar();
	wr_to_array();
	printf("-------------------------------\n");
	system("grep Huge /proc/meminfo");
	printf("-------------------------------\n\n");

	printf("Press any key to rd from memory area\n");
	getchar();
	rd_from_array();
	printf("-------------------------------\n");
	system("grep Huge /proc/meminfo");
	printf("-------------------------------\n\n");

	shmctl(shmid1, IPC_RMID, NULL);

	return 0;
}
