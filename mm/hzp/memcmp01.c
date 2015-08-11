/*
 * Copyright (C) 2015 Linux Test Project.
 *
 * Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
 * Modify: Li Wang <liwang@redhat.com>
 *
 */

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>

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

int main(void)
{
	char *p;
	unsigned long i;
	int HPAGE_SISE;
	int ret;

	HPAGE_SIZE = read_hugepagesize();

	ret = posix_memalign((void **)&p, HPAGE_SIZE, 100 * HPAGE_SIZE);
	if (ret) {
		fprintf(stderr, "posix_memalign: %s\n",
				strerror(ret));
		return -1;
	}

	for (i = 0; i < 100 * HPAGE_SIZE; i += 4096)
		assert(p[i] == 0);
	pause();
	return 0;
}
