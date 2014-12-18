#include <stdio.h>
#include <malloc.h>

int main(void)
{
	void *m;
	int i;

	printf("Allocation VIRT memory\n");
	printf("top shows a questionmark for VIRT when it is larger than 8TB\n");

	for(i=0; i<200; i++) {
		m=malloc(1L*50*1024*1024*1024);
		printf("malloc returned %p\n",m);
		if(i>161) {
			printf("press return to for next allocation\n");
			getchar();
		}
	}
}
