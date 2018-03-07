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
# PATH: src/setjmp/ve/setjmp.s
# int setjmp(jmp_buf env)
#
# wrapper(setjmp):
# __setjmp(env)
# _setjmp(env)
# setjmp(env)
#
# s0 contains the first formal argument passed to
#  __setjmp/_setjmp/setjmp
#
# Following will be stored in %s0 at different offsets:
# - Callee saved registers(%s14 to %s44)
# - frame pointer, stack pointer, link register,
# - link area register, outer register.

.global __setjmp
.global _setjmp
.global setjmp
.type __setjmp,@function
.type _setjmp,@function
.type setjmp,@function
.text

__setjmp:
_setjmp:
setjmp:
	# Saving the current stack context
	st	%sl, 0x00(0, %s0)	#Save Stack Limit
	st	%fp, 0x08(0, %s0)	#Save Frame Pointer
	st	%lr, 0x10(0, %s0)	#Save Link Register
	st	%sp, 0x18(0, %s0)	#Save Stack Pointer
	st	%s12, 0x20(0, %s0)	#Save Outer Register
	st	%s13, 0x28(0, %s0)	#Save Link area Register
	# Saving Callee Saved Registers
	st	%s15, 0x30(0, %s0)
	st	%s16, 0x38(0, %s0)
	st	%s17, 0x40(0, %s0)
	st	%s18, 0x48(0, %s0)
	st	%s19, 0x50(0, %s0)
	st	%s20, 0x58(0, %s0)
	st	%s21, 0x60(0, %s0)
	st	%s22, 0x68(0, %s0)
	st	%s23, 0x70(0, %s0)
	st	%s24, 0x78(0, %s0)
	st	%s25, 0x80(0, %s0)
	st	%s26, 0x88(0, %s0)
	st	%s27, 0x90(0, %s0)
	st	%s28, 0x98(0, %s0)
	st	%s29, 0xA0(0, %s0)
	st	%s30, 0xA8(0, %s0)
	st	%s31, 0xB0(0, %s0)
	st	%s32, 0xB8(0, %s0)
	st	%s33, 0xC0(0, %s0)
	# Set return value "0". Always successfull.
	xor     %s0, %s0, %s0
	# Return
	beq.l.t 0,0x0(,%lr)
