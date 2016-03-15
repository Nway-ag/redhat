// This is reproducer of bz-1312729
#include <stdio.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>

#define GB_SZ  (1024*1024*1024)
#define MB_SZ  (1024*1024)
#define PG_SZ  (4*1024)

#define INV_PTR ((char *)-1)

#define MAX_DST  1024

int id_src_1gb;
char *src_1gb;

int id_dst[MAX_DST];
char *dst[MAX_DST];

void free_and_exit ( int exit_code )
{
	int ret;
	int i;

	if ( id_src_1gb != -1 ) {
		ret = shmctl( id_src_1gb, IPC_RMID, NULL );
		if ( ret == -1 ) perror( "shmctl(id_src_1gb)" );
	}

	for ( i=0; i<MAX_DST; ++i ) {
		if ( id_dst[i] != -1 ) {
			ret = shmctl( id_dst[i], IPC_RMID, NULL );
			if ( ret == -1 ) perror( "shmctl(id_dst[i])" );
		}
	}

	exit( exit_code );
}

int get_page_fault_num ( )
{
	FILE *f = fopen( "/proc/self/stat", "r" );
	char s[11][256];
	int pg;
	int ret = fscanf( f, "%s %s %s %s %s %s %s %s %s %s %s %d",
                          s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[7], s[8], s[9], s[10], &pg );
	if ( ret != 12 ) {
		perror( "get_page_fault_num" );
		pg = -1;
	}
	return pg;
}

int main ( int argc, const char *argv[] )
{
	int i;
	int alloc_sz;

	argc = argc;
	alloc_sz = atoi( argv[1] );
	printf( "%d\n", alloc_sz );

	id_src_1gb = -1;
	src_1gb = INV_PTR;
	for ( i=0; i<MAX_DST; ++i ) {
		id_dst[i] = -1;
		dst[i] = INV_PTR;
	}

	// allocate source memory (1GB only)
	id_src_1gb = shmget(IPC_PRIVATE, 1*GB_SZ, IPC_CREAT);
	src_1gb = shmat( id_src_1gb, NULL, 0 );
	printf( "src_1gb = %d, %p\n", id_src_1gb, src_1gb );
	if ( id_src_1gb == -1 ) free_and_exit(-1);
	if ( src_1gb == (char*)-1  ) free_and_exit(-1);

	// allocate destination memory (array)
	int dst_num = alloc_sz - 1;
	for ( i=0; i<dst_num; ++i ) {
		id_dst[i] = shmget(IPC_PRIVATE, 1*GB_SZ, IPC_CREAT);
		dst[i] = (char *)shmat( id_dst[i], NULL, 0 );
		printf( "dst%03d = %d, %p\n", i, id_dst[i], dst[i] );
		if ( id_dst[i] == -1 ) free_and_exit( -1);
		if ( dst[i] == (char*)-1 ) free_and_exit(-1);
	}

	printf( "##### PageFault(first): %10d \n", get_page_fault_num() );

	// memmove  source to each destination memories (for SWAP-OUT)
	printf ( "memmove:" );
	for ( i=0; i<dst_num; ++i ) {
		memmove( dst[i], src_1gb, 1*GB_SZ );
		printf ( " %d", i );
		fflush( stdout );
	}
	printf( "\n" );
	printf( "##### PageFault(After memmove): %10d \n", get_page_fault_num() );

	// check data on DRAM or SWAP.  '0' means "on SWAP", '1' means "on DRAM"
	printf ( "mincore check:" );
	for ( i=0; i<dst_num; ++i ) {
		unsigned char vec;
		int ret = mincore( dst[i], PG_SZ, &vec );
		if ( ret == -1 ) {
			perror( "mincore: " );
			free_and_exit( -1 );
		}
		printf ( " %d", vec );
		fflush( stdout );
	}
	printf( "\n" );

	// Do madvice() to dst[0].
	printf( "##### PageFault(before madvice): %10d \n", get_page_fault_num() );
	madvise(dst[0], PG_SZ, MADV_WILLNEED);
	sleep(3);  // wait for read from SWAP

	// Read dst[0] data.
	printf( "##### PageFault(after madvice / before Mem Access): %10d \n", get_page_fault_num() );
	*dst[0] = 10;
	printf( "##### PageFault(after madvice / after Mem Access): %10d \n", get_page_fault_num() );


	free_and_exit(0);

	return 0;
}
