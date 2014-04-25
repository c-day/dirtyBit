#hazard test

llb $1, 0x08
llb $3, 0x10
llb $4, 0xF0
lhb $4, 0x00
llb $5, 0x08
llb $6, 0x07

sub $2, $1, $3      # $2 written to by sub ($2 = 8 = 0x10 - 0x08)
and $12, $2, $5     # $2 depends on sub (1st time) ($12 = 0)
or  $13, $6, $2     # $2 depends on sub (2nd time) ($13 = 0x0F = 0x07 | 0x08)
add $14, $2, $2     # depends on $2 1st and second time ($14 = 0x10)
sw  $6, 8($5)       # store 0x07 in mem location 0xF0
lw  $2, 8($2)       # expect to get 0x07

sub $0, $2, $6      # 0x07 - 0x07 = 0
bne FAIL
add $0, $12, $12    # 0 + 0 = 0 
bne FAIL
sub $0, $4, $13     # 0x0F - 0x0F = 0
bne FAIL

# set $1 to all F's WE WIN!
llb $1 0xFF
hlt

FAIL:
hlt
