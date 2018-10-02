#define _GNU_SOURCE
#include <stdint.h>
#include "libc.h"
#include "atomic.h"
#include <inttypes.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/time.h>
#include <time.h>
#include <stdlib.h>
#include "syscall.h"

static uint64_t base_clock = 0ULL;
struct timespec base_tspec = {0};
struct timespec prev_tspec = {0};
static uint64_t base_stm = 0ULL;

static volatile int lock[2];

int __clock_gettime(clockid_t clk, struct timespec *ts)
{
	int r;
	struct timespec tspec = {0};
        struct timeval tv = {0};
        struct timeval tmp_base_tspec = {0};
        struct timeval prev_tspec_tmp = {0};
        uint64_t e_time, e_time_tmp, cur_stm;
	void *vehva = (void *)0x000000001000;
	int ret = 0;

	if (clk == CLOCK_MONOTONIC)
	{
		if (!ts) return -1;

		if (!base_tspec.tv_sec) {
			LOCK(lock);

			if (!base_tspec.tv_sec) {
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

				r = __syscall(SYS_clock_gettime, clk, &tspec);
				if(r < 0) {
					ret = __syscall_ret(r);
					goto hndl_ret;
				}
				ret = r;
				base_tspec.tv_sec = ts->tv_sec = tspec.tv_sec;
				base_tspec.tv_nsec = ts->tv_nsec = tspec.tv_nsec;
				GET_STM(base_stm, vehva);
				prev_tspec.tv_sec = ts->tv_sec;
				prev_tspec.tv_nsec = ts->tv_nsec;
				goto hndl_ret;
			}
			UNLOCK(lock);
		}
		GET_STM(cur_stm, vehva);
		e_time = (cur_stm - base_stm) & ((1ULL << 56) - 1 );
		e_time_tmp = e_time / base_clock;
		tv.tv_sec = e_time_tmp / 1000000;
		tv.tv_usec = e_time_tmp % 1000000;

		/*Storing base data from nano to micro sec structure*/
		tmp_base_tspec.tv_sec = base_tspec.tv_sec;
		tmp_base_tspec.tv_usec = (int)base_tspec.tv_nsec/1000;

		timeradd(&tmp_base_tspec, &tv, &tv);
		/*Storing current time data from micro to nano*/
		ts->tv_sec = tv.tv_sec;
		ts->tv_nsec = (int)tv.tv_usec*1000;

		LOCK(lock);

		if (ts->tv_sec - prev_tspec.tv_sec > 3600) {
			r = __syscall(SYS_clock_gettime, clk, &tspec);
			if(r < 0) {
				ret =  __syscall_ret(r);
				goto hndl_ret;
			}
			base_tspec.tv_sec = ts->tv_sec = tspec.tv_sec;
			base_tspec.tv_nsec = ts->tv_nsec = tspec.tv_nsec;
			base_stm = cur_stm;
		}

		/*Preparing structure for timercmp in micro sec format*/
		prev_tspec_tmp.tv_sec = prev_tspec.tv_sec;
		prev_tspec_tmp.tv_usec = (int)prev_tspec.tv_nsec/1000;

		if (timercmp(&tv, &prev_tspec_tmp, <)) {
			struct timeval diff;
			timersub(&prev_tspec_tmp, &tv, &diff);
			if (diff.tv_sec < 60) {
				ts->tv_sec = prev_tspec.tv_sec;
				ts->tv_nsec = prev_tspec.tv_nsec;
				goto hndl_ret;
			}
		}

		prev_tspec.tv_sec = ts->tv_sec;
		prev_tspec.tv_nsec = ts->tv_nsec;
	}
	else
	{
		r = __syscall(SYS_clock_gettime, clk, ts);
		if (r == -ENOSYS) {
			if (clk == CLOCK_REALTIME) {
				__syscall(SYS_gettimeofday, ts, 0);
				ts->tv_nsec = (int)ts->tv_nsec * 1000;
				return 0;
			}
			r = -EINVAL;
		}
		return __syscall_ret(r);
	}

hndl_ret:
                UNLOCK(lock);
                return ret;
}

weak_alias(__clock_gettime, clock_gettime);
