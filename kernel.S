#include "registers.inc"

.global word_quit
.text
.balign 4

.option norelax

#include "dict.txt"
.balign 4
forth_dict_end:
.space 256

.option relax

.data
.balign 4
dict:
.word word_bye
forth_here:
.word forth_dict_end
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
.ascii "12340"
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
