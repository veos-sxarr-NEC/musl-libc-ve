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
.set clr_round_mode,    0xCFFF

.set clr_except_rm,     0x3000  #mask for clearing all the other bits in
				# control and status words except rounding
				# mode bits (50 and 51)

.set default_env,       0x3000

.text
.global fetestexcept
.type fetestexcept,@function
fetestexcept:
	and		%s62, 0x3F, %s0		#s0 contains the 1st argument which has the exceptions that are to be tested for
						#only 6 exceptions are possible therefore masking s0 with 0x3F and storing result in s62
	smir		%s61, %psw		#loads the contents of program status word(PSW) into s61 register
	and		%s61, %s61, (50)0	#masking all other bits except exception mask and flags
	and		%s0, %s61, %s62		#testing the exceptions; if exception(s) is set then corresponding bits are returned
						#otherwise zero is returned

	beq.l.t		0,0x0(,%s10)

.text
.global feclearexcept
.type feclearexcept,@function
feclearexcept:
	and		%s62, 0x3F, %s0		#s0 contains the 1st argument which has the exceptions that are to be cleared off
						#only 6 exceptions are possible therefore masking s0 with 0x3F and storing result in s62
	sfr		%s61			#stores the contents of psw[58..63] i.e. status word in s61
	nnd		%s61, %s62, %s61	#AND s61 with the negation of s62 and store in s61
	lfr		%s61			#load the psw[58..63] with s61[58..63]
	xor		%s0, %s0, %s0		#store zero in the s0 register

	beq.l.t		0,0x0(,%s10)

.text
.global feraiseexcept
.type feraiseexcept,@function
feraiseexcept:
	and		%s62, 0x3F, %s0		#s0 contains the 1st argument which has the exceptions that are to be raised
	sfr             %s61			#stores the contents of psw[58..63] i.e. status word in s61
	or		%s60, %s61, %s62	#set the exception to be raised without disturbing other exceptions
	lfr             %s60			#load the psw[58..63] with s61[58..63]
	xor		%s0, %s0, %s0		#store zero in the s0 register

	beq.l.t		0,0x0(,%s10)

.text
.global __fesetround
.type __fesetround,@function
__fesetround:
	or		%s62, %s0, (0)1		#s0 contains the 1st argument which has the rounding mode that is to be set
						#stores the contents of s0 register in s62
	spm		%s61			#store the psw[50..57] in s61 register and rest all the bits are set to zero
	lea		%s60, clr_round_mode	#store 0xCFFF in s60 as only
						# psw[50..51]
						# represents the rounding mode
	and		%s61, %s60, %s61	# clearing psw[50..51]
	or		%s61, %s62, %s61	#set the rounding mode in s61 with the rounding mode contained in s62
	lpm		%s61			#load the psw[50..57] with s61[50..57]
	xor		%s0, %s0, %s0		#store zero in the s0 register

	beq.l.t		0,0x0(,%s10)

.text
.global fegetround
.type fegetround,@function
fegetround:
	spm		%s62			#store the psw[50..57] in s62 register and rest all the bits are set to zero
	lea		%s61, clr_except_rm	#store 0x3000 in s61 as only
						# psw[50..51]
						# represents the rounding mode
	and		%s0, %s61, %s62		#clear all the bits except 50 and 51 of s62 register
						# & set return value to s0

	beq.l.t		0,0x0(,%s10)

.text
.global fegetenv
.type fegetenv,@function
fegetenv:
	or		%s62, %s0, (0)1		#s0 contains the 1st argument which has the address where the value is to be stored
						#stores the contents of s0 register in s62
	smir		%s61, %psw		#loads the contents of program status word(PSW) into s61 register
	st2b		%s61, (,%s62)		#store s61[48..63] (i.e. psw[48..63]) at the 2-bytes memory location contained in s62
	xor		%s0, %s0, %s0		#store zero in the s0 register

	beq.l.t		0,0x0(,%s10)

.text
.global fesetenv
.type fesetenv,@function
fesetenv:
	addu.l		%s62, 1, %s0		#increment s0 by 1 and store the result in s62 register
	xor		%s0, %s0, %s0		#store zero in the s0 register
	breq.l.t	%s62, 0, 1f		#if s62 is equal to 0 then jump to 1f
	subu.l		%s62, %s62, (63)0	#decrement s62 by 1
	ld2b		%s61, (,%s62)		#load s61[48..63] with the value at the memory location contained in S62
	lpm		%s61			#load the psw[50..57] with s61[50..57]
	lfr		%s61			#load the psw[58..63] with s61[58..63]
	beq.l.t		0,0x0(,%s10)
1:	lea		%s61, default_env	#store 0x3000 in s61
						#0x3000 signifies the default value that is to be set in control and status words
						#50..51 = 11 (round to neareast)
						#52..57 = 000000 (continue to exceptions mode)
						#58..63 = 000000 (clearing all exception flags)
	lpm		%s61			#load the psw[50..57] with s61[50..57]
	lfr		%s61			#load the psw[58..63] with s61[58..63]

	beq.l.t		0,0x0(,%s10)
