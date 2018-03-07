static inline struct pthread *__pthread_self()
{
	char *p = NULL;
	__asm__ __volatile__ ( "or %0, 0, %%tp" : "+r"(p) );
	return (pthread_t)((char *)p - sizeof(struct pthread));
}

#define TLS_ABOVE_TP
#define TP_ADJ(p)   ((((uint64_t)(p)) + sizeof(struct pthread)) + 15) \
							& (0xfffffffffffffff0)

#define CANCEL_REG_IP 16
struct dummy_tcbhead_t {
	uint64_t data[6];
};
#define TCB_OFFSET (((sizeof(struct dummy_tcbhead_t))+16UL-1UL)&-16UL)
#define MC_PC IC
#define MAX_SIZE_TP sizeof(struct dummy_tcbhead_t)
