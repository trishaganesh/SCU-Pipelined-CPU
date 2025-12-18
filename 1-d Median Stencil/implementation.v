// BEFORE PROGRAM: x1 = n, x2 = &a, x3 = &b
        mem[0]   = 32'b00000000000000000000000000000111; // SUB x0, x0, x0 (set zero register)
        
        // Pre-loading label addresses using SVPC
        mem[1]   = 32'b00010001110101100000000000001111; // SVPC x22, 71  original: SVPC x22, 40   (start of a[i-1] < a[i] branch)
        mem[2]   = 32'b00001110100101110000000000001111; // SVPC x23, 58  original: SVPC x23, 33   (else-if a[i-1] >= a[i+1] in a[i-1] >= a[i] branch)
        mem[3]   = 32'b00010000010110000000000000001111; // SVPC x24, 65  original: SVPC x24, 36   (else b[i] = a[i-1] in that branch)
        mem[4]   = 32'b00010011000110010000000000001111; // SVPC x25, 76  original: SVPC x25, 41   (else-if a[i] >= a[i+1] in a[i-1] < a[i] branch)
        mem[5]   = 32'b00010100110110100000000000001111; // SVPC x26, 83  original: SVPC x26, 44   (else b[i] = a[i] in a[i-1] < a[i] branch)
        mem[6]   = 32'b00010100110110110000000000001111; // SVPC x27, 83  original: SVPC x27, 44   (end of main loop body, x5-- / decide continue)
        mem[7]   = 32'b00000101010111000000000000001111; // SVPC x28, 21  original: SVPC x28, 12   (top of loop: i++ location)
        mem[8]    = 32'b00011001100111100000000000001111;  // SVPC x30, 102  original: SVPC x30, 49   (end-of-program location)
        mem[9]   = 32'b00010110000111010000000000001111; // SVPC x29, 89  original: SVPC x29, 45   (start of b[n-1] = a[n-1] code)
        
        
        // check if n == 0
        mem[10]  = 32'b11111111110001010000010000000101; // INC x5, x1, -1   (x5 = n-1)
        mem[11]  = 32'b00000000000000000111100000001010; // BRN x30    (if n - 1 < 0, then exit (n == 0)
        mem[12]  = 32'b0; // NOP  (for fixing branch hazard)
        mem[13]  = 32'b0; // NOP  (for fixing branch hazard)
        
        // set b[0] = a[0]
        mem[14]  = 32'b00000000000001000000100000001110;  // LD  x4, x2, 0   (x4 = a[0])
        mem[15]  = 32'b0; // NOP (for fixing data hazard)
        mem[16]  = 32'b0; // NOP (for fixing data hazard)
        mem[17]  = 32'b0; // NOP (for fixing data hazard)
        mem[18]  = 32'b00000000000000000000110001000011; // ST  x4, x3, 0   (b[0] = a[0])
        
        mem[19]  = 32'b00000000000001100000000000000100; // ADD x6, x0, x0   (i = 0)
       
       // check if n == 1
        mem[20]  = 32'b11111111100001010000010000000101; // INC x5, x1, -2   (x5 = n-2)
        mem[21]  = 32'b00000000000000000111100000001010; // BRN x30   (if n == 1, exit since b[0] already set) 
        mem[22]  = 32'b0; // NOP  (for fixing branch hazard)
        mem[23]  = 32'b0; // NOP  (for fixing branch hazard)
        
        // check if n == 2
        mem[24]  = 32'b00000000000100000001010000000111; // SUB x16, x5, x0   (used to activate BRZ flag for n == 2)
        mem[25]  = 32'b00000000000000000111010000001001; // BRZ x29   (if n == 2, skip loop and go to location to set b[n-1]
        mem[26]  = 32'b0; // NOP  (for fixing branch hazard)
        mem[27]  = 32'b0; // NOP  (for fixing branch hazard)
        
        // START OF LOOP
            mem[28]  = 32'b00000000010001100001100000000101; // INC x6, x6, 1   (i++)
            mem[29]  = 32'b0; // NOP (for fixing data hazard)
            mem[30]  = 32'b0; // NOP (for fixing data hazard)
            mem[31]  = 32'b0; // NOP (for fixing data hazard)
            mem[32]  = 32'b11111111110001110001100000000101;  // INC x7, x6, -1   (x7 = i-1)
            mem[33]  = 32'b00000000010010000001100000000101;  // INC x8, x6, 1    (x8 = i+1)
            mem[34]  = 32'b0; // NOP (for fixing data hazard)
            mem[35]  = 32'b0; // NOP (for fixing data hazard)
            mem[36]  = 32'b0; // NOP (for fixing data hazard)
            
             // compute addresses for a[i-1], a[i], a[i+1]
            mem[37]  = 32'b00000000000010010001110000100100;  // ADD x9,  x7, x2   (x9 = &a[i-1])
            mem[38]  = 32'b00000000000010100001100000100100;   // ADD x10, x6, x2  (x10 = &a[i])
            mem[39]  = 32'b0; // NOP (for fixing data hazard)
            mem[40]  = 32'b0; // NOP (for fixing data hazard)
            mem[41]  = 32'b0; // NOP (for fixing data hazard)
            mem[42]  = 32'b00000000000010110010000000100100; // ADD x11, x8, x2   (x11 = &a[i+1])
            mem[43]  = 32'b00000000000011000001100000110100; // ADD x12, x6, x3   (x12 = &b[i])
            
            // load a[i-1], a[i], a[i+1]
            mem[44]  = 32'b00000000000011010010010000001110; // LD  x13, x9, 0    (x13 = a[i-1])
            mem[45]  = 32'b00000000000011100010100000001110; // LD  x14, x10, 0   (x14 = a[i])
            mem[46]  = 32'b00000000000011110010110000001110; // LD  x15, x11, 0   (x15 = a[i+1])
            mem[47]  = 32'b0; // NOP (for fixing data hazard)
            
            // NOTE: BRN -> branch if (X < Y)
            
            // if a[i-1] >= a[i]
            mem[48]  = 32'b00000000000100000011010011100111; // SUB x16, x13, x14   (if a[i-1] - a[i] is negative it'll activate N flag)
            mem[49]  = 32'b00000000000000000101100000001010; // BRN x22   (branch if a[i-1] < a[i] (condition false))
            mem[50]  = 32'b0; // NOP  (for fixing branch hazard)
            mem[51]  = 32'b0; // NOP  (for fixing branch hazard)
                // if a[i] >= a[i+1]
                mem[52]  = 32'b00000000000100000011100011110111; // SUB x16, x14, x15   (if a[i] - a[i+1] is negative it'll activate N flag)
                mem[53]  = 32'b00000000000000000101110000001010; // BRN x23   (branch if a[i] < a[i+1])
                mem[54]  = 32'b0; // NOP  (for fixing branch hazard)
                mem[55]  = 32'b0; // NOP  (for fixing branch hazard)
                    mem[56]  = 32'b00000000000000000011000011100011; // ST  x14, x12, 0   (b[i] = a[i])
                    mem[57]  = 32'b00000000000000000110110000001000; // J x27   (jump to loop-exit / x5-- location)
                    mem[58]  = 32'b0; // NOP  (for fixing branch hazard) 
                    mem[59]  = 32'b0; // NOP  (for fixing branch hazard)
                // else if a[i-1] >= a[i+1]
                mem[60]  = 32'b00000000000100000011010011110111; // SUB x16, x13, x15   (if a[i-1] - a[i+1] is negative it'll activate N flag)
                mem[61]  = 32'b00000000000000000110000000001010; // BRN x24   (branch if a[i-1] < a[i+1])
                mem[62]  = 32'b0; // NOP  (for fixing branch hazard) 
                mem[63]  = 32'b0; // NOP  (for fixing branch hazard) 
                    mem[64]  = 32'b00000000000000000011000011110011; // ST  x15, x12, 0   (b[i] = a[i+1])
                    mem[65]  = 32'b00000000000000000110110000001000; // J x27
                    mem[66]  = 32'b0; // NOP  (for fixing branch hazard) 
                    mem[67]  = 32'b0; // NOP  (for fixing branch hazard) 
                // else
                mem[68]  = 32'b00000000000000000011000011010011; // ST  x13, x12, 0   (b[i] = a[i-1])
                mem[69]  = 32'b00000000000000000110110000001000; // J x27
                mem[70]  = 32'b0; // NOP  (for fixing branch hazard) 
                mem[71]  = 32'b0; // NOP  (for fixing branch hazard) 
            // else
                // if a[i-1] >= a[i+1]
                mem[72]  = 32'b00000000000100000011010011110111; // SUB x16, x13, x15   (if a[i-1] - a[i+1] is negative it'll activate N flag)
                mem[73]  = 32'b00000000000000000110010000001010; // BRN x25   (branch if a[i-1] < a[i+1])
                mem[74]  = 32'b0; // NOP  (for fixing branch hazard)
                mem[75]  = 32'b0; // NOP  (for fixing branch hazard)
                    mem[76]  = 32'b00000000000000000011000011010011; // ST x13, x12, 0   (b[i] = a[i-1])
                    mem[77]  = 32'b00000000000000000110110000001000; // J x27
                    mem[78]  = 32'b0; // NOP  (for fixing branch hazard)
                    mem[79]  = 32'b0; // NOP  (for fixing branch hazard)
                // else if a[i] >= a[i+1]
                mem[80]  = 32'b00000000000100000011100011110111; // SUB x16, x14, x15   (if a[i] - a[i+1] is negative it'll activate N flag)
                mem[81]  = 32'b00000000000000000110100000001010; // BRN x26   (branch if a[i] < a[i+1])
                mem[82]  = 32'b0; // NOP  (for fixing branch hazard)
                mem[83]  = 32'b0; // NOP  (for fixing branch hazard)
                    mem[84]  = 32'b00000000000000000011000011110011; // ST x15, x12, 0 (b[i] = a[i+1])
                    mem[85]  = 32'b00000000000000000110110000001000; // J x27
                    mem[86]  = 32'b0; // NOP  (for fixing branch hazard)
                    mem[87]  = 32'b0; // NOP  (for fixing branch hazard)
                // else
                mem[88]  = 32'b00000000000000000011000011100011; // ST  x14, x12, 0   (b[i] = a[i])
                
            mem[89]  = 32'b11111111110001010001010000000101; // INC x5, x5, -1   (x5--)
            mem[90]  = 32'b0; // NOP (for fixing data hazard)
            mem[91]  = 32'b0; // NOP (for fixing data hazard)
            mem[92]  = 32'b0; // NOP (for fixing data hazard)
            // if result is negative, then x5 > 0, so keep running the loop
            mem[93]  = 32'b00000000000100010000000001010111; // SUB x17, x0, x5
            mem[94]  = 32'b00000000000000000111000000001010; // BRN x28   (if result negative, then x5 > 0, so go to top of loop and loop again)
            mem[95]  = 32'b0; // NOP  (for fixing branch hazard) 
            mem[96]  = 32'b0; // NOP  (for fixing branch hazard) 
        
        // b[n-1] = a[n-1]
        mem[97]  = 32'b11111111110100100000010000000101; // INC x18, x1, -1   (x18 = n-1)
        mem[98]  = 32'b0; // NOP (for fixing data hazard)
        mem[99]  = 32'b0; // NOP (for fixing data hazard)
        mem[100] = 32'b0; // NOP (for fixing data hazard)
        mem[101] = 32'b00000000000100110000100100100100; // ADD x19, x2, x18   (x19 = &a[n-1])
        mem[102] = 32'b00000000000101000000110100100100; // ADD x20, x3, x18   (x20 = &b[n-1])
        mem[103] = 32'b0; // NOP (for fixing data hazard)
        mem[104] = 32'b0; // NOP (for fixing data hazard)
        mem[105] = 32'b00000000000101010100110000001110; // LD  x21, x19, 0   (x21 = a[n-1])
        mem[106] = 32'b0; // NOP (for fixing data hazard)
        mem[107] = 32'b0; // NOP (for fixing data hazard)
        mem[108] = 32'b0; // NOP (for fixing data hazard)
        mem[109] = 32'b00000000000000000101000101010011; // ST  x21, x20, 0   (b[n-1] = a[n-1])
        mem[110] = 32'b00000000000000000000000000000000; // NOP   (original end of program marker)
        
        // NEG instruction demo (not part of median stencil but still required to demo)
        mem[111] = 32'b00000000001000110000110000000110;  // NEG x35, x3  (x35 = -x3 = -71)
