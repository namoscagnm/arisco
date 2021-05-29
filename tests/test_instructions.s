addi x31,x0,0           // STARTUP: Any test should pass if and only if x31 is zero
ADDI x21, x0, 123       // BEGIN:   Test ADDI start, setting expected value
ADDI x20, x0, 123
SUB x31, x20, x21       // END:     Control variable: X31 is zero if and only if circuit is correct. Finish test
addi x10,x0,1110        // BEGIN:   Test ADD start, setting expected value
addi x1,x0,555
addi x2,x0,555
add x3,x1,x2
sub x31,x3,x10          // END:     Control variable should be zero if passed
lui x1, 1               // BEGIN:   Tests LUI. 4096 is lui 1, because its the 13th bit (2^12)
addi x2,x0,2047         //          4096 = 2047+2047+2
addi x2,x2,2047
addi x2,x2,2
sub x31,x1,x2           // END:     Control variable: X31 has to be zero when 4096 - 4096 = 0
addi x1,x0,2047         // BEGIN:   Test negative numbers on ADDI
addi x31,x1,-2047       // END:     Control variable: X31 should be zero
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop