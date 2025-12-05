// GROUP: NAT (Andrew Vattuone, Nico Villegas-Kirchman, Trisha Ganesh)
// ASSUME: x1 = n, x2 = &a, x3 = &b
SUB x0, x0, x0    // set zero register

//Pre-loading label addresses using SVPC
SVPC x22, 40 // start of the a[i-1] < a[i] branch
SVPC x23, 33 // else if a[i-1] >= a[i+1] line in a[i-1] >= a[i] branch
SVPC x24, 36 // else b[i] = a[i-1] line in a[i-1] >= a[i] branch
SVPC x25, 41 // else if a[i] >= a[i+1] line in a[i-1] < a[i] branch
SVPC x26, 44 // else b[i] = a[i] line in a[i-1] < a[i] branch
SVPC x27, 44 // end of main loop body (x5-- line, determine if continue)
SVPC x28, 12 // top of loop (i++ location)
SVPC x29, 45 // start of b[n-1] = a[n-1] location
SVPC x30, 49 // end of program

// check if n == 0
INC x5, x1, -1    // x5 = n-1
BRN x30           // if n - 1 <0, then exit (n==0)

// set b[0] = a[0]
LD x4, x2, 0
ST x4, x3, 0

ADD x6, x0, x0      // i = 0

// check if n == 1
INC x5, x1, -2     // x5 = n-2
BRN x30            // n == 1, so exit since b[0] already set

// check if n == 2
SUB x16,x5,x0     // used to activate BRZ flag
BRZ x29           // n == 2, so skip loop and go to location to set b[n-1]

// START OF LOOP
    INC x6, x6, 1      // i++
    INC x7, x6, -1     // calculate i - 1
    INC x8, x6, 1      // calculate i + 1
    ADD x9, x7, x2     // calculate location of a[i-1]
    ADD x10, x6, x2    // calculate location of a[i]
    ADD x11, x8, x2    // calculate location of a[i+1]
    ADD x12, x6, x3    // calculate location of b[i]

    // load values for a[i-1], a[i], and a[i+1]
    LD x13, x9, 0
    LD x14, x10, 0
    LD x15, x11, 0


    // NOTE: BRN -> branch if (X < Y)

    // if a[i-1] >= a[i]
    SUB x16, x13, x14
    BRN x22   // branch if condition is false
  // if a[i] >= a[i+1]                   
        SUB x16, x14, x15
        BRN x23  // branch if condition is false             
            ST x14, x12, 0    // b[i] = a[i]
            J x27
        // else if a[i-1] >= a[i+1]
        SUB x16, x13, x15
        BRN x24  // branch if condition is false          
            ST x15, x12, 0    // b[i] = a[i+1]
            J x27
        // else
  ST x13, x12, 0        // b[i] = a[i-1]
        J x27
    // else
	  // if a[i-1] >= a[i+1]
        SUB x16, x13, x15
        BRN x25   // branch if condition is false
            ST x13, x12, 0    // b[i] = a[i-1]
            J x27
	  // else if a[i] >= a[i+1]
        SUB x16, x14, x15
        BRN x26  // branch if condition is false
            ST x15, x12, 0    // b[i] = a[i+1]
            J x27
	  // else
        ST x14, x12, 0        // b[i] = a[i]

    INC x5, x5, -1     // x5--
    // if result is negative, then x5 > 0, so keep running the loop
    SUB x16, x0, x5
    BRN x28             // go to top of loop

// b[n-1] = a[n-1]
INC x18, x1, -1
ADD x19, x2, x18
ADD x20, x3, x18
LD x21, x19, 0
ST x21, x20, 0

NOP // represents end of program

