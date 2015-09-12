#include <rw.hc>

#define endianess ((enum rw_endianess)*(const char*)(const int[]){1})
static const char* lastError = 0;

void rw_fixEndianes( void* mem, size_t size, size_t count, enum rw_endianess e ){
  if( endianess != e ){
    char* start = mem;
    char* end   = start + size*count + 1 - size;
    for( char* it=start; it<end; it += size )
      for( size_t i=0; i<size/2; i++ ){
        char tmp = it[i];
        it[i] = it[size-i-1];
        it[size-i-1] = tmp;
      }
  }
}

void rw_error( const char* message ){
  lastError = message;
}

bool rw_isError( void ){
  return lastError;
}

void rw_resetError( void ){
  lastError = 0;
}

const char* rw_getLastError( void ){
  return lastError;
}
