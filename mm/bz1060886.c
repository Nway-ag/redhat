/*
 * bz1060886.c - helper to reproduce bug 1060886
 * gcc -Wall -o bz1060886 bz1060886.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>
#include <errno.h>
#include <sys/mman.h>

#define MB	(1UL << 20)
#define BALLOONMAP_RATIO 90
#define BALLOON_SIZE(v) (100 * v / BALLOONMAP_RATIO)

static inline void read_bytes(unsigned long length, void *addr)
{
	unsigned long i;
	unsigned char tmp;
	for (i = 0; i < length; i++)
		tmp += *((unsigned char *)(addr + i));
}

static inline void write_bytes(unsigned long length, void *addr)
{
	unsigned long i;
	for (i = 0; i < length; i++)
		*((unsigned char *)(addr + i)) = 0xff;
}

const char *prg_name;
const char *short_opts = "hs:";
const struct option long_opts[] = {
		{"help", 0, NULL, 'h'},
		{"size", 1, NULL, 's'},
		{NULL, 0, NULL, 0} } ;

void print_usage(FILE *stream, int exit_code)
{
	fprintf(stream, "Usage: %s <options>\n", prg_name);
	fprintf(stream,
		"   -h  --help     (Display this usage information)\n"
		"   -s  --size     <MB>\n");
	exit(exit_code);
}

static inline void *balloon_inflate(unsigned long len)
{
	void *addr = mmap(NULL, len, PROT_READ | PROT_WRITE,
			  MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
	if (addr == MAP_FAILED) {
		perror("mmap");
		abort();
	}
	write_bytes(len, addr);
	return addr;
}

int main(int argc, char *argv[])
{
	void *addr, *shm, *block;
	int errno, next_opt;
	size_t length = 0;

	prg_name = argv[0];
	do {
		next_opt = getopt_long(argc, argv, short_opts, long_opts, NULL);
		switch (next_opt) {
		case 's':
			length = atoi(optarg) * MB;
			break;

		case 'h':
			print_usage(stdout, 0);

		case '?':
			print_usage(stderr, 1);

		case -1:
			break;

		default:
			abort();
		}
	} while (next_opt != -1);

	if (argc == 1 || length == 0)
		print_usage(stderr, 2);

	addr = mmap(NULL, length/2, PROT_READ | PROT_WRITE,
		    MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
	if (addr == MAP_FAILED) {
		perror("mmap");
		return 1;
	}

	write_bytes(length/2, addr);

	shm = mmap(NULL, length/2, PROT_READ | PROT_WRITE,
		   MAP_ANONYMOUS | MAP_SHARED, -1, 0);
	if (shm == MAP_FAILED) {
		perror("mmap");
		return 1;
	}

	write_bytes(length/2, shm);

	block = balloon_inflate(BALLOON_SIZE(length));

	read_bytes(length/2, addr);

	munmap(block, BALLOON_SIZE(length));
	munmap(addr, length/2);
	munmap(shm, length/2);
	return 0;
}
