# // Memory-mapped IO in IO page, 1-hot addressing in word address.   
# localparam IO_LEDS_bit = 0;  // W five leds
# localparam IO_UART_DAT_bit = 1;  // W data to send (8 bits) 
# localparam IO_UART_CNTL_bit = 2;  // R status. bit 9: busy sending

IO = 0x400000
LEDS = 4
UART_DAT = 8
UART_CNTL = 16

T = 20 # delay 2**T cycles, 2**20 ~ 1M

    tail setup # !!!

DATA:
    string hello

align 4

setup:
    li gp, IO
loop:
    li sp, 0

send:
    lb a0, DATA(sp)
    call putc
    call putled
    addi sp, sp, 1

    bnez a0, send
    call delay
    j loop


putc: # a0 is the 32-bit char
    # send char
    sw a0, UART_DAT(gp)
    # Read UART status (bit 9)
    li t0, 1<<9
_l0_putc:
    lw t1, UART_CNTL(gp)
    and  t1, t1, t0
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
