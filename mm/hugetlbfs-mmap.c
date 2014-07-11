/*
 * This program use private Huge TLB mapping. The primer method is by mmaping files from the hugetlb filesystem.
 *
 * Usage:
 *	1. mkdir -p /mnt/huge
 * 	2. mount none /mnt/huge -t hugetlbfs
 * 	3. gcc -o hugetlbfs-mmap hugetlbfs-mmap.c
 * 	4. ./hugetlbfs-mmap
 *
 */

#include <fcntl.h> 
#include <stdio.h>
#include <sys/mman.h> 
#include <errno.h> 

#define MAP_LENGTH      (2*1024*1024) 

int main() 
{ 
	int fd; 
	char * addr; 
	int i, j, count=0;

	/* create a file in hugetlb fs */ 
	fd = open("/mnt/huge/test", O_CREAT | O_RDWR); 
	if(fd < 0){ 
		perror("Err: "); 
		return -1; 
	}   

	/* map the file into address space of current application process */ 
	addr = mmap(0, MAP_LENGTH, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0); 
	if(addr == MAP_FAILED){ 
		perror("Err: "); 
		close(fd); 
		unlink("/mnt/huge/test"); 
		return -1; 
	}   

	/* from now on, you can store application data on huage pages via addr */ 
	for(i = 0; i < MAP_LENGTH; i++){
		addr[i] = 'A';
	}

	for(j = 0; j < MAP_LENGTH; j++)
		if(addr[j] == 'A') count++;

	if(count == j)
		printf("hugetlbfs read sucess.\n");
	else
		printf("hugetlbfs read failed.\n");
	/******************************************/

	munmap(addr, MAP_LENGTH); 
	close(fd); 
	unlink("/mnt/huge/test"); 
	return 0; 
}
