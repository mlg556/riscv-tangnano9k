\ duplicate the item on top of the stack

: dup sp@ @ ;
: -1 dup dup nand dup dup nand nand ;

: 0 -1 dup nand ;
: 1 -1 dup + dup nand ;
: 2 1 1 + ;
: 3 2 1 + ;
: 4 2 2 + ;
: 5 4 1 + ;
: 6 4 2 + ;
: 7 4 3 + ;
: 8 4 4 + ;
: 9 8 1 + ;
: 10 8 2 + ;
: 11 8 3 + ;
: 12 8 4 + ;
: 13 12 1 + ;
: 14 12 2 + ;
: 15 12 3 + ;
: 16 12 4 + ;
: 17 16 1 + ;
: 18 16 2 + ;
: 19 16 3 + ;
: 20 16 4 + ;
: 21 20 1 + ;
: 22 20 2 + ;
: 23 20 3 + ;
: 24 20 4 + ;
: 25 24 1 + ;
: 26 24 2 + ;
: 27 24 3 + ;
: 28 24 4 + ;
: 29 28 1 + ;
: 30 28 2 + ;
: 31 28 3 + ;
: 32 28 4 + ;

\ inversion and negation
: invert dup nand ;
: negate invert 1 + ;
: - negate + ;

\ stack manipulation words
: drop dup - + ;
: over sp@ 4 - @ ;
: swap over over sp@ 12 - ! sp@ 4 - ! ;
: nip swap drop ;
: 2dup over over ;
: 2drop drop drop ;

\ logic operators
: and nand invert ;
: or invert swap invert and invert ;

\ equality checks
: = - 0= ;
: <> = invert ;

\ left shift operators (1, 4, and 8 bits)
: 2* dup + ;
: 16* 2* 2* 2* 2* ;
: 256* 16* 16* ;

\ basic binary numbers
: 0b00 0 ;
: 0b01 1 ;
: 0b10 2 ;
: 0b11 3 ;
: 0b1111 15 ;
