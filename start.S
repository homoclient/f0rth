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
cli_loop:
    call cli_read
    beqz a0, cli_idle
    mv a1, a0
    mv s0, a1
    la a0, cli_buffer
    call nputs
    call put_space
    call search_word
    beqz a0, cli_parse_number
    jalr ra, 8(a0)
    la a0, str_ok
    li a1, 4
    call nputs
    call put_newline
    j cli_idle
cli_parse_number:
    mv a1, s0
    la a0, cli_buffer
    call parse_number
    beqz a0, cli_not_a_number
    addi sp, sp, -4
    sw a1, 0(sp)
    la a0, str_ok
    li a1, 3
    call nputs
    call put_newline
    j cli_idle
cli_not_a_number:
    la a0, str_unknown
    li a1, 31
    call nputs
    call put_newline
cli_idle:
    li a0, 10
    call delay_ms
    j cli_loop


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

nputs:
    mv t2, a0
    mv t3, a1
    la t1, UART0_FIFO_REG
nputs_loop:
    lw t0, 0(a0)
    andi t0, t0, 255
    sw t0, 0(t1)
    addi a1, a1, -1
    beqz a1, nputs_finish
    addi a0, a0, 1
    j nputs_loop
nputs_finish:
    mv a0, t2
    mv a1, t3
    ret

put_newline:
    la t1, UART0_FIFO_REG
    li t0, 13
    sw t0, 0(t1)
    li t0, 10
    sw t0, 0(t1)
    ret

put_space:
    la t1, UART0_FIFO_REG
    li t0, 32
    sw t0, 0(t1)
    ret

.data
.balign 4
addr_pst:
.word parameter_stack_top
addr_rst:
.word return_stack_top
str_ok:
.ascii " ok"
.balign 4
str_unknown:
.ascii " is neither a word nor a number"
.balign 4

.bss
.balign 4
return_stack_bottom:
.space 0x400
return_stack_top:
parameter_stack_bottom:
.space 0x400
parameter_stack_top:
