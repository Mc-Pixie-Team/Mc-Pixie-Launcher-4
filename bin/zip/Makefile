CC = clang
CFLAGS = -std=gnu99 -current_version 1.0 -compatibility_version 1.0 -fvisibility=hidden
SRC_FILES = pixie.c zip.c  # Add more source files if needed
OUTPUT = libRatings.A.dylib

all: $(OUTPUT)

$(OUTPUT): $(SRC_FILES)
	$(CC) -dynamiclib $(CFLAGS)  -o $@

clean:
	rm -f $(OUTPUT)
