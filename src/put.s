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

.globl putstring

putstring:
	addi sp,sp,-4 # save ra on the stack
	sw ra,0(sp)   # (need to do that for functions that call functions)
	mv t2,a0	
.L2:    lbu a0,0(t2)
	beqz a0,.L3
	call putchar
	addi t2,t2,1	
	j .L2
.L3:    lw ra,0(sp)  # restore ra
	addi sp,sp,4 # resptore sp
	ret
