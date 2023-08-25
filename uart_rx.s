IO = 0x400000
LEDS = 4
UART_TX = 8
UART_RX = 16
UART_CTRL = 32

    li gp, IO
getc:
    lw a0, UART_CTRL(gp)
    # write to led
    # sw a0, LEDS(gp)
    bnez a0, getc
    # data is ready to read
    lb a0, UART_RX(gp)
    sw a0, LEDS(gp)
    j getc
