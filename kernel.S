#include "registers.inc"

.global read_line, search_word, parse_number, push_number
.text
.balign 4
// before: a0: addr of name string to search a1: len of name
// after: a0: non-zero addr of the word found, zero if word not found
search_word:
    li t0, 32
    bgtu a1, t0, search_word_give_up
    andi t0, a1, -4
    slt t1, t0, a1
    slli t1, t1, 2
    add t0, t0, t1
    sub t1, t0, a1
    li t2, -1
    slli t1, t1, 3
    srl t2, t2, t1
    // li t6, 0 // reserved for hash
    la t1, word_bye
search_word_cmp:
    lw t3, 4(t1)
    bne a1, t3, search_word_len_neq
    sub t3, t1, t0
    addi t3, t3, 4
search_word_cmp_4bytes:
    lw t4, -4(t3)
    lw t5, 0(a0)
    beq t3, t1, search_word_last_4bytes
    bne t4, t5, search_word_cmp_fail
    addi t3, t3, 4
    addi a0, a0, 4
    j search_word_cmp_4bytes
search_word_last_4bytes:
    and t4, t4, t2
    and t5, t5, t2
    bne t4, t5, search_word_cmp_fail
    mv a0, t1
    ret
search_word_cmp_fail:
search_word_len_neq:
search_word_hash_neq:
    lw t1, 0(t1)
    beqz t1, search_word_give_up
    j search_word_cmp
search_word_give_up:
    li a0, 0
    ret

// before: a0: addr of str to parse a1: len of str
// after: a0: 1 if is number, 0 if not a1: value
parse_number:
    lb t0, 0(a0)
// check base
    li t1, '%'
    beq t0, t1, parse_number_base_is_2
    li t1, '#'
    beq t0, t1, parse_number_base_is_10
    li t1, '$'
    beq t0, t1, parse_number_base_is_16
    la t1, forth_base
    lw t6, 0(t1)
    j parse_number_check_sign
parse_number_base_is_2:
    li t6, 2
    j parse_number_base_found
parse_number_base_is_10:
    li t6, 10
    j parse_number_base_found
parse_number_base_is_16:
    li t6, 16
parse_number_base_found:
    addi a1, a1, -1
    beqz a1, parse_number_fail
    addi a0, a0, 1
    lb t0, 0(a0)
parse_number_check_sign: // t6: base
    li t2, 0
    li t1, '-'
    bne t0, t1, parse_number_positive
    li t5, 0xffffffff
    addi a1, a1, -1
    beqz a1, parse_number_fail
    addi a0, a0, 1
    lb t0, 0(a0)
    j parse_number_loop
parse_number_positive:
    li t5, 0
parse_number_loop: // t6: base  t5: sign
    li t1, 'z'
    bgt t0, t1, parse_number_fail
    li t1, 97
    blt t0, t1, parse_number_loop_below_a
    addi t0, t0, -87
    j parse_number_loop_check_digit
parse_number_loop_below_a:
    addi t1, t1, -32
    blt t0, t1, parse_number_loop_below_A
    addi t0, t0, -55
    j parse_number_loop_check_digit
parse_number_loop_below_A:
    addi t1, t1, -17
    blt t0, t1, parse_number_fail
    addi t0, t0, -48
parse_number_loop_check_digit:
    bge t0, t6, parse_number_fail
    add t2, t0, t2
    addi a1, a1, -1
    beqz a1, parse_number_result
    mul t2, t2, t6
    addi a0, a0, 1
    lb t0, 0(a0)
    j parse_number_loop
parse_number_result:
    li a0, 1
    xor a1, t2, t5
    slti t5, t5, 0
    add a1, a1, t5
    ret
parse_number_fail:
    li a0, 0
    ret

// a0: number to push into parameter stack
push_number:
    addi sp, sp, -4
    sw a0, 0(sp)
    ret

.option norelax

#include "dict.txt"

//.balign 4
//.ascii "base"
//.balign 4
//word_base:
//.word 0
//.word 4
//    la t0, forth_base
//    addi sp, sp, -4
//    sw t0, 0(sp)
//    ret
//
//.balign 4
//.ascii "emit"
//.balign 4
//word_emit:
//.word word_base
//.word 4
//    la t0, UART0_FIFO_REG
//    lw t1, 0(sp)
//    addi sp, sp, 4
//    sw t1, 0(t0)
//    ret
//
//.balign 4
//.ascii "hello"
//.balign 4
//word_hello:
//.word word_emit
//.word 5
//    addi tp, tp, -4
//    sw ra, 0(tp)
//    la a0, str_hello
//    call rom_printf
//    lw ra, 0(tp)
//    addi tp, tp, 4
//    ret
//str_hello:
//.asciz "hello!\n"
//
//.balign 4
//.ascii "fuck"
//.balign 4
//word_fuck:
//.word word_hello
//.word 4
//    addi tp, tp, -4
//    sw ra, 0(tp)
//    la a0, str_fuck
//    call rom_printf
//    lw ra, 0(tp)
//    addi tp, tp, 4
//    ret
//str_fuck:
//.asciz "fuck!\n"
//
//.balign 4
//.ascii "shit_with_long_name"
//.balign 4
//word_shit_with_long_name:
//.word word_fuck
//.word 19
//    addi tp, tp, -4
//    sw ra, 0(tp)
//    la a0, str_shit
//    call rom_printf
//    lw ra, 0(tp)
//    addi tp, tp, 4
//    ret
//str_shit:
//.asciz "piece of shit with long name\n"
//
//.balign 4
//.ascii "bye"
//.balign 4
//word_bye:
//.word word_shit_with_long_name
//.word 3
//    addi sp, sp, -24
//    li t0, 13
//    sw t0, 20(sp)
//    li t0, 10
//    sw t0, 16(sp)
//    li t0, '!'
//    sw t0, 12(sp)
//    li t0, 'e'
//    sw t0, 8(sp)
//    li t0, 'y'
//    sw t0, 4(sp)
//    li t0, 'b'
//    sw t0, 0(sp)
//    addi tp, tp, -4
//    sw ra, 0(tp)
//    la t0, word_emit
//    jalr ra, 8(t0)
//    la t0, word_emit
//    jalr ra, 8(t0)
//    la t0, word_emit
//    jalr ra, 8(t0)
//    la t0, word_emit
//    jalr ra, 8(t0)
//    la t0, word_emit
//    jalr ra, 8(t0)
//    la t0, word_emit
//    jalr ra, 8(t0)
//    lw ra, 0(tp)
//    addi tp, tp, 4
//    ret

.option relax

.data
.balign 4
dict:
.word word_bye
forth_base:
.word 10
str_fuck:
.asciz "fuck!"

.bss
.balign 4
name_buffer:
.space 256
