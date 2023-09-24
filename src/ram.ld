/* everything is stored in RAM. first code, then data*/
MEMORY
{
   RAM (RWX) : ORIGIN = 0x0000, LENGTH = 0x8000  /* 32kB RAM */
}
SECTIONS
{
    .text : {
        . = ALIGN(4);
        start.o (.text*)
        *(.text*)
        *(.rodata*) 
        *(.srodata*)

    } > RAM

    .data : {
        *(.data*)
        *(.sdata*)
    } > RAM

    .bss : {
      *(.bss*)
      *(.sbss*)
    } > RAM

}