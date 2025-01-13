#include "registers.inc"

.option norelax

.global word_quit
.text
.balign 4

.macro CALL_WORD_VIA w, r
    la \r, \w
    jalr ra, 8(\r)
.endm

.macro CALL_WORD w
    jal ra, \w + 8
.endm

#include "dict.txt"
#.balign 4
.p2align 2
forth_dict_end:
.space 256

.data
.balign 4
forth_dict:
.word word_bye
forth_dict_editing:
.word 0
forth_here:
.word forth_dict_end-0x700000
forth_state:
.word 0
forth_base:
.word 10
forth_str_ok:
.ascii " ok"
forth_str_compiled:
.ascii " compiled"
forth_str_unknown:
.ascii " is neither a word nor a number"
forth_str_word_is_compile_only:
.ascii " is a compile only word"
str_fuck:
.ascii "fuckfuckfuckfuckfuck"
str_test1:
.ascii "fuckfuckerfuckfucker"
str_test2:
.ascii "fuck"
str_test3:
.ascii "-12345"

.bss
.balign 4
forth_digits_buffer:
.space 64
forth_interpreter_input_buffer:
.space 256
