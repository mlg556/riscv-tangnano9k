IO_BASE = 0x400000
LEDS = 4
UART_TX = 8
UART_RX = 16
UART_CTRL = 32

UART_CTRL_TX_DONE = 1
UART_CTRL_RX_DONE = 2

loop:
    call uart_get
    call put_led
    call uart_put
    
    j loop

# Func: put_led
# Arg: a0 = value to print to leds

put_led:
    li t0, IO_BASE
    sw a0, LEDS(t0)
    ret

# Func: uart_get
# Ret: a0 = character received
uart_get:
    li t0, IO_BASE
uart_get_loop:
    lw t1, UART_CTRL(t0)
    andi t1, t1, UART_CTRL_RX_DONE # isolate bit1
    # UART_CTRL bit1 is set => rx done
    # so loop until done
    beqz t1, uart_get_loop
    # read char
    lb a0, UART_RX(t0)
    ret

# Func: uart_put
# Arg: a0 = character to send
uart_put:
    li t0, IO_BASE
    # send char
    sw a0, UART_TX(t0)

uart_put_loop:
    lw t1, UART_CTRL(t0)
    andi t1, t1, UART_CTRL_TX_DONE # isolate bit0
    # UART_CTRL bit0 is set => tx done
    # so loop until done
    beqz t1, uart_put_loop
    ret