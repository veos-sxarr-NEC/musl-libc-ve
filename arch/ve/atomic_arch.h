#ifndef _INTERNAL_ATOMIC_H
#define _INTERNAL_ATOMIC_H

#include <stdint.h>

/* a_ctz_i : count trailing zero bits of 32-bit number X.
 */
#define a_ctz_i a_ctz_i
static inline int a_ctz_i(unsigned int x)
{
	static const char debruijn32[32] = {
		0, 1, 23, 2, 29, 24, 19, 3, 30, 27, 25, 11, 20, 8, 4, 13,
		31, 22, 28, 18, 26, 10, 7, 12, 21, 17, 9, 6, 16, 5, 15, 14
	};
	return debruijn32[(x&-x)*0x076be629 >> 27];
}

/* a_ctz_l : count trailing zero bits of number X.
 * In VE, long is also a 64-bit number.
 */
#define a_ctz_l a_ctz_l
static inline int a_ctz_l(unsigned long x)
{
	uint32_t y = x;
	if (!y) {
		y = x>>32;
		return 32 + a_ctz_i(y);
	}
	return a_ctz_i(y);
}

/* a_ctz_64 : count trailing zero bits of 64-bit number X.
 */
#define a_ctz_64 a_ctz_64
static inline int a_ctz_64(uint64_t x)
{
	uint32_t y = x;
	if (!y) {
		y = x>>32;
		return 32 + a_ctz_i(y);
	}
	return a_ctz_i(y);
}

/* a_atmam64 : perform operation(decided by opcode) on pointer P with value V.
 * On success: return old value available at pointer P.
 * If ptr is not aligned to 8-byte boundary, causes memory access exception.
 * Definition is available in atomic.s
 */
#define a_atmam64 a_atmam64
extern uint64_t a_atmam64(volatile void *p, uint64_t v, int opcode);

/* a_and_64 : perform AND operation on value pointed by pointer P with value V.
 * Implementation :
 * 1. OPCODE 0 for AND operation used in atmam instruction.
 * 2. OLD copies the current value present at *P.
 * 3. compare return value of a_atmam64 with OLD, if not equal, means operation
 * is failed, and we have to retry this operation.
 * This function always return success.
 */
#define a_and_64 a_and_64
static inline void a_and_64(volatile uint64_t *p, uint64_t v)
{
	uint64_t old;
	do old = *p;
	while (a_atmam64(p, v, 0) != old);
}

/* a_or_64 : perform OR operation on value pointed by pointer P with value V.
 * Implementation :
 * 1. OPCODE 1 for OR operation used in atmam instruction.
 * 2. OLD copies the current value present at *P.
 * 3. compare return value of a_atmam64 with OLD, if not equal, means operation
 * is failed, and we have to retry this operation.
 * This function always return success.
 */
#define a_or_64 a_or_64
static inline void a_or_64(volatile uint64_t *p, uint64_t v)
{
	uint64_t old;
	do old = *p;
	while (a_atmam64(p, v, 1) != old);
}

/* a_store_l : Store long number X at address location pointed by pointer P.
 * This function always return success.
 */
#define a_store_l a_store_l
static inline void a_store_l(volatile void *p, long x)
{
	*(long *)p = x;
}

/* a_or_l : perform OR operation on value pointed by pointer P with value V.
 * In VE, long is also a 64-bit number so we invoke a_atmam64.
 * Implementation :
 * 1. OPCODE 1 for OR operation used in atmam instruction.
 * 2. OLD copies the current value present at *P.
 * 3. Compare return value of a_atmam64 with OLD, if not equal, means operation
 * is failed, and we have to retry this operation.
 * This function always return success.
 */
#define a_or_l a_or_l
static inline void a_or_l(volatile void *p, long v)
{
	long old;
	do old = *(long *)p;
	while ((long)a_atmam64(p, v, 1) != old);
}

/* a_cas64 : Compare number T and value at address pointed by P,
 *		and if both are equal then swap *P with S.
 * On success: return zero.
 * On Failure: return non-zero value.
 * If ptr is not aligned to 8-byte boundary, causes memory access exception.
 * Definition is available in atomic.s
 */
#define a_cas64 a_cas64
extern uint64_t a_cas64(volatile void *p, uint64_t t, uint64_t s);

/* a_cas_p : Compare pointer T and pointer available at *P,
 *		and if both are equal then swap **P with *S.
 * Implementation :
 * 1. Call a_cas64, in success return old pointer *T;
 * 2. If a_cas64 Fail, copy *P in OLD, if OLD != T, return OLD
 *				else retry this function.
 * 3. On failure, return OLD.
 */
#define a_cas_p a_cas_p
static inline void *a_cas_p(volatile void *p, void *t, void *s)
{
	uint64_t old;
	for (;;) {
		if (!(a_cas64(p, (uint64_t)t, (uint64_t)s)))
			return (void *)t;
		old = *(uint64_t *)p;
		if (old != (uint64_t)t)
			return (void *)old;
	}
}

/* a_cas_l : Compare long number T and number available at P,
 *		and if both are equal then swap *P with S.
 * Implementation :
 * 1. Call a_cas64, in success return prev value (T);
 * 2. If a_cas64 Fail, copy *P in OLD, if OLD != T, return OLD
 *				else retry this function.
 * 3. On failure, return OLD.
 */
#define a_cas_l a_cas_l
static inline long a_cas_l(volatile void *p, long t, long s)
{
	long old;
	for (;;) {
		if (!(a_cas64(p, t, s)))
			return t;
		old = *(long *)p;
		if (old != (long)t)
			return old;
	}
}

/* a_cas32 : Compare number T and number available at pointer P,
 *		and if both are equal then swap *P with S.
 * On success: return zero.
 * On Failure: return non-zero value.
 * If ptr is not aligned to 4-byte boundary, causes memory access exception.
 * Definition is available in atomic.s
 */
#define a_cas32 a_cas32
extern int a_cas32(volatile void *p, int t, int s);

/* a_cas : Compare number T and value at pointer P,
 *		and if both are equal then swap *P with T.
 * Implementation :
 * 1. Call a_cas32, in success return prev value (T);
 * 2. If a_cas32 fail, copy *P in OLD, if OLD != T, return OLD
 *				else retry this function.
 * 3. On failure, return OLD.
 */
#define a_cas a_cas
static inline int a_cas(volatile int *p, int t, int s)
{
	int old;
	for (;;) {
		if (!(a_cas32(p, t, s)))
			return t;
		old = *p;
		if (old != (int)t)
			return old;
	}
}

/* a_swap_l : Swap 8-byte number V with number pointed by pointer X.
 * On success: return previous number.
 * This function always return success.
 * If ptr(X) is not aligned to 8-byte boundary, causes memory access exception.
 * Definition is available in atomic.s
 */
#define a_swap_l a_swap_l
extern long a_swap_l(volatile void *x, long v);

/* a_swap : Swap two pointers **X and *V.
 * On success: return previous pointer number (*X).
 * This function always return success.
 * If ptr is not aligned to 8-byte boundary, causes memory access exception.
 * Definition is available in atomic.s
 */
#define a_swap_p a_swap_p
static inline void *a_swap_p(void *volatile * x, void *v)
{
	return (void *)a_swap_l((void *)x, (long)v);
}

/* a_or : perform OR operation on number pointed by pointer P with value V.
 * Implementation :
 * 1. Call a_cas32, in success  a_cas32 return 0.
 * This function always return success.
 */
#define a_or a_or
static inline void a_or(volatile void *p, int v)
{
	int old;
	do old = *(int *)p;
	while (a_cas32(p, old, old|v));
}

/* a_and : perform AND operation on value pointed by pointer P with value V.
 * Implementation :
 * 1. Call a_cas32, in success  a_cas32 return 0.
 * This function always return success.
 */
#define a_and a_and
static inline void a_and(volatile void *p, int v)
{
	int old;
	do old = *(int *)p;
	while (a_cas32(p, old, old&v));
}

/* a_swap : Swap 4-byte interger value V with value pointed by pointer X.
 * On success: return previous value.
 * If ptr(P) is not aligned to 4-byte boundary, causes memory access exception.
 * Definition is available in atomic.s
 * This function always return success.
 */
#define a_swap a_swap
extern int a_swap(volatile int *x, int v);

/* a_and : Fetch value pointed by pointer *X and added with value V.
 * Implementation :
 * 1. Call a_cas32, in success  a_cas32 return 0.
 * 2. On Return, return old value available at pointer X.
 * This function always return success.
 */
#define a_fetch_add a_fetch_add
static inline int a_fetch_add(volatile int *x, int v)
{
	int old;
	do old = *x;
	while (a_cas32(x, old, old+v));
	return old;
}

/* a_inc : Increment number pointed by pointer X by 1.
 * Implementation :
 * 1. Call a_cas32, in success  a_cas32 return 0.
 * This function always return success.
 */
#define a_inc a_inc
static inline void a_inc(volatile int *x)
{
	int old;
	do old = *x;
	while (a_cas32(x, old, old+1));
}

/* a_dec : Decrement number pointed by pointer X by 1.
 * Implementation :
 * 1. Call a_cas32, in success  a_cas32 return 0.
 * This function always return success.
 */
#define a_dec a_dec
static inline void a_dec(volatile int *x)
{
	int old;
	do old = *x;
	while (a_cas32(x, old, old-1));
}

/* a_store : Store 4-byte integer value X at location pointed by pointer P.
 * This function always return success.
 */
#define a_store a_store
static inline void a_store(volatile int *p, int x)
{
	*p = x;
}

/* Currently we dont have any support for a_spin() and
 * a_crash() (as no such assembly instuctions are available)
 * Need to update in future.
 */
#define a_spin a_spin
static inline void a_spin(void)
{
	return;
}

#define a_crash a_crash
static inline void a_crash(void)
{
	return;
}

#endif
