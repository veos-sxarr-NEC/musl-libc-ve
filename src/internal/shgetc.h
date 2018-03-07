/* Changes by NEC Corporation for the VE port in musl, 2017-2018 */
#include "stdio_impl.h"

void __shlim(FILE *, off_t);
int __shgetc(FILE *);

#define shcnt(f) ((f)->shcnt + ((f)->rpos - (f)->rend))
#define shlim(f, lim) __shlim((f), (lim))
#ifdef VE
#define shgetc(f) (((unsigned long)(f)->rpos < (unsigned long)(f)->shend)\
		? *(f)->rpos++ : __shgetc(f))
#else
#define shgetc(f) (((f)->rpos < (f)->shend) ? *(f)->rpos++ : __shgetc(f))
#endif
#define shunget(f) ((f)->shend ? (void)(f)->rpos-- : (void)0)
