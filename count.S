T = 100_000

    li a0, 0

start:
    call delay
    addi a0, a0, 1

    j start

delay:
    li t0, T
loop:
    beqz t0, end
    addi t0, t0, -1
    j loop
end:
    ret

