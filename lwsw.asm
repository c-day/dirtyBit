llb R1, 0x01
llb R2, 0x02
llb R3, 0x03
llb R4, 0x04
llb R5, 0x05
llb R10, 0x00
lhb R10, 0x10

#load multiple values into R10 to make sure store word is workin
sw R10, R1, 0
sw R10, R2, 0
sw R10, R3, 0
sw R10, R4, 0
sw R10, R5, 0
lw R7, R10, 0

sw R10, R5, 0
sw R10, R4, 0
sw R10, R3, 0
sw R10, R2, 0
sw R10, R1, 0
sw R10, R5, 0
lw R6, R10, 0

sub R0, R6, R7
b neq, FAIL
llb R1, 0xAA
lhb R1, 0xAA
hlt

FAIL:
llb R1, 0xFF
