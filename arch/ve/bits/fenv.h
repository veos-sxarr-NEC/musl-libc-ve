#define FE_INEXACT    1
#define FE_INVALID    2
#define __FE_DENORM   4
#define FE_UNDERFLOW  8
#define FE_OVERFLOW   16
#define FE_DIVBYZERO  32

#define FE_ALL_EXCEPT \
	(FE_INEXACT | FE_DIVBYZERO | FE_UNDERFLOW | FE_OVERFLOW | FE_INVALID)

#define FE_TOWARDZERO 0
#define FE_UPWARD     0x1000
#define FE_DOWNWARD   0x2000
#define FE_TONEAREST  0x3000

typedef unsigned short fexcept_t;

typedef unsigned short fenv_t;

#define FE_DFL_ENV      ((const fenv_t *) -1)
