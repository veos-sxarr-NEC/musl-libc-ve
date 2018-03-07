/* Copyright (C) 2014 NEC Corporation. */

#ifndef _STDARG
#define _STDARG

#ifdef __STDC__
#define	va_copy(dest, src)	((void)((dest) = (src)))
#endif /* __STDC__ */

#endif /* _STDARG */

#define _STDARG_ALIGN	8
#ifdef _LONG64
#define _STDARG_CASTINT	long
#else
#define _STDARG_CASTINT	long long
#endif


#ifdef	__STDC__

#ifndef _VA_LIST
#define _VA_LIST void *
#endif /*_VA_LIST*/

#ifndef __VA_LIST
#define __VA_LIST
typedef _VA_LIST	va_list;
#endif

#define va_start(list, parm) (void) (list = (va_list)(((long *)&parm)+1))
#define va_arg(list, type) (list = (va_list)(((long *)list)+1), *(type *)(((long *)list)-1))
#define	va_end(list)	(void)0

#else /*!__STDC__*/

#error "not supported"

#endif /*__STDC__*/
