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
/* PATH: src/thread/ve/__unmapself.s */
#include <bits/reg.h>
.text
.global __unmapself
.type   __unmapself,@function
__unmapself:
	/* prepare registers/arguments for munmap system call */
	or	%s2, %s1, (0)1		/* Shift arguments and */
					/* place the syscall number on s0 */
	or	%s1, %s0, (0)1
	or	%s0, 11, (0)1		/* SYS_munmap */

	/* SHM and MONC of munmap system call */
	ld      %s3, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s3)
	shm.l	%s1, 0x8(%s3)
	shm.l	%s2, 0x10(%s3)
	monc				/* munmap(arg1,arg2) */

	/* prepare registers/arguments for exit system call */
	or	%s0, 60, (0)1		/* SYS_exit (60) */
	xor	%s1, %s1, %s1		/* exit() args: always return success */

	/* SHM and MONC of munmap system call */
	shm.l	%s0, 0x0(%s3)
	shm.l	%s1, 0x8(%s3)
	monc				/* exit(0) */
