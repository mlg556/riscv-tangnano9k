IO = 0x400000
LEDS = IO+4

T = 100_000

setup:
    li gp, LEDS
    li a0, 0

loop:
    sw a0, 0(gp) # display
    addi a0, a0, 1
    call delay
    j loop


delay:
    li t0, T
_loop:
    beqz t0, _end
    addi t0, t0, -1
    j _loop
_end:
    ret
