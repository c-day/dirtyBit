llb R1, 0x01
llb R2, 0x02
llb R3, 0x03
llb R4, 0x04
llb R5, 0x05

llb R10, 0x00
lhb R10, 0x10  #R10 now has 0x1000

# do a lot of lw sw in a row
sw R0, R10, 0
sw R1, R10, 1
sw R2, R10, 2
sw R3, R10, 3
sw R4, R10, 4
sw R5, R10, 5

lw R6, R10, 5   #R6 holds 5
lw R7, R10, 4   #R7 holds 4
lw R8, R10, 3   #R8 holds 3
lw R9, R10, 2   #R9 holds 2
lw R11, R10, 1  #R11 holds 1
lw R12, R10, 0  #R12 holds 0

# make sure everything is correct
sub R0, R6, R5
bne FAIL
sub R0, R7, R4
bne FAIL
sub R0, R8, R3
bne FAIL
sub R0, R9, R2
bne FAIL
sub R0, R11, R1
bne FAIL
sub R0, R12, R0
beq DONE



FAIL:
llb R1, 0xFF

DONE:
llb R1, 0xAA
lhb R1, 0xAA
