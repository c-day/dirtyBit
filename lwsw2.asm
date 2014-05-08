llb R1, 0x01
llb R2, 0x10
llb R3, 0x11

llb R4, 0x0F
llb R5, 0x01

llb R10, 0x00
lhb R10, 0x10

loop:
#switch R1 and R2
sw R1, R10, 0
sw R2, R10, 1
lw R1, R10, 1
lw R2, R10, 0

#check to see if R1 and R2 still add up to R3
add R6, R1, R2
sub R0, R6, R3
b neq, FAIL

#increment R1 and decrement R2
add R1, R1, R5
sub R2, R2, R5

#check to see if loop is done
sub R4, R4, R5
b neq, loop


FAIL:
llb R1, 0xFF
hlt

DONE:
llb R1, 0xAA
lhb R1, 0xAA
hlt