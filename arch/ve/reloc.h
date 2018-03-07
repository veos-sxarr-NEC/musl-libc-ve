#define LDSO_ARCH "ve"
#define TPOFF_K		16

#define REL_REFLONG	R_VE_REFLONG
#define REL_REFQUAD	R_VE_REFQUAD
#define REL_SREL32	R_VE_SREL32
#define REL_SYMBOLIC_HI	R_VE_HI32
#define REL_SYMBOLIC_LO	R_VE_LO32
#define REL_OFFSET_HI	R_VE_PC_HI32
#define REL_OFFSET_LO	R_VE_PC_LO32
#define REL_GOT         R_VE_GLOB_DAT
#define REL_PLT         R_VE_JUMP_SLOT
#define REL_RELATIVE    R_VE_RELATIVE
#define REL_COPY        R_VE_COPY
#define REL_DTPMOD      R_VE_DTPMOD64
#define REL_DTPOFF      R_VE_DTPOFF64
#define REL_TPOFF       R_VE_TPOFF64

#define CRTJMP(pc,sp) __asm__ __volatile__( \
	" lea %%sp, (,%1);  b.l (,%0)" : : "r"(pc), "r"(sp) )

#define GETFUNCSYM(fp, __dls2, got) __asm__ ( \
        "lea    %%s62, __dls2@PC_LO(%1)\n" \
        "\tand  %%s62, %%s62, (%2)%3\n" \
        "\tsic  %%s61\n" \
        "\tlea.sl  %%s62, __dls2@PC_HI(%%s61, %%s62)\n" \
        "\tor   %0, %%s62, (%3)%4\n" \
        : "=r"(*fp): "i"(-24), "i"(32), "i"(0), "i"(1));
