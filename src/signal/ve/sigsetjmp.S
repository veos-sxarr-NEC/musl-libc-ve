/* Copyright (C) 2017-2018 by NEC Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
/*
# int sigsetjmp(sigjmp_buf env, int savesigs);
#
# wrapper(sigsetjmp):
# 1st argument env => %s0
#	where, env is a structure variable.
# 2nd argument savesigs =>%s1
#
# sigsetjmp functionality:
# 1. sigsetjmp checks the value of its first argument
#	- If non-zero, invoke rt_sigprocmask() syscall
#	and save the current signal mask.
# 2. Call setjmp()*/

#include <bits/reg.h>
#include <bits/signal.h>
.global sigsetjmp
.type sigsetjmp,@function
.text

sigsetjmp:
	or	%s4, %s0, (0)1		/* Save s0 in s4 (if s0 gets overwrite) */
	st	%s1, 0xC8(0, %s4)	/* Save content of s1 at
					0xC8 offset of s4 */
	or      %s59, %s4, (0)1
	breq.l.t 0, %s1, 1f		/* If (!s1) jump */
					/* else invoke sigreturn() syscall */

	/* Preparing arguments for rt_sigprocmask() system call */
	or	%s0, 14, (0)1		/* Save syscall number in s0 */
	or	%s1, 2, (0)1		/* Save 1st arg(i.e. SIG_UNBLOCK) in s1 */
	xor	%s2, %s2, %s2		/* Save 2nd arg(i.e. NULL) in s2 */
	lea	%s3, 0xD0(0, %s4)	/* Save 3rd arg
					   (i.e. address of signal mask) */

	/* SHM and MONC of rt_sigprocmask() system call */
	ld	%s46, SHM_OFFSET(,%s14)
	lea     %s61, _NSIG
	or      %s60, 3, (0)1
	srl     %s4, %s61, %s60
	shm.l   %s0, 0x0(%s46)
	shm.l   %s1, 0x8(%s46)
	shm.l   %s2, 0x10(%s46)
	shm.l	%s3, 0x18(%s46)
	shm.l	%s4, 0x20(%s46)
	monc				/* rt_sigprocmask(monc) */

1:	or	%s0, %s59, (0)1
#ifndef SHARED
	lea	%s12, __setjmp@LO	# get lower part of (__setjmp) address
	and	%s12, %s12, (32)0
	lea.sl	%s12, __setjmp@HI(,%s12)# get upper part of (__setjmp) address
#else
	lea     %s12, __setjmp@PC_LO(-24)
	and     %s12,%s12,(32)0
	sic     %s62
	lea.sl  %s12, __setjmp@PC_HI(%s12,%s62)
#endif
	beq.l.t	0, 0x0(,%s12)		/* call setjmp() */
