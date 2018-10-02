#define _GNU_SOURCE
#include <inttypes.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/time.h>
#include <time.h>
#include <stdlib.h>
#include "syscall.h"
#include <sys/types.h>
#include "libc.h"

#define SYS_sysve 316
#define VE_SYSVE_GET_VE_INFO 51

ssize_t _ve_get_ve_info(char *name, char *buffer, size_t size)
{
	int ret = 0;
	ret = syscall(SYS_sysve, VE_SYSVE_GET_VE_INFO, (uint64_t)name,
			(uint64_t)buffer, size);
	return __syscall_ret(ret);
}

static uint64_t base_clock = 0ULL;
struct timeval base_tv = {0};
struct timeval prev_tv = {0};
static uint64_t base_stm = 0ULL;

static volatile int lock[2];

int gettimeofday(struct timeval *restrict tv, void *restrict tz)
{
	int ret = 0;
	struct timespec ts;
	uint64_t e_time, e_time_tmp, cur_stm;
        void *vehva = (void *)0x000000001000;

	if (!tv) return -1;

	if (tz != (struct timezeone *)NULL) {
		ret = clock_gettime(CLOCK_REALTIME, &ts);
		if(ret < 0)
			return ret;
		tv->tv_sec = ts.tv_sec;
		tv->tv_usec = (int)ts.tv_nsec / 1000;
		return 0;
	}

	if (!base_tv.tv_sec) {
		LOCK(lock);

		if (!base_tv.tv_sec) {
			errno = 0;
			char base_clk[10] = {0};

			ret = _ve_get_ve_info("clock_base", base_clk, 10);
			if(ret < 0)
				goto hndl_ret;

			base_clock = strtol(base_clk, NULL, 10);
			if (errno) {
				ret = -1;
                                goto hndl_ret;
			}

			ret = clock_gettime(CLOCK_REALTIME, &ts);
			if(ret < 0)
				goto hndl_ret;

			base_tv.tv_sec = tv->tv_sec = ts.tv_sec;
			base_tv.tv_usec = tv->tv_usec = (int)ts.tv_nsec / 1000;
			GET_STM(base_stm, vehva);
			prev_tv.tv_sec = tv->tv_sec;
			prev_tv.tv_usec = tv->tv_usec;
			goto hndl_ret;
		}
		UNLOCK(lock);
	}
	GET_STM(cur_stm, vehva);
	e_time = (cur_stm - base_stm) & ((1ULL << 56) - 1 );
	e_time_tmp = e_time / base_clock;
	tv->tv_sec = e_time_tmp / 1000000;
	tv->tv_usec = e_time_tmp % 1000000;
	timeradd(&base_tv, tv, tv);

	LOCK(lock);

	if (tv->tv_sec - prev_tv.tv_sec > 3600) {
		ret = clock_gettime(CLOCK_REALTIME, &ts);
		if(ret < 0)
                        goto hndl_ret;
		base_tv.tv_sec = tv->tv_sec = ts.tv_sec;
		base_tv.tv_usec = tv->tv_usec = (int)ts.tv_nsec / 1000;
		base_stm = cur_stm;
	}

	if (timercmp(tv, &prev_tv, <)) {
		struct timeval diff;
		timersub(&prev_tv, tv, &diff);
		if (diff.tv_sec < 60) {
			tv->tv_sec = prev_tv.tv_sec;
			tv->tv_usec = prev_tv.tv_usec;
			goto hndl_ret;
		}
	}
	prev_tv.tv_sec = tv->tv_sec;
	prev_tv.tv_usec = tv->tv_usec;

hndl_ret:
        UNLOCK(lock);
        return ret;
}
