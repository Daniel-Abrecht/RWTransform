# RWTransform
RWTransform is a C library for reading binary datas from files into c structs.

## Example

The following example shows how to define the bitmap file header structure using RWTransform.

```
#ifndef RW_MODE
  #include <stdint.h>
  #include <rw.hc>
#endif

#define STNAME bitmap_file_header

RW_BEGIN((
  endianess = RW_LITTLE_ENDIAN;
))

RW_SMEMBER( uint16_t, 1, magic_number )
RW_SMEMBER( uint32_t, 1, file_size )
RW_RESERVED( 4 )
RW_SMEMBER( uint32_t, 1, bmi_offset )

RW_END()
```

```
if( !parse_bitmap_file_header( &bfh, file, 0 ) ){
  printf( "%s\n", rw_getLastError() );
  return 0;
}

printf(
  "magic_number:\t %u %c%c\n"
  "file_size:\t %u\n"
  "bmi_offset:\t %u\n",
  (unsigned)bfh.magic_number,
  (bfh.magic_number>>0) & 0xFF,
  (bfh.magic_number>>8) & 0xFF,
  (unsigned)bfh.file_size,
  (unsigned)bfh.bmi_offset
);
```

## Macros

Macro      | Description
-----------|------------
STNAME     | Used as struct name, as typename with the suffix "\_t" and to declare a function to parse the file prefixed with "parse_"
RW_BEGIN   | Begins of struct definition, first argument is used to add code to the begin of the parse function
RW_SMEMBER | Defines a struct member, the arguments are  member type, number of members and membername
RW_RESERVED  RW_PADDING | Skip some bytes while parsing file
RW_END     | End of struct definition


## Functions

```
void rw_fixEndianes( void*, size_t size, size_t count, enum rw_endianess );
void rw_error( const char* message );
bool rw_isError( void );
void rw_resetError( void );
const char* rw_getLastError( void );
```

Name            | Description
----------------|------------
rw_fixEndianes  | Converts _count_ elements of size _size_ from specified endianess to host endianess
rw_error        | Sets a new errormessage
rw_isError      | Checks, if an error occured
rw_resetError   | Resets the error indicator and the last error message
rw_getLastError | Returns the message of the last error or NULL

## Variables avaiable in generated parse functions

Variable  | Description
----------|------------
endianess | Specifies the endianess of the datas to parse, is either RW_BIG_ENDIAN or RW_LITTLE_ENDIAN
p         | Third argument of generated parse function, array of void pointers. Can be used to pass additional argumnents to the function
_STNAME_  | First argument of generated parse function. expands to wathever STNAME is defined. pointer of type struct _STNAME_ 
