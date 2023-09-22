/* everything is stored in BRAM. first code, then data*/
MEMORY
{
   BRAM (RWX) : ORIGIN = 0x0000, LENGTH = 0x8000  /* 32kB RAM */
}
SECTIONS
{
    .text : {
        . = ALIGN(4);
        start.o (.text*)
        *(.text*)
        *(.rodata*) 
        *(.srodata*)

    } > BRAM

    .data : {
        *(.data*)
        *(.sdata*)
    } > BRAM

    .bss : {
      *(.bss*)
      *(.sbss*)
    } > BRAM

}