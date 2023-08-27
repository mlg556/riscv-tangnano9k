################### riscv-tangnano9k ###################
# my tangnano9k has
# 8192 4-bytes words => 32768 B = 32KB (RAM + ROM)
# [0x0000 => 0x3FFF] ROM
# [0x4000 => 0x7FFF] RAM

ROM_BASE_ADDR = 0x0000
ROM_SIZE = 16*1024

RAM_BASE_ADDR = 0x4000
RAM_SIZE = 14*1024

# additional definitions for IO and UART base addresses

IO_BASE = 0x400000
LEDS = 4
UART_TX = 8
UART_RX = 16
UART_CTRL = 32

UART_CTRL_TX_DONE = 1
UART_CTRL_RX_DONE = 2

# serial functions from uart_echo.s

# Func: serial_init(a0: baud_rate)
# Arg: a0 = baud rate
# baud_rate currently fixed to 115_200
# so this does nothing
serial_init:
    ret

# Func: serial_getc
# Ret: a0 = character received
serial_getc:
    li t0, IO_BASE
serial_getc_loop:
    lw t1, UART_CTRL(t0)
    andi t1, t1, UART_CTRL_RX_DONE # isolate bit1
    # loop until bit1 is set
    beqz t1, serial_getc_loop
    # read char
    lw a0, UART_RX(t0)
    ret

# Func: serial_putc
# Arg: a0 = character to send
serial_putc:
    li t0, IO_BASE
    sw a0, UART_TX(t0) # send char
serial_putc_loop:
    lw t1, UART_CTRL(t0)
    andi t1, t1, UART_CTRL_TX_DONE # isolate bit0
    # loop until bit0 is set
    beqz t1, serial_putc_loop
    ret

####################################################