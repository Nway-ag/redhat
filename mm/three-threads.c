#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

pthread_t thread;

void* thread3(void* d)
{
	int count3 = 1;

	while(count3 <= 3){
//		sleep(10);
		printf("Thread 3: %d\n", count3++);
	}
	return NULL;
}

void* thread2(void* d)
{
	int count2 = 1;

	while(count2 <= 3){
		printf("Thread 2: %d\n", count2++);
	}
	return NULL;
}

int main(){
	pthread_create(&thread, NULL, thread2, NULL);
	pthread_create(&thread, NULL, thread3, NULL);

	//Thread 1
	int count1 = 1;

	while(count1 <= 3){
		printf("Thread 1: %d\n", count1++);
	}

	pthread_join(thread,NULL);
	return 0;
}
