.section .init
.balign 16
.global _init
.type	_init, @function
_init:
	st %s0, 0x0(%s11)
	st %s9, 0x8(%s11)
	beq.l.t 0, 0x0(,%s10)

.section .rodata
.globl  __ve_hw_specific00		
.type   __ve_hw_specific00,@object	
.hidden __ve_hw_specific00		
__ve_hw_specific00:				
        .zero   256
