#include "registers.inc"

.global _start, addr_pst_top, addr_rst_top

.section .text.init

_start:
    la t0, _interrupt_vector_table_base
    csrw mtvec, t0

    la t0, _bss_start
    la t1, _bss_end
    beq t0, t1, .L2
.L1:
    sw x0, 0(t0)
    addi t0, t0, 4
    blt t0, t1, .L1
.L2:
    call wdt_disable
    li a0, 1
    call set_cpu_freq
    la sp, parameter_stack_top
    la tp, return_stack_top
quit_loop:
    la t0, word_quit
    jalr ra, 8(t0)
    j quit_loop

set_cpu_freq:
    li t1, 4
    slt t0, t1, a0
    addi t0, t0, 12
    la t1, SYSTEM_CPU_PER_CONF_REG
    sw t0, 0(t1)
    li t2, 2
    slt t0, t2, a0
    slli t0, t0, 10
    addi t0, t0, 1
    andi t1, a0, 2
    srli t1, t1, 1
    sub t0, t0, t1
    la t1, SYSTEM_SYSCLK_CONF_REG
    sw t0, 0(t1)
    ret

.data
.balign 4
addr_pst_top:
.word parameter_stack_top
addr_rst_top:
.word return_stack_top

.bss
.balign 4
return_stack_bottom:
.space 0x400
return_stack_top:
parameter_stack_bottom:
.space 0x400
parameter_stack_top:
