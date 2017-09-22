/*
 * This program is just using for memory allocate.
 * e.g. `./malloc 1024`
 */

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

#define MB_1 (1024*1024)
#define GB_1 (1024*MB_1)

int main(int argc, char *argv[])
{
	char *str=NULL;
	int N = atoi(argv[1]);

	str = (char *)malloc(N*MB_1);
	if(str == NULL)
	{
		printf("Malloc failed.\n");
	}else{
		printf("Allocated %d M memorys.\n",N);
	}

	free(str);

	return 0;	
}

