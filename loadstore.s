A = 400
B = 800
slow_bit = 11

# Copy 16 bytes from adress A
# to address B

    li a0, 0
    li s1, 16
    li s0, 0

L0:
    lb a1, s0, A
    sb a1, s0, B
    call delay
    addi s0, s0, 1
    bne s0, s1, L0

    # Read 16 bytes from adress B
    li s0, 0
L1:
    lb a0, s0, B  # a0  is plugged to the LEDs
    call delay
    addi s0, s0, 1
    bne s0, s1, L1
    ebreak 

delay:
    li t0, 1
    slli t0, t0, slow_bit
L2:
    addi t0, t0, -1
    bnez t0, L2
    ret 