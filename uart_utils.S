#include "registers.inc"

.global uart0_rx_len, uart0_tx_len, uart0_send_byte, uart0_read_byte

.text
.balign 4
uart0_rx_len:
    la t6, UART0_STATUS_REG
    lw a0, 0(t6)
    andi a0, a0, 1023
    ret

uart0_tx_len:
    la t6, UART0_STATUS_REG
    lw a0, 0(t6)
    srli a0, a0, 16
    andi a0, a0, 1023
    ret

uart0_send_byte:

uart0_read_byte:
    la t6, UART0_FIFO_REG
    lw a0, 0(t6)
    andi a0, a0, 255
    ret
