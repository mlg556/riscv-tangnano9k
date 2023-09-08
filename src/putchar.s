.equ IO_BASE, 0x400000
.equ IO_LEDS, 4
.equ IO_UART_TX, 8
.equ IO_UART_RX, 16
.equ IO_UART_CTRL, 32

.equ UART_CTRL_TX_DONE, 1
.equ UART_CTRL_RX_DONE, 2

.section .text
.globl putchar

# remember gp is already loaded with IO_BASE

# Func: putchar
# Arg: a0 = character to send
putchar:
    # send char
    sw a0, IO_UART_TX(gp)

.L0:
    lw t0, IO_UART_CTRL(gp)
    andi t0, t0, UART_CTRL_TX_DONE # isolate bit0
    # UART_CTRL bit0 is set => tx done
    # so loop until done
    beqz t0, .L0
    ret
