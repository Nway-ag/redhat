#include <stdio.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdlib.h>

int main ( int argc, const char *argv[] )
{
	argc = argc;
	int shmid = atoi( argv[1] );

	int ret;
	ret = shmctl(shmid, IPC_RMID, NULL);
	if ( ret == -1 ) {
		perror("shmctl");
		exit(EXIT_FAILURE);
	}
	return 0;
}
