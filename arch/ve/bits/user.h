#undef __WORDSIZE
#define __WORDSIZE 64

#define SR_NUM    64               /* Number of Scalar Registers */
#define VR_NUM    64               /* Number of Vector Registers */
#define AUR_MVL   256              /* MAX Length of Vector */

/* VE process user regs */
struct ve_user_regs {
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
};

/* VE process Vector regs */
struct ve_user_vregs {
	/* Vector Mask Registers */
	reg_t VMR[16][4];               /*  0x1800 -  0x19FF */
	uint8_t pad3[0x40000 - 0x1A00]; /*  0x1A00 - 0x3FFFF */
	/* Vector Registers */
	reg_t VR[VR_NUM][AUR_MVL];      /* 0x40000 - 0x5FFFF */
	uint8_t pad4[0x80000 - 0x60000];/* 0x60000 - 0x7FFFF */
};

struct user {
	struct ve_user_regs regs;      /*     0x0 - 0x1800  */
	struct ve_user_vregs vregs;    /*  0x1800 - 0x80000 */
};

#define PAGE_MASK		(~(PAGE_SIZE-1))
#define NBPG			PAGE_SIZE
#define UPAGES			1
