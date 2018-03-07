.section .fini
.balign 16
.global	_fini
.type	_fini, @function
_fini:
	st %s0, 0x0(%s11)
	st %s9, 0x8(%s11)
	beq.l.t 0, 0x0(,%s10)
