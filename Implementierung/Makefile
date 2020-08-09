# Optimize lvl 3, turn on extra warnings
CFLAGS=-O3 -g -Wall -Wextra -no-pie

.PHONY: all
all: main

main: main.c -lm tricorn.S tricorn_simd.S multicorn.S
	$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f main && rm -f result_asm_simd.bmp &&  rm -f test

.PHONY: test
test: test.c -lm tricorn.S tricorn_simd.S multicorn.S
	$(CC) $(CFLAGS) -o $@ $^
	chmod +x test.sh
	./test.sh