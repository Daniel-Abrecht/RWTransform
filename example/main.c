#include <bitmap_file_header.struct>

int main(){

  const char* filename = "image.bmp";

  FILE* file = fopen( filename, "rb" );

  if( !file ){
    printf( "Failed to open file \"%s\"\n", filename );
    return 0;
  }

  bitmap_file_header_t bfh;

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

  fclose( file );
  return 0;
}
