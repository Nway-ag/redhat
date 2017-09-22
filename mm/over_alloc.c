#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#define GB 1024*1024*1024

int main(int argc, char *argv[])
{
	char **p;
	int i;
	int N = 0;

	if(argc != 2) {
		printf("Usage: ./malloc N\n");
		return -1;
	}
	N = atoi(argv[1]);

	printf("you are try to alloc %dGb memory...\n", N);
	p = (char **)malloc(N * sizeof(char *));
	for(i = 0; i < N; i++) {
		p[i] = (char *)malloc(GB);
		if(p[i] == NULL) {
			perror("Warning");
			return -1;
		}
		memset(p[i], 1, GB);
	}
	printf("malloc successfully\n");
	free(p);
	return 0;
}
