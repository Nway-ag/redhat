#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

#define  PAGE_SIZE  (size_t)4096

main(int argc, char *argv[])
{
	char *buf;
	int i, npages;

	npages = atoi(argv[1]);
	if (npages < 1) {
		printf("invalid argument\n");
		_exit(1);
	}

	buf = (char *)malloc((size_t)npages * PAGE_SIZE);
	if (buf == NULL) {
		printf("malloc failed\n");
		_exit(1);
	}

	while (1) {
		for (i = 0; i < npages; i++)
			buf[(i * PAGE_SIZE)] = '*';
	}
}
