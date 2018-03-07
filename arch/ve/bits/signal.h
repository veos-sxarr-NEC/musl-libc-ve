#ifndef __ASSEMBLER__
#include <stdint.h>
#if defined(_POSIX_SOURCE) || defined(_POSIX_C_SOURCE) \
 || defined(_XOPEN_SOURCE) || defined(_GNU_SOURCE) || defined(_BSD_SOURCE)

#if defined(_XOPEN_SOURCE) || defined(_GNU_SOURCE) || defined(_BSD_SOURCE)
#define MINSIGSTKSZ	533656			/* For VE Architecture sizeof(struct sigframe) + 8194 */
#define SIGSTKSZ	(MINSIGSTKSZ + 32768)	/* As defined in glibc */
#endif
typedef uint64_t reg_t;

#define SR_NUM 64               /* Number of Scalar Registers */
#define VR_NUM 64               /* Number of Vector Registers */
#define AUR_MVL 256             /* MAX Length of Vector */

/* Copied from AUSIM */
typedef struct {
	/* Performance Counters */
	reg_t USRCC;                    /*     0x0 -     0x7 */
	reg_t PMC[16];                  /*     0x8 -    0x87 */
	uint8_t pad0[0x1000 - 0x88];    /*    0x88 -   0xFFF */
	/* Control Registers */
	reg_t PSW;                      /*  0x1000 -  0x1007 */
	reg_t EXS;                      /*  0x1008 -  0x100F */
	reg_t IC;                       /*  0x1010 -  0x1017 */
	reg_t ICE;                      /*  0x1018 -  0x101F */
	reg_t VIXR;                     /*  0x1020 -  0x1027 */
	reg_t VL;                       /*  0x1028 -  0x102F */
	reg_t SAR;                      /*  0x1030 -  0x1047 */
	reg_t PMMR;                     /*  0x1038 -  0x103F */
	reg_t PMCR[4];                  /*  0x1040 -  0x105F */
	uint8_t pad1[0x1400 - 0x1060];  /*  0x1060 -  0x13FF */
	/* Scalar Registers */
	reg_t SR[SR_NUM];               /*  0x1400 -  0x15FF */
	uint8_t pad2[0x1800 - 0x1600];  /*  0x1600 -  0x17FF */
	/* Vector Mask Registers */
	reg_t VMR[16][4];               /*  0x1800 -  0x19FF */
	uint8_t pad3[0x40000 - 0x1A00]; /*  0x1A00 - 0x3FFFF */
	/* Vector Registers */
	reg_t VR[VR_NUM][AUR_MVL];      /* 0x40000 - 0x5FFFF */
	uint8_t pad4[0x80000 - 0x60000];/* 0x60000 - 0x7FFFF */
} mcontext_t;

struct sigaltstack {
	void *ss_sp;
	int ss_flags;
	size_t ss_size;
};

typedef struct __ucontext {
	unsigned long uc_flags;
	struct __ucontext *uc_link;
	stack_t uc_stack;
	mcontext_t uc_mcontext;
	sigset_t uc_sigmask;
} ucontext_t;

#define SA_NOCLDSTOP  1
#define SA_NOCLDWAIT  2
#define SA_SIGINFO    4
#define SA_ONSTACK    0x08000000
#define SA_RESTART    0x10000000
#define SA_NODEFER    0x40000000
#define SA_RESETHAND  0x80000000
#define SA_RESTORER   0x04000000

#endif

#endif
#define SIGHUP    1
#define SIGINT    2
#define SIGQUIT   3
#define SIGILL    4
#define SIGTRAP   5
#define SIGABRT   6
#define SIGIOT    SIGABRT
#define SIGBUS    7
#define SIGFPE    8
#define SIGKILL   9
#define SIGUSR1   10
#define SIGSEGV   11
#define SIGUSR2   12
#define SIGPIPE   13
#define SIGALRM   14
#define SIGTERM   15
#define SIGSTKFLT 16
#define SIGCHLD   17
#define SIGCONT   18
#define SIGSTOP   19
#define SIGTSTP   20
#define SIGTTIN   21
#define SIGTTOU   22
#define SIGURG    23
#define SIGXCPU   24
#define SIGXFSZ   25
#define SIGVTALRM 26
#define SIGPROF   27
#define SIGWINCH  28
#define SIGIO     29
#define SIGPOLL   29
#define SIGPWR    30
#define SIGSYS    31
#define SIGUNUSED SIGSYS

#define _NSIG 65
