IO = 0x400000
LEDS = 4
UART_TX = 8
UART_RX = 16
UART_CTRL = 32

setup:
    li gp, IO
    li a0, 0

loop:
    call getc
    call putled
    call putc
    j loop

getc:
    lw a0, UART_CTRL(gp)
    beqz a0, getc
    lb a0, UART_RX(gp)
    ret

putc: # a0 is the 32-bit char
    # send char
    sw a0, UART_TX(gp)
    # UART_CTRL bit0 is set => tx complete
_l0_putc:
    lw t0, UART_CTRL(gp)
    beqz t0, _l0_putc
    ret

putled:
    sw a0, LEDS(gp)
    ret