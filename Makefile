CC = gcc
CFLAGS = -Wall -Wextra -Wpedantic -std=c11
INCLUDES = -I scripts/c/include

SRC = scripts/c/src/main.c scripts/c/src/logger.c scripts/c/src/utils.c
BIN = scripts/c/bin/rnaflow

.PHONY: all build run clean

all: build

build: $(BIN)

$(BIN): $(SRC)
	$(CC) $(CFLAGS) $(INCLUDES) $(SRC) -o $(BIN)

run: build
	./$(BIN)

clean:
	rm -f $(BIN)
