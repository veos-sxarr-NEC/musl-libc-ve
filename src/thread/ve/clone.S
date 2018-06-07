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
/* PATH: src/thread/ve/clone.S
*  The argument passing order and corresponding registers is as follows:
*
*  wrapper(clone):
*  __clone(fn,	stack,	flags,	arg, ...
*				&new->tid, TP_ADJ(new), &new->tid)
*  VE convention: args need to fetch from stack as,
*		fn =>		%s0 =>	1st_arg =>	176+8*0 (SP)
*		stack =>	%s1 =>	2nd_arg =>	176+8*1 (SP)
*		flags =>	%s2 =>	3rd arg =>	176+8*2 (SP)
*		arg =>		%s3 =>	4th arg =>	176+8*3 (SP)
*	ptid or &new->tid =>	%s4 =>	5th_arg =>	176+8*4 (SP)
*	TLS or TP_ADJ(new) =>	%s5 =>	6th arg =>	176+8*5 (SP)
*	ctid or &new->tid =>	%s6 =>	7th arg =>	176+8*6 (SP)
*	Guard pointer	=>	%s7 =>	8th arg =>	176+8*7 (SP)
*  syscall(clone):
*	clone(	flags,	stack,	ptid,	ctid,	tls)
*  VE convention:
*	s0(nr)	s1,	s2,	s3,	s4,	s5,
*/
#include <bits/reg.h>
.text
.global	__clone
.type	__clone,@function
__clone:
	ld	%s0, 0xB0(0,%s11)	/* s0	= 1st arg of function */
	ld	%s1, 0xB8(0,%s11)	/* %s1	= 2nd arg of function */

	/* return -EINVAL, if function or stack is NULL */
	breq.l	 0, %s0, error		/* check for NULL function */
	breq.l	 0, %s1, error		/* check for NULL stack */

	ldl.sx	%s2, 0xC0(0,%s11)	/* %s2	= 3rd arg of function */
	ld	%s3, 0xC8(0,%s11)	/* %s3	= 4th arg of function */
	ld	%s4, 0xD0(0,%s11)	/* %s4	= 5th arg of function */
	ld	%s5, 0xD8(0,%s11)	/* %s5	= 6th arg of function */
	ld	%s6, 0xE0(0,%s11)	/* %s6	= 7th arg of function */
	ld	%s7, 0xE8(0,%s11)	/* %s7	= 8th arg of function */
	or	%s62, %s0, (0)1		/* fn	= %s62	[save fn in s62] */
	or	%s0, 56, (0)1		/* %s0	= SYS_clone */

	or	%s63, %s1, (0)1		/* %s63	= temp. hold child SP */
	or	%s1, %s2, (0)1		/* %s1	= flags */
	or	%s47, %s63, (0)1	/* %s47	= hold SP, used as FP for child */
	lea	%s2, -0xB0(,%s47)	/* %s2	= stack pointer
					also reserve memory for callee */
					/* saved register used in child context */
	or	%s48, %s3, (0)1		/* %s48	= args pointer [save arg in s48] */
	or	%s3, %s4, (0)1		/* %s3	= ptid */
	or	%s4, %s6, (0)1		/* %s4	= ctid */
					/* %s5 already has TLS */
	xor	%s6, %s6, %s6

	/* SHM and MONC of clone system call */
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)		/* %s0 = SYS_clone */
	shm.l	%s1, 0x8(%s46)		/* %s1 = flags (1st arg) */
	shm.l	%s2, 0x10(%s46)		/* %s2 = stack pointer (2nd arg) */
	shm.l	%s3, 0x18(%s46)		/* %s3 = ptid (3nd arg) */
	shm.l	%s4, 0x20(%s46)		/* %s4 = ctid (4th arg) */
	shm.l	%s5, 0x28(%s46)		/* %s5 = TLS (5th arg) */
	shm.l	%s7, 0x30(%s46)		/* %s7 = Guard (Guard Pointer) */
	monc

	brne.l.t 0, %s0, 1f		/* return from parent context */

	/* execute in child context */
	xor	%s9, %s9, %s9		/* clear the frame pointer */

	or	%s9, %s47,(0)1		/* set FP at initial SP. */

	/* setting stack limit  */
	lea     %s60, __libc@PC_LO(-24) /* Fetching libc struct addr */
	and     %s60, %s60,(32)0
	sic     %s59
	lea.sl  %s60, __libc@PC_HI(%s59,%s60)
	ld      %s58, 0x38(0, %s60)     /* page_size is at 56 offset */
	subu.l  %s58, %s47, %s58
	lea	%s47, 0x180DC8		/* STACK_AREA_FOR_SIGNAL */
	addu.l  %s58, %s47, %s58
	or      %s8, %s58,(0)1		/* set initial stack_limit */

	or	%s0, %s48, (0)1		/* %s0 = Args pointer */
					/* put the saved argument into the 1st */
					/* argument reg. before function call */
	or	%s12, %s62, (0)1	/* %s12 = Child function pointer */
	bsic	%s10, 0x0(,%s12)	/* invoke child function */

	/* prepare registers/arguments for exit system call */
	or	%s1, %s0, (0)1		/* %s1 = exit status for exit syscall */
	xor	%s0, %s0, %s0
	or	%s0, 60, (0)1		/* %s0 = SYS_exit */

	/* SHM and MONC of exit system call */
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	monc

1:	beq.l.t 0,0x0(, %lr)

error:
	st      %s33, 0xa8(0,%s11)  /* #918 saving calling save register */
	or      %s33, %lr, (0)1

	/* getting address of errno */
	lea     %sp, -176-80(,%sp)
#ifndef SHARED
	lea     %s12, __errno_location@LO
	and     %s12, %s12, (32)0
	lea.sl  %s12, __errno_location@HI(,%s12)
#else
	lea     %s12, __errno_location@PC_LO(-24)
	and     %s12,%s12,(32)0
	sic     %s62
	lea.sl  %s12, __errno_location@PC_HI(%s12,%s62)
#endif
	bsic    %lr, (,%s12)
	lea     %sp, 176+80(,%sp)

	/* Setting EINVAL */
	or	%s0, -22, (0)1

	or      %lr, %s33, (0)1
	ld      %s33, 0xa8(0,%s11)  /* fetching calling save register */
	beq.l.t 0,0x0(, %lr)
