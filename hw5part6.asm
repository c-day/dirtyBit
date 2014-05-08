# Our objective here is to test some basic Read After Writes (RAW)
# and to also double check and make sure our branches/jumps are
# working properly

   # first we setup our registers
    LLB R14, 0x00
    LLB R13, 0x01
    LLB R1,  0x12
    LLB R2,  0x21

    # do our first add the W part of RAW
    ADD R3,  R2, R1      # we expect 0x33
    # no we do our R of RAW
    SW  R3,  R0, 0x1C    # we attempt to/expect to store 0x33
    LW  R4,  R0, 0x1C    # go get our expect 0x33 from 0x1C mem location
    SUB R5,  R4, R3      # we subtract what we hope to be 0x33-0x33 and set Z=1
    B NEQ, BAD

    # fall through if we pass
    ADD R14, R14, R13   # add one to R14 to know we passed this test
    HLT



BAD:
    HLT
