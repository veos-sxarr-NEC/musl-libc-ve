/* Written 2011 Nicholas J. Kain, released as Public Domain */
.weak _init
.weak _fini
.text
.global _start
_start:
# original _start
	xor	%s9, %s9, %s9

/* call __setPthreadStruct to set pthread struct %tp*/
	lea	%s11, -176-80(,%s11)

	lea	%s12, __setPthreadStruct@LO
	and	%s12, %s12, (32)0
	lea.sl	%s12, __setPthreadStruct@HI(,%s12)
	bsic	%lr, (,%s12)

	lea	%s11, 176+80(,%s11)

# get __libc_start_main first argument, address of main
	lea	%s0, main@LO
	and	%s0, %s0, (32)0
	lea.sl	%s0, main@HI(,%s0)

# get __libc_start_main second and third argument, argc, argv
	ld	%s1, 0x0(%sp)
	lea	%s2, 0x8(%sp)

# get addresses of _init, _fini, _exit
	lea	%s3, _init@LO
	and	%s3, %s3, (32)0
	lea.sl	%s3, _init@HI(,%s3)
	lea	%s4, _fini@LO
	and	%s4, %s4, (32)0
	lea.sl	%s4, _fini@HI(,%s4)
	lea	%s5, _exit@LO
	and	%s5, %s5, (32)0
	lea.sl	%s5, _exit@HI(,%s5)

# set sp. RSA + six params
	lea	%sp, -176-80(,%sp)
/* make %sp aligned to 16 bytes */
	and	%sp, %sp, (60)1

# set the arguments
	st	%s0, 0xB0(,%sp)
	st	%s1, 0xC0(,%sp)
	st	%s2, 0xC8(,%sp)
	st	%s3, 0xD0(,%sp)
	st	%s4, 0xE0(,%sp)
	st	%s5, 0xF0(,%sp)

# call __libc_start_main
	lea	%s12, __libc_start_main@LO
	and	%s12, %s12, (32)0
	lea.sl	%s12, __libc_start_main@HI(,%s12)
	bsic	%lr, (,%s12)
