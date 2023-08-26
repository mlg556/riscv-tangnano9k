# Memory-mapped IO in IO page, 1-hot addressing in word address.   
#IO_LEDS_bit = 0;  W five leds
#IO_UART_TX_DATA_bit = 1;  // W data to send (8 bits) 
#IO_UART_RX_DATA_bit = 2;  // R data to read (8 bits) 
#IO_UART_CTRL = 3;  // R status. bit 0: busy sending

IO = 0x400000
LEDS = 4
UART_TX = 8
UART_RX = 16
UART_CTRL = 32

T = 5 # delay 2**T cycles, 2**20 ~ 1M

setup:

loop:
    li a0, 104
    call putc
    call putled

    li a0, 105
    call putc
    call putled

    j loop

# Func: serial_putc
# Arg: a0 = character to send
serial_putc:
    li t0, IO
serial_putc_loop:
    lw t1, UART_CTRL(gp)
    andi t1, t1, 1 # isolate bit0
    # UART_CTRL bit0 is set => tx done
    # so loop until done
    beqz t1, serial_putc_loop
    # send char
    sw a0, UART_TX(gp)
    ret

putled:
    sw a0, LEDS(gp)
    ret
