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
/* void longjmp(jmp_buf env, int val);
 *
 * wrapper(longjmp):
 * _longjmp(env, val)
 * longjmp(env, val)
 *
 * 1st argument env => %s0 (contains setjmp saved stack context)
 * 2nd argument env => %s1 (value to be returned once longjmp
 * restores the stack context saved by setjmp())
 */
#include <bits/signal.h>

.text
.global _longjmp
.global longjmp
.type _longjmp,@function
.type longjmp,@function
_longjmp:
longjmp:
	/* if(arg1) Goto label '2:' & store arg1 to return */
	/* else increment arg1 */
	brne.w  0, %s1, 2f
	addu.w	%s63, 1, %s1
	/* Goto label '3:' */
	br.l	3f
2:
	or	%s63, %s1, (0)1
3:
	or      %s62, %s0, (0)1
	ld	%s2, 0xC8(0, %s62)

	breq.l.t 0, %s2, 1f		/* if (arg0) restore signal mask, \
					   else jmp to 1*/

	/* Preparing arguments for rt_sigprocmask() system call */
	or      %s0, 14, (0)1           /* Save syscall number in s0 */
	or      %s1, 2, (0)1            /* Save 1st arg(i.e. SIG_SETMASK)in s1*/
	lea     %s2, 0xD0(0, %s62)	/* Save 2nd arg
					 address of saved mask) in s2 */
	xor     %s3, %s3, %s3           /* Save 3rd arg(i.e. NULL) in s3 */

	/* SHM and MONC of rt_sigprocmask() system call */
	ld      %s46, 0x18(,%s14)
	lea	%s61, _NSIG
	or	%s60, 3, (0)1
	srl	%s4, %s61, %s60
	shm.l   %s0, 0x0(%s46)
	shm.l   %s1, 0x8(%s46)
	shm.l   %s2, 0x10(%s46)
	shm.l   %s3, 0x18(%s46)
	shm.l   %s4, 0x20(%s46)

	monc                            /* rt_sigprocmask(monc) */

	or      %s0, %s62, (0)1
1:
	ld	%sl, 0x00(0, %s0)	/* Fetch Stack Limit */
	ld	%fp, 0x08(0, %s0)	/* Fetch Frame Pointer */
	ld	%lr, 0x10(0, %s0)	/* Fetch Link Register */
	ld	%sp, 0x18(0, %s0)	/* Fetch Stack Pointer */
	ld	%s12, 0x20(0, %s0)	/* Fetch Outer Register */
	ld	%s13, 0x28(0, %s0)	/* Fetch Link area Register */
	/* Fetch the Callee Saved Registers */
	ld	%s15, 0x30(0, %s0)
	ld	%s16, 0x38(0, %s0)
	ld	%s17, 0x40(0, %s0)
	ld	%s18, 0x48(0, %s0)
	ld	%s19, 0x50(0, %s0)
	ld	%s20, 0x58(0, %s0)
	ld	%s21, 0x60(0, %s0)
	ld	%s22, 0x68(0, %s0)
	ld	%s23, 0x70(0, %s0)
	ld	%s24, 0x78(0, %s0)
	ld	%s25, 0x80(0, %s0)
	ld	%s26, 0x88(0, %s0)
	ld	%s27, 0x90(0, %s0)
	ld	%s28, 0x98(0, %s0)
	ld	%s29, 0xA0(0, %s0)
	ld	%s30, 0xA8(0, %s0)
	ld	%s31, 0xB0(0, %s0)
	ld	%s32, 0xB8(0, %s0)
	ld	%s33, 0xC0(0, %s0)
	/* Store %s1 to %s0 */
	xor     %s0, %s0, %s0
	or	%s0, %s63, (0)1
	beq.l.t 0,0x0(,%lr)
