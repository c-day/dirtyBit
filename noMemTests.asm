################################################################################
# Craig Day
# ECE 552
# WISC architecture test bench
# 
# All tests are perfomed assuming that LLB, SUB, and B EQ work properly
################################################################################

#   We will use R14 as the accumulator register to track how far we are

    LLB R14, 0x00       # init our accumulator
    LLB R13, 0x01       # we need a register to add one don't we? No immd here! 
    
T_ADD:                  # test the ADD and SUB operations
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 1
    LLB R5, 0x05        # R5 <= 0x0005
    LLB R1, 0x05        # R1 <= 0x0005
    LLB R2, 0x07        # R2 <= 0x0007
    LLB R3, 0x0C        # R3 <= 0x000C
    ADD R1, R1, R2      
    SUB R0, R1, R3
    B EQ, T_ADDZ        # if R1 == R3, test passed
    HLT                 # test failed

T_ADDZ:                 # test the ADDZ opperation (does not do addtion as z flag not set)
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 2
    LLB R5, 0x07        # R5 <= 0x0007
    LLB R1, 0x02        # R1 <= 0x0002
    LLB R2, 0x01        # R2 <= 0x0001
    ADD R0, R1, R2      # clear the Z flag
    LLB R1, 0x72        # R1 <= 0x0072
    LLB R2, 0x22        # R2 <= 0x0072
    LLB R3, 0x72        # R3 <= 0x0072
    ADDZ R1, R1, R2
    SUB R0, R1, R3
    B EQ, T_AND
    HLT

T_AND:                  # test the AND operation
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 3
    LLB R1, 0xFF        # R1 <= 0xFFFF
    AND R1, R1, R0      # R1 <= 0xFFFF & 0x0000
    SUB R0, R1, R0      # set flags with R1 - 0
    B EQ, T_NOR         # if R1 == 0, test passed
    HLT                 # if we are here, the AND test failed, halting

T_NOR:                  # test the NOR operation
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 4
    LLB R5, 0x01
    LLB R1, 0x85        # R1 <= 0x0005
    LLB R2, 0x86        # R2 <= 0x0006
    LLB R3, 0x78        # R3 <= 0x0008
    NOR R4, R1, R2      # R1 <= ~(R1 | R2)
    SUB R0, R4, R3
    B EQ, T_SLL         # if R1 == R3, test passed
    HLT                 # if we get here, test NOR failed, halting 

T_SLL:                  # test logical shift left, SLL
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 5
    LLB R5, 0x02
    LLB R1, 0x07        # R1 <= 0x0007
    LLB R2, 0x70        # R2 <= 0x0070
    SLL R1, R1, 4       # R1 <= R1 << 4
    SUB R0, R1, R2      # compare R1 and R2, should be equal and set Z
    B EQ, T_SRL         # if R1 == R2, test SLL passed
    HLT                 # if we get here, the SLL test failed, halting

T_SRL:                  # test logical shift right, SRL
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 6
    LLB R5, 0x03
    LLB R1, 0x70
    LLB R2, 0x07
    SRL R1, R1, 4
    SUB R0, R1, R2
    B EQ, T_SRA         # R1 == R2, test passed
    HLT                 # test failed

T_SRA:                  # test arithmatic shift right, SRA
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 7
    LLB R5, 0x04
    LLB R1, 0xF0
    LLB R2, 0xFF
    SRA R1, R1, 4
    SUB R0, R1, R2      
    B EQ, T_LHB         # if R1 == R2, test passed
    HLT                 # test failed

T_LHB:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 8
    LLB R5, 0x09
    LLB R1, 0x00
    LLB R2, 0xBC
    SLL R2, R2, 8
    LHB R1, 0xBC
    SUB R0, R1, R2
    B EQ, T_B_UNCOND    # if R1 == R2, test passed
    HLT                 # test failed

    #well we know, or at least hope, that B EQ has worked so lets try the others
T_B_UNCOND:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 9
    B UNCOND,  T_NEQ

T_NEQ:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 10
    LLB R5, 0x09
    LLB R1, 0x08
    SUB R0, R5, R1
    B NEQ, T_GT
    HLT

T_GT:   #9-8 is > 0 so we can just use the flags set above
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 11
    B GT, T_GTE
    HLT

T_GTE:  #Test the greater part of GTE
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 12
    B GTE, T_GTE2
    HLT

T_GTE2: #Test equal part of GTE
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 13
    LLB R9, 0x55
    SUB R0, R9, R9
    B GTE, T_LTE
    HLT

T_LTE:  #Test equal part of LTE
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 14
    SUB R0, R9, R9
    B LTE, T_LTE2
    HLT

T_LTE2: #Test less than part of LTE
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 15
    SUB R0, R1, R5  #8-9 < 0
    B LT, T_LT
    HLT

T_LT:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 16
    SUB R0, R1, R5  #8-9 < 0
    B LT, T_OVFL
    HLT

T_OVFL:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 17
    LLB R5, 0xFF    #sign extended on load to 0xFFFF
    LHB R5, 0x7F
    LLB R1, 0x01
    ADD R9, R1, R5
    B OVFL, T_ADD_SatPOV
    HLT
    
# end of basic test

###############################################################################

# we now begin edge cases begining with saturation

T_ADD_SatPOV:           # test overflowing positivly with addition
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 18
    LLB R4, 0xFD
    LHB R4, 0x7F        # load in 0x7FFD
    LLB R5, 0x06        # load in 0x0006
    ADD R0, R4, R5
    B OVFL, T_ADD_SatNOV
    HLT
    
T_ADD_SatNOV:           # test adding overflowing negativly with addition
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 19
    LLB R4, 0x00
    LHB R4, 0x80        # load in 0x8000
    LLB R5, 0xF1        # load in 0xFFF1
    ADD R0, R4, R5
    B OVFL, T_SUB_SatPOV
    HLT
    
T_SUB_SatPOV:           # test positive overflow with subtraction (pos) - (neg)
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 20
    LLB R4, 0xFF
    LHB R4, 0x7F        # load in 0x7FFF
    LLB R5, 0xFF        # load in 0xFFFF
    SUB R0, R4, R5
    B OVFL, T_SUB_SatNOV
    HLT
    
T_SUB_SatNOV:           # test negative overflow with subtraction (neg) - (pos)
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 21
    LLB R4, 0x00
    LHB R4, 0x80        # load in 0x8000
    LLB R5, 0xF1        
    LHB R5, 0x7F        # load in 0x7FF1
    SUB R0, R4, R5
    B OVFL, T_DONT_BRANCH
    HLT

###############################################################################
  # now we test the branch not taken
  
T_DONT_BRANCH:          # set Z = 1 and hope it doesn't take the branch
    ADD R14, R14, R13   # add one to the accumulator    Current Val:  22
    ADD R0,  R0, R0
    B NEQ, FAIL
    
    ADD R14, R14, R13   # test eq with Z=0 and accumualte Current Val: 23
    B EQ, FAIL
    
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 24
    ADD R0, R0, R0     # set Z = 1
    B GT, FAIL
    
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 25
    SUB R0, R0, R14     # set N = 1
    B GT, FAIL
    
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 26
    SUB R0, R0, R14     # set N = 1
    B GTE, FAIL
    
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 27
    B LT, FAIL
    
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 28
    B LTE, FAIL
    
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 29
    B OVFL, FAIL        # sure hope we havne't overflowed by now
    
    # We can't NOT uncond branch so...
    B UNCOND, T_SW

FAIL:                   # u dun goufdd
      HLT
###############################################################################      
  
T_SW:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 30
    LLB R1, 0x05
    LLB R2, 0x22
    SW  R1, R2, 2       # store 0x05 into 0x22 + 2 (0x24)
    
T_LW:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: 31
    LLB R3, 0x05
    LLB R2, 0x26
    
    LW  R10, R2, -2      # load 0x05(hoepfully) into 0x26 - 2 (0x24)
    SUB R11, R10, R3
    B EQ, T_ADDZ2
    HLT

###############################################################################
    
T_ADDZ2:                # this addz should do addition
    ADD R14, R14, R13   # add one to the accumulator    Current Val: ?
    LLB R5, 0x08
    SUB R0, R0, R0      # set the Z flag
    LLB R1, 0x52
    LLB R2, 0x22
    LLB R3, 0x74
    ADDZ R1, R1, R2     
    SUB R0, R1, R3
    B EQ, T_JAL         # if R1 == R3, test passed
    HLT                 # test failed



###############################################################################

# test JAL and JR last
    
T_JAL:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: ?
    JAL T_JUMP          # jump to "a function" and set return value
    
DONE:
    ADD R14, R14, R13   # add one to the accumulator    Current Val: ?
    LLB R5, 0xAA
    LHB R5, 0xAA        # set R5 = 0xAAAA to signify all tests passed
    HLT

T_JUMP: 
    ADD R14, R14, R13   # add one to the accumulator    Current Val: ?
    LLB R11, 0xAD
    LHB R11, 0xDE       # put something in a register so we know we made it here
    JR  R15             # return to one after the jal ie done