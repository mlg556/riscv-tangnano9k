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

    tail setup # !!!

DATA:
    string helo

align 4

setup:
    li gp, IO
    li sp, 0
loop:
    lb a0, DATA(sp)
    call putc
    call putled
    call delay

    lb a0, DATA+1(sp)
    call putc
    call putled
    call delay

    lb a0, DATA+2(sp)
    call putc
    call putled
    call delay

    lb a0, DATA+3(sp)
    call putc
    call putled
    call delay

    j loop

putc: # a0 is the 32-bit char
    # send char
    sw a0, UART_TX(gp)
    # UART_CTRL bit0 is set => tx complete
_l0_putc:
    lw t1, UART_CTRL(gp)
    bnez t1, _l0_putc
    ret

putled:
    sw a0, LEDS(gp)
    ret

delay:
    li t0, 1
    slli t0, t0, T
_l0_delay:
    beqz t0, _end_delay
    addi t0, t0, -1
    j _l0_delay
_end_delay:
    ret
