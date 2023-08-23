WORD = 4
DATA = 400
T = 500_000

# write 3,4,5
li t0, 3
li sp, 0
sw t0, DATA(sp)

li t0, 4
addi sp, sp, WORD
sw t0, DATA(sp)

li t0, 5
addi sp, sp, WORD
sw t0, DATA(sp)

# read to a0
loop:
    li sp, 0
    lw a0, DATA(sp)
    call delay

    addi sp, sp, WORD
    lw a0, DATA(sp)
    call delay

    addi sp, sp, WORD
    lw a0, DATA(sp)
    call delay
    j loop

ebreak

delay:
    li t0, T
.loop:
    beqz t0, .end
    addi t0, t0, -1
    j .loop
.end:
    ret