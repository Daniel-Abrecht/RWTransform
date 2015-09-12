#ifndef RW_H
#define RW_H

  #include <stdio.h>
  #include <stddef.h>
  #include <stdbool.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

  #define RW_BEGIN RW_E( RW_BEGIN_, RW_MODE )
  #define RW_END RW_E( RW_END_, RW_MODE )

  #define RW_CVMEMBER( CONDITION, TYPE, COUNT, NAME ) \
    RW_E( RW_CONDITIONAL_MEMBER_VAR_, RW_MODE)( CONDITION, NAME )

  #define RW_SMEMBER( TYPE, COUNT, NAME ) \
    RW_E( RW_STATIC_MEMBER_, RW_MODE )( TYPE, COUNT, NAME )

  #define RW_CMEMBER( CNAME, TYPE, COUNT, NAME ) \
    RW_E( RW_CONDITIONAL_MEMBER_, RW_MODE )( CNAME, TYPE, COUNT, NAME )

  #define RW_RESERVED( SIZE ) RW_PADDING( SIZE )
  #define RW_PADDING( SIZE ) \
    RW_E( RW_PADDING_, RW_MODE )( SIZE )

///////////////////////////////////////////////////////////////////////////////////////////////////

  #define RW_CONCAT( X, Y ) X ## Y
  #define RW_E( X, Y ) RW_CONCAT( X, Y )
  #define RW_STR2( X ) #X
  #define RW_STR( X ) RW_STR2( X )
  #define RW_UNPACK( ... ) __VA_ARGS__

///////////////////////////////////////////////////////////////////////////////////////////////////

  #define RW_BEGIN_RW_DECLARATION( CODE ) \
    struct STNAME; \
    bool RW_E( parse_, STNAME )( struct STNAME* STNAME, FILE* file, void* p[] ); \
    typedef struct STNAME {

  #define RW_END_RW_DECLARATION() \
    } RW_E( STNAME, _t );


  #define RW_BEGIN_RW_DEFINE_PARSE_FUNCTION( CODE ) \
    bool RW_E( parse_, STNAME )( struct STNAME* STNAME, FILE* file, void* p[] ){ \
      enum rw_endianess endianess = RW_BIG_ENDIAN; \
      RW_UNPACK CODE \
      (void)p; \
      (void)endianess;

  #define RW_END_RW_DEFINE_PARSE_FUNCTION() \
    return true; \
    error: { \
       /* Error handling */\
    } \
    return false;\
  }


  #define RW_CONDITIONAL_MEMBER_VAR_RW_DEFINE_PARSE_FUNCTION( ... )
  #define RW_CONDITIONAL_MEMBER_VAR_RW_WRITE( ... )
  #define RW_CONDITIONAL_MEMBER_VAR_RW_DECLARATION( CONDITION, NAME ) \
    bool NAME;


  #define RW_CONDITIONAL_MEMBER_RW_DECLARATION( CNAME, TYPE, COUNT, NAME ) \
    RW_STATIC_MEMBER_RW_DECLARATION( TYPE, COUNT, NAME )

  #define RW_CONDITIONAL_MEMBER_RW_DEFINE_PARSE_FUNCTION( CNAME, TYPE, COUNT, NAME ) \
    if( CONDITION ){ \
      RW_STATIC_MEMBER_RW_DEFINE_PARSE_FUNCTION( TYPE, COUNT, NAME ) \
    }


  #define RW_STATIC_MEMBER_RW_DECLARATION( TYPE, COUNT, NAME ) \
    union { \
      TYPE NAME; \
      TYPE a_ ## NAME[COUNT]; \
    };

  #define RW_STATIC_MEMBER_RW_DEFINE_PARSE_FUNCTION( TYPE, COUNT, NAME ) \
    if( fread( STNAME->a_ ## NAME, sizeof(TYPE), COUNT, file ) < COUNT ){ \
      rw_error( \
        feof( file ) \
          ? "Unexpected end of file while reading member " #TYPE " " #NAME "[" #COUNT "] of " RW_STR(STNAME) \
          : "Failed to read member " #TYPE " " #NAME "[" #COUNT "] of " RW_STR(STNAME) \
      ); \
      goto error; \
    } \
    rw_fixEndianes( STNAME->a_ ## NAME, sizeof(TYPE), COUNT, endianess );


  #define RW_PADDING_RW_DECLARATION( SIZE )
  #define RW_PADDING_RW_DEFINE_PARSE_FUNCTION( SIZE ) \
    if( fseek( file, SIZE, SEEK_CUR ) ){ \
      rw_error( \
        feof( file ) \
          ? "Unexpected end of file while skiping padding of size " #SIZE " in " RW_STR(STNAME) \
          : "Failed to skip padding of size " #SIZE " in " RW_STR(STNAME) \
      ); \
      goto error; \
    }

///////////////////////////////////////////////////////////////////////////////////////////////////

  enum rw_pass {
    RW_DECLARATION,
    RW_DEFINE_PARSE_FUNCTION
  };

  enum rw_endianess {
    RW_BIG_ENDIAN,
    RW_LITTLE_ENDIAN
  };

//////////////////////////////////////////////////////////////////////////////////////////////////

  void rw_fixEndianes( void*, size_t size, size_t count, enum rw_endianess );
  void rw_error( const char* message );
  bool rw_isError( void );
  void rw_resetError( void );
  const char* rw_getLastError( void );

#endif

///////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef RW_CODEGEN
  #ifndef RW_CODEGEN_ACTIVE

    #define RW_CODEGEN_ACTIVE
    #ifdef STNAME
      #undef STNAME
    #endif

    #ifdef RW_MODE
      #undef RW_MODE
    #endif
    #include RW_CODEGEN

    #undef STNAME

    #undef RW_MODE
    #define RW_MODE RW_DEFINE_PARSE_FUNCTION
    #include RW_CODEGEN

  #else

    #ifndef RW_MODE
      #define RW_MODE RW_DECLARATION
    #endif

  #endif
#else

  #ifdef RW_MODE
    #undef RW_MODE
  #endif
  #define RW_MODE RW_DECLARATION

  #ifdef STNAME
    #undef STNAME
  #endif

#endif
