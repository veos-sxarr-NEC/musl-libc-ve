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
/*# PATH: src/process/ve/vfork.s
# The argument passing order and corresponding registers is as follows:

# vfork()
#
# syscall(vfork):
#      vfork()*/
#include <bits/reg.h>
.text
.global        vfork
.type  vfork,@function
vfork:
	st      %s33, 0xa8(0,%s11)      /* #918 saving callee save regiester */
	or      %s33, 0, %s10           /* Saving %lr */
	/* prepare registers/arguments for clone system call*/

	or      %s0, 58, (0)1           /* %s0   = SYS_vfork*/
	/* SHM and MONC of clone system call */
	ld	%s46, SHM_OFFSET(, %tp)	/* shared page offset */
	shm.l   %s0, 0x0(%s46)
	monc
	lea     %s11, -176-16(,%s11)
	st	%s0, 176(, %s11)
#ifndef SHARED
        lea     %s12, __syscall_ret@LO       # get lower part of (__setjmp) address
        and     %s12, %s12, (32)0
        lea.sl  %s12, __syscall_ret@HI(,%s12)# get upper part of (__setjmp) address
#else
        lea     %s12, __syscall_ret@PC_LO(-24)
        and     %s12,%s12,(32)0
        sic     %s62
        lea.sl  %s12, __syscall_ret@PC_HI(%s12,%s62)
#endif
	bsic    %s10,0x0(0,%s12)
	lea     %s11, 176+16(,%s11)
	or      %s10, 0, %s33           /* Saving %lr */
	ld      %s33, 0xa8(0,%s11)      /* fetchin callee save regiester */
	b.l     (,%lr) /* jmp to return address */
