/*
Linker script for STM32F765ZG

FLASHITCM is read-only, so it's the VMA (runtime address)
FLASHAXI is the only way to write to internal flash memory, so it's the LMA (load address)
We use >FLASHITCM AT >FLASHAXI do to this


*/

ENTRY(Reset_Handler)

_estack = 0x20080000;    /* end of RAM */

/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0x100;      /* required amount of heap  */
_Min_Stack_Size = 0x1800; /* required amount of stack: max for one function is 0x1100 */

/* Specify the memory areas */
MEMORY
{
	/* This is for having mostly SRAM:
	DTCMRAM (xrw)	: ORIGIN = 0x20000000, LENGTH = 128K
	SRAM (xrw)		: ORIGIN = 0x20020000, LENGTH = 384K
	*/

	/* This is for using DTCM as main RAM:*/
	DTCMRAM (xrw)	: ORIGIN = 0x20000000, LENGTH = 128K	/*Everything goes in DTCM RAM by default*/
	SRAM1 (xrw)		: ORIGIN = 0x20020000, LENGTH = 384K	/*...unless specified to go in SRAM1*/


	FLASHAXI (rx)	: ORIGIN = 0x08010000, LENGTH = 1024K /* Start at Sector 2, which leaves space for params sector and for Bootloader sector*/
	FLASHITCM (rx)	: ORIGIN = 0x00210000, LENGTH = 1024K
}

/* To Do: Add ALIGN_WITH_INPUT to each .section-name : ALIGN_WITH_INPUT */

/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector : ALIGN_WITH_INPUT
  {
	. = ALIGN(4);
	KEEP(*(.isr_vector)) /* Startup code */
	. = ALIGN(4);
  } >FLASHITCM AT >FLASHAXI

  /* The program code and other data goes into FLASH */
  .text : ALIGN_WITH_INPUT
  {
	. = ALIGN(4);
	*(.text)           /* .text sections (code) */
	*(.text*)          /* .text* sections (code) */
	*(.glue_7)         /* glue arm to thumb code */
	*(.glue_7t)        /* glue thumb to arm code */
	*(.eh_frame)

	KEEP (*(.init))
	KEEP (*(.fini))

	. = ALIGN(4);
	_etext = .;        /* define a global symbols at end of code */
  } >FLASHITCM AT >FLASHAXI

  /* Constant data goes into FLASH */
  .rodata : ALIGN_WITH_INPUT
  {
	. = ALIGN(4);
	*(.rodata)         /* .rodata sections (constants, strings, etc.) */
	*(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
	. = ALIGN(4);
  } >FLASHITCM AT >FLASHAXI

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASHITCM AT >FLASHAXI

  .ARM : ALIGN_WITH_INPUT 
  {
	__exidx_start = .;
	*(.ARM.exidx*)
	__exidx_end = .;
  } >FLASHITCM AT >FLASHAXI

  .preinit_array     : ALIGN_WITH_INPUT
  {
	PROVIDE_HIDDEN (__preinit_array_start = .);
	KEEP (*(.preinit_array*))
	PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASHITCM AT >FLASHAXI
  .init_array :
  {
	PROVIDE_HIDDEN (__init_array_start = .);
	KEEP (*(SORT(.init_array.*)))
	KEEP (*(.init_array*))
	PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASHITCM AT >FLASHAXI

  .fini_array : ALIGN_WITH_INPUT
  {
	PROVIDE_HIDDEN (__fini_array_start = .);
	KEEP (*(SORT(.fini_array.*)))
	KEEP (*(.fini_array*))
	PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASHITCM AT >FLASHAXI

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data : ALIGN_WITH_INPUT
  {
	. = ALIGN(4);
	_sdata = .;        /* create a global symbol at data start */
	*(.data)           /* .data sections */
	*(.data*)          /* .data* sections */

	. = ALIGN(4);
	_edata = .;        /* define a global symbol at data end */
  } >DTCMRAM AT> FLASHAXI

  
  /* Uninitialized data section */
  . = ALIGN(4);
  .bss : ALIGN_WITH_INPUT
  {
	/* This is used by the startup in order to initialize the .bss secion */
	_sbss = .;         /* define a global symbol at bss start */
	__bss_start__ = _sbss;
	*(.bss)
	*(.bss*)
	*(COMMON)

	. = ALIGN(4);
	_ebss = .;         /* define a global symbol at bss end */
	__bss_end__ = _ebss;
  } >DTCMRAM

 /* DTCMRAM section, variables must be located here explicitly */
  /* Example: __attribute__ ((section (".sramdata"))) uint32_t foobar[99999]; */

  /* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack : ALIGN_WITH_INPUT
  {
	. = ALIGN(8);
	PROVIDE ( end = . );
	PROVIDE ( _end = . );
	. = . + _Min_Heap_Size;
	. = . + _Min_Stack_Size;
	. = ALIGN(8);
  } >DTCMRAM

  /* DTCM section, variables must be located here explicitly */
  /* Example: __attribute__ ((section (".dtcmdata"))) uint32_t foobar[99999]; */
 /*
  .dtcmdata (NOLOAD) :
  {
    . = ALIGN(16);
    *(.dtcmdata)
    . = ALIGN(16);
  } >DTCMRAM
*/

  .sram1data (NOLOAD) :
  {
    . = ALIGN(16);
    *(.sram1data)
    . = ALIGN(16);
  } >SRAM1


  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
	libc.a ( * )
	libm.a ( * )
	libgcc.a ( * )
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
