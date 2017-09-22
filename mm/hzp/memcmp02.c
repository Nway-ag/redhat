/*
 * Copyright (C) 2015 Linux Test Project.
 *
 * Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
 * Modify: Li Wang <liwang@redhat.com>
 *
 */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define MB	(1UL << 20)
#define GB	(1UL << 30)

static int read_hugepagesize(void)
{
	FILE *fp;
	char line[BUFSIZ], buf[BUFSIZ];
	int val;

	fp = SAFE_FOPEN(cleanup, PATH_MEMINFO, "r");
	while (fgets(line, BUFSIZ, fp) != NULL) {
		if (sscanf(line, "%64s %d", buf, &val) == 2)
			if (strcmp(buf, "Hugepagesize:") == 0) {
				SAFE_FCLOSE(cleanup, fp);
				return 1024 * val;
			}
	}

	SAFE_FCLOSE(cleanup, fp);
	tst_brkm(TBROK, NULL, "can't find \"%s\" in %s",
			"Hugepagesize:", PATH_MEMINFO);
}

int main(int argc, char **argv)
{
	char *p;
	int i, ret;
	int N = atoi(argv[1]);

	if (N < 1) {
		fprintf(stderr, "Invalid argument\n");
		exit(1);
	}

	HPAGE_SIZE = read_hugepagesize();

	ret = posix_memalign((void **)&p, HPAGE_SIZE, N * GB);
	if (ret) {
		fprintf(stderr, "posix_memalign: %s\n",
				strerror(ret));
		return -1;
	}

	for (i = 0; i < 1000; i++) {
		char *_p = p;

		while (_p < p+N/2*GB) {
			assert(*_p == *(_p+N/2*GB));
			_p += 4096;
			asm volatile ("" : : : "memory");
		}
	}

	free(p);

	return 0;
}
