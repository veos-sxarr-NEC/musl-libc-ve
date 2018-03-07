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
.text
.global _dlstart
_dlstart:
	xor	%s9, %s9, %s9
	lea	%s0, 0x0(,%sp)	/* move sp address into 1st argument slot */
.weak _DYNAMIC
.hidden _DYNAMIC
	lea     %s1, _DYNAMIC@PC_LO(-24) /* 2nd arg as an address of DYNAMIC segment */
        and     %s1, %s1,(32)0
        sic     %s63
        lea.sl  %s1, _DYNAMIC@PC_HI(%s63,%s1)

	lea     %s11, -176-80(,%s11)
	and	%s11, %s11, (60)1	/* %sp aligned to 16 bytes */

	lea	%s12, _dlstart_c@PC_LO(-24)
	and	%s12, %s12,(32)0
	sic	%s62
	lea.sl	%s12, _dlstart_c@PC_HI(%s12,%s62)

	bsic	%lr, (%s12)	/* calling _dlstart_c function */
