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
/* PATH: src/thread/ve/syscall_cp.s
*  The __syscall_cp() macro, after preprocessing,call
*  (__syscall_cp)(nr,u,v,w,x,y,z) defined in ./src/thread/cancel_impl.c
*  from which,
*  if (!libc.main_thread || (self = __pthread_self())->canceldisable)
*	return __syscall(nr, u, v, w, x, y, z);
*
*  r = __syscall_cp_asm(&self->cancel, nr, u, v, w, x, y, z);
*  which ends up in syscall_cp.s
*
*  The argument passing order and corresponding registers is as follows:
*  Maximum args in syscall_cp call is 6, from which nr is syscall number.
*  s0: return value, pointer to self->cancel.
* s1: system call number.
* s2-s7: args
*
* VE convention from function call:
*        arg1,		arg2,	arg3,	arg4,	arg5,	arg6,	arg7,	arg8
*	__cancel,	nr,	u,	v,	w,	x,	y,	z
*	s0,		s1,	s2,	s3,	s4,	s5,	s6,	s7
*
*  VE convention for system call	:
*	s0,	s1,	s2,	s3,	s4,	s5,	s6
*	num,	arg1,	arg2,	arg3,	arg4,	arg5,	arg6
*	nr,	u,	v,	w,	x,	y,	z
*/
#include <bits/reg.h>
.text
.global __cp_begin
.hidden __cp_begin
.global __cp_end
.hidden __cp_end
.global __cp_cancel
.hidden __cp_cancel
.hidden __cancel
.global __syscall_cp_asm
.hidden __syscall_cp_asm
.type   __syscall_cp_asm,@function
__syscall_cp_asm:

__cp_begin:
/*	 s0 holds first argument, its a pointer to self->cancel.
*	 we must compare the dereferenced value with 0 and jump to
*	 1f if self->cancel is not set else call __cancel().
*/
	ldl	%s63, (,%s0)
	brne.l 0, %s63, __cp_cancel

/*	ok, the cancel flag was not set
*	prepare registers/arguments for system call
*/
	or	%s63, %s0, (0)1
	or	%s0, %s1, (0)1		/* syscall number into s0 */
	or	%s1, %s2, (0)1		/* Shift the arguments */
	or	%s2, %s3, (0)1		/* from s2-s7 into s1-s6. */
	or	%s3, %s4, (0)1
	or	%s4, %s5, (0)1
	or	%s5, %s6, (0)1
	or	%s6, %s7, (0)1

	/* SHM and MONC of system call */
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	shm.l	%s2, 0x10(%s46)
	shm.l	%s3, 0x18(%s46)
	shm.l	%s4, 0x20(%s46)
	shm.l	%s5, 0x28(%s46)
	shm.l	%s6, 0x30(%s46)
	monc
__cp_end:
	beq.l.t 0,0x0(, %lr)
__cp_cancel:
#ifndef SHARED
	lea	%s12, __cancel@LO
	and	%s12, %s12, (32)0
	lea.sl	%s12, __cancel@HI(,%s12)
#else
	lea     %s12, __cancel@PC_LO(-24)
	and     %s12,%s12,(32)0
	sic     %s62
	lea.sl  %s12, __cancel@PC_HI(%s12,%s62)
#endif
	bsic	%s10, 0x0(,%s12)
