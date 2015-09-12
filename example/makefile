OPTIONS += -Wall -Werror -Wextra -pedantic
OPTIONS += -std=c11

SRC = ..

STRUCT_DIR = $(SRC)/struct

OPTIONS += -I$(STRUCT_DIR) -I$(SRC)/rw/

OBJECTS += $(STRUCT_DIR)/bitmap_file_header.o
OBJECTS += $(SRC)/rw/rw.o
OBJECTS += main.o

all: $(OBJECTS)
	gcc $^ -o main

%.o: %.c
	gcc $(OPTIONS) -c -o "$@" "$<"

%.o: %.struct
	gcc -x c $(OPTIONS) -DRW_CODEGEN="<$(shell basename $<)>" -c -o "$@" $(SRC)/rw/rw.hc

clean:
	rm -f $(shell find .. -iname "*.o")
