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

.section	.data
.set max_fg,    255     #MAXIMUM FLAG use in ts1am.l instruction

# uint64_t a_atmam64(volatile void *p, uint64_t v, int opcode)
# atmam required  3 registers
# implementation ==> atmam  src, ptr, opcode
#	opcode	: 0-> AND , 1-> OR , 2-> ADD
#	src (v)	: 64-bit value
#	ptr (*p): pointer from where data is to be fetched
#		The address indicated by (p) must be aligned to 8-byte boundary
#		otherwise a memory access exception is generated.
.text
.global	a_atmam64
.type	a_atmam64,@function
a_atmam64:
	fencem 1		# FENCE(ST=1)
	atmam	%s1, %s0, %s2
	fencem 2		# FENCE(LF=1)
	or	%s0,%s1,(0)1
	beq.l.t 0,0x0(,%s10)

# uint64_t a_cas64(volatile void *p, uint64_t t, uint64_t s)
# For cas.l , pointer must be aligned to 8-byte boundary.
# implementation==> cas.l s,p,t
# %s0-> dest pointer (*p)
# %s1-> condition register value (t)
# %s2-> newval(s), which will be stored in (*p) if (*p == t)
# if (%s1 == value at %s0)
#	 value at %s0 = %s2
# %s2 = old value at %s0
# In success, %s2 and %s1 both will have same value (old).
# In failure, %s1 have old value and %s2 still have newval.
# cmpu.l : compare %s1 and %s2; if equal, %s0 have zero
#		else %s0 have non-zero value.
.text
.global a_cas64
.type	a_cas64,@function
a_cas64:
	fencem 1		# FENCE(ST=1)
	cas.l	%s2, %s0, %s1
	fencem 2		# FENCE(LF=1)
	cmpu.l	%s0, %s1, %s2
	beq.l.t 0, 0x0(,%s10)

# int a_cas32(volatile void *p, int t, int s)
# pointer(*p) must be 4-byte aligned
# and is used for data types of size 4 bytes.
# remaining operation is same as a_cas64().
.text
.global a_cas32
.type	a_cas32,@function
a_cas32:
	fencem 1		# FENCE(ST=1)
	cas.w	%s2, %s0, %s1
	fencem 2		# FENCE(LF=1)
	cmpu.w	%s0, %s1, %s2
	beq.l.t 0, 0x0(,%s10)

# long a_swap_l(volatile void *Sz, long Sx)
# For ts1am.l, the address indicated by pointer must be
# aligned to 8-byte boundary.
# implementation: ts1am.l newval,pointer,cond_fg
#	newval(Sx)	: value stored after swap, at address pointed by Sz
#	pointer(Sz)	: address from where old value is to be swapped and
#			  new value is to be stored.
#	cond_fg(Sy)	: condition bits Sy[56:63] to perform swap operation
#			  on memory with 8-byte data size of Sx.
#	Old ← M(Sz, 8)
#	for (i = 0 to 7)
#		if(Sy[56+i] == 1) then M(Sz+7-i) ← Sx[8*i:8*i+7]
#	Sx ← Old
.text
.global a_swap_l
.type	a_swap_l,@function
a_swap_l:
	lea	%s2, max_fg
	fencem 1		# FENCE(ST=1)
	ts1am.l	%s1, %s0, %s2
	fencem 2		# FENCE(LF=1)
	or	%s0, %s1, (0)1
	beq.l.t 0, 0x0(,%s10)

# int a_swap(volatile int *Sz, int Sx)
# For ts1am.w, the address indicated by pointer *Sz must be
# aligned to 4-byte boundary.
# implementation: ts1am.w newval,pointer,cond_fg
#	newval(Sx)	: value stored after swap, at address pointed by Sz
#	pointer(Sz)	: address from where old value is to be swapped and
#			  new value is to be stored.
#	cond_fg(Sy)	: condition bits Sy[60:63] to perform swap operation
#			  on memory with 4-byte data size of Sx.
#	Old ← M(Sz, 4)
#	for (i = 0 to 3)
#		if (Sy[60+i] = 1) {M(Sz+3-i) ← Sx[8*(i+4):8*(i+4)+7]}
#	Sx[32:63] ← Old
#	Sx[0:31] ← 00…0
.text
.global a_swap
.type	a_swap,@function
a_swap:
	fencem 1		# FENCE(ST=1)
	ts1am.w	%s1, %s0,15
	fencem 2		# FENCE(LF=1)
	or	%s0, %s1, (0)1
	beq.l.t 0, 0x0(,%s10)

# void a_spin()	NOT IMPLEMENTED
# void a_crash() NOT IMPLEMENTED
