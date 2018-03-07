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

#include "stdio_impl.h"
#include <wchar.h>

wint_t __fgetwc_unlocked(FILE *);

/*task-refs #766*/
wchar_t *fgetws(wchar_t *restrict s, int n, FILE *restrict f)
{
	wchar_t *p = s;

	if (!n--) return s;

	FLOCK(f);

	for (; n; n--) {
		wint_t c = __fgetwc_unlocked(f);
		if (c == WEOF) break;
		*p++ = c;
		*p = 0;
		if (c == '\n') break;
	}
	if (ferror(f)) p = s;

	FUNLOCK(f);

	return (p == s) ? NULL : s;
}

weak_alias(fgetws, fgetws_unlocked);
