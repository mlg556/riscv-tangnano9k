IO_BASE = 0x400000
LEDS = 4
UART_TX = 8
UART_RX = 16
UART_CTRL = 32

UART_CTRL_TX_DONE = 1
UART_CTRL_RX_DONE = 2

loop:
    call serial_getc
    call put_led
    call serial_putc

    li a0, ' '
    call serial_putc
    li a0, 'o'
    call serial_putc
    li a0, 'k'
    call serial_putc
    li a0, '\n'
    call serial_putc

    j loop

# Func: put_led
# Arg: a0 = value to print to leds

put_led:
    li t0, IO_BASE
    sw a0, LEDS(t0)
    ret

# Func: serial_getc
# Ret: a0 = character received
serial_getc:
    li t0, IO_BASE
serial_getc_loop:
    lw t1, UART_CTRL(t0)
    andi t1, t1, UART_CTRL_RX_DONE # isolate bit1
    # UART_CTRL bit1 is set => rx done
    # so loop until done
    beqz t1, serial_getc_loop
    # read char
    lb a0, UART_RX(t0)
    ret

# Func: serial_putc
# Arg: a0 = character to send
serial_putc:
    li t0, IO_BASE
    # send char
    sw a0, UART_TX(t0)

serial_putc_loop:
    lw t1, UART_CTRL(t0)
    andi t1, t1, UART_CTRL_TX_DONE # isolate bit0
    # UART_CTRL bit0 is set => tx done
    # so loop until done
    beqz t1, serial_putc_loop
    ret