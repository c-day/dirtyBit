#summing test that should stress mem hazard detection

llb R1, 0x01
llb R2, 0x02
llb R3, 0x03
llb R4, 0x04
llb R5, 0x05
llb R6, 0x10    #expected result

add R1, R1, R1  # 1 + 1 = 2
add R1, R1, R2  # 2 + 2 = 4
add R1, R1, R3  # 4 + 3 = 7
add R1, R1, R4  # 7 + 4 = 11
add R1, R1, R5  # 11 + 5 = 16 = 0x10

sub R0, R1, R6
bne FAIL
llb R1, 0xAA
hlt

FAIL:
llb R1, 0xFF
hlt
