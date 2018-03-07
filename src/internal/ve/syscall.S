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
/* Usage: long syscall (syscall_number, arg1, arg2, arg3, arg4, arg5, arg6)
* We need to do some arg shifting, the syscall_number will be in %S0.
* Please refer VE syscall framework for more details.
*/
#include <bits/reg.h>

.global __syscall
.type __syscall,@function
__syscall:
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	shm.l	%s2, 0x10(%s46)
	shm.l	%s3, 0x18(%s46)
	shm.l	%s4, 0x20(%s46)
	shm.l	%s5, 0x28(%s46)
	shm.l	%s6, 0x30(%s46)
	monc
	beq.l.t 0,0x0(, %lr)

.global __syscall0
.type __syscall0,@function
__syscall0:
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	monc
	beq.l.t 0,0x0(, %lr)

.global __syscall1
.type __syscall1,@function
__syscall1:
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	monc
	beq.l.t 0,0x0(, %lr)

.global __syscall2
.type __syscall2,@function
__syscall2:
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	shm.l	%s2, 0x10(%s46)
	monc
	beq.l.t 0,0x0(, %lr)

.global __syscall3
.type __syscall3,@function
__syscall3:
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	shm.l	%s2, 0x10(%s46)
	shm.l	%s3, 0x18(%s46)
	monc
	beq.l.t 0,0x0(, %lr)

.global __syscall4
.type __syscall4,@function
__syscall4:
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	shm.l	%s2, 0x10(%s46)
	shm.l	%s3, 0x18(%s46)
	shm.l	%s4, 0x20(%s46)
	monc
	beq.l.t 0,0x0(, %lr)

.global __syscall5
.type __syscall5,@function
__syscall5:
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	shm.l	%s2, 0x10(%s46)
	shm.l	%s3, 0x18(%s46)
	shm.l	%s4, 0x20(%s46)
	shm.l	%s5, 0x28(%s46)
	monc
	beq.l.t 0,0x0(, %lr)

.global __syscall6
.type __syscall6,@function
__syscall6:
	ld      %s46, SHM_OFFSET(, %tp)
	shm.l	%s0, 0x0(%s46)
	shm.l	%s1, 0x8(%s46)
	shm.l	%s2, 0x10(%s46)
	shm.l	%s3, 0x18(%s46)
	shm.l	%s4, 0x20(%s46)
	shm.l	%s5, 0x28(%s46)
	shm.l	%s6, 0x30(%s46)
	monc
	beq.l.t 0,0x0(, %lr)
