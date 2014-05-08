#hazard test

llb R1, 0x08
llb R3, 0x10
llb R4, 0xF0
lhb R4, 0x00
llb R5, 0x08
llb R6, 0x07

sub R2, R1, R3      # R2 written to by sub (R2 = 8 = 0x10 - 0x08)
and R12, R2, R5     # R2 depends on sub (1st time) (R12 = 0)
or  R13, R6, R2     # R2 depends on sub (2nd time) (R13 = 0x0F = 0x07 | 0x08)
add R14, R2, R2     # depends on R2 1st and second time (R14 = 0x10)
sw  R6, R5, 8       # store 0x07 in mem location 0xF0
lw  R2, R2, 8       # expect to get 0x07

sub R0, R2, R6      # 0x07 - 0x07 = 0
bne FAIL
add R0, R12, R12    # 0 + 0 = 0
bne FAIL
sub R0, R4, R13     # 0x0F - 0x0F = 0
bne FAIL

# set R1 to all A's WE WIN!
llb R1, 0xAA
lhb R1, 0xAA
hlt

FAIL:
llb R1, 0xFF
hlt
