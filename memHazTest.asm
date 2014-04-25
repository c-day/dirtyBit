#summing test that should stress mem hazard detection

llb $1, 0x01
llb $2, 0x02
llb $3, 0x03
llb $4, 0x04
llb $5, 0x05
llb $6, 0x10    #expected result

add $1, $1, $1  # 1 + 1 = 2
add $1, $1, $2  # 2 + 2 = 4
add $1, $1, $3  # 4 + 3 = 7
add $1, $1, $4  # 7 + 4 = 11
add $1, $1, $5  # 11 + 5 = 16 = 0x10

sub $0, $1, $6
bne FAIL
llb $15, 0xFF
hlt

FAIL:
hlt