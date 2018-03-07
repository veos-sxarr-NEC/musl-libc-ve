#if defined(_POSIX_SOURCE) || defined(_POSIX_C_SOURCE) \
 || defined(_XOPEN_SOURCE) || defined(_GNU_SOURCE) || defined(_BSD_SOURCE)
#define PAGE_SIZE_2MB   (2 * 1024 * 1024)
#define LONG_BIT 64
#endif
#define PTHREAD_STACK_MIN (4 * 1024 * 1024)
#define LONG_MAX  0x7fffffffffffffffL
#define LLONG_MAX  0x7fffffffffffffffLL
/*#task-refs #818*/
#define BASE_SEM_PATH "/dev/shm/sem."  /*base path of semaphore-name*/
#define BASE_SEM_PATH_SIZE 13  /*base path size of semaphore-name*/
