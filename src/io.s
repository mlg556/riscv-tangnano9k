# functions for UART TX/RX and GPIO LEDs

.equ IO_BASE, 0x400000
.equ IO_LEDS, 4
.equ IO_UART_TX, 8
.equ IO_UART_RX, 16
.equ IO_UART_CTRL, 32

.equ UART_CTRL_TX_DONE, 1
.equ UART_CTRL_RX_DONE, 2

.section .text

# remember gp is IO_BASE from start.s

.globl putchar
# Func: putchar
# Arg: a0 = character to send
putchar:
    # send char
    sw a0, IO_UART_TX(gp)
putchar_loop:
    lw t0, IO_UART_CTRL(gp)
    andi t0, t0, UART_CTRL_TX_DONE # isolate TX_DONE
    # UART_CTRL bit0 is set => tx done
    # so loop until done
    beqz t0, putchar_loop
    ret

.globl getchar
# Func: getchar
# Ret: a0 = character received
getchar:
    lw t0, IO_UART_CTRL(gp)
    andi t0, t0, UART_CTRL_RX_DONE # isolate RX_DONE
    beqz t0, getchar
    # read char
    lb a0, IO_UART_RX(gp)
    ret

# Func: putled
# a0: value to print to leds
.global putled
putled:
    sw a0, IO_LEDS(gp)
    ret

# decrement from 2^N until 0
.global sleep
sleep:
    li t0, 1
    sll a0, t0, a0 # a0 = 1 << a0
sleep_loop:
    addi a0, a0, -1
    bnez a0, sleep_loop
    ret
