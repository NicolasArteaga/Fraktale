# Optimize lvl 3, turn on extra warnings
CFLAGS=-O3 -g -Wall -Wextra -no-pie

.PHONY: all
all: main_c

main_c: main.c -lm
	$(CC) $(CFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f main_c && rm -f result_c.bmp &&  rm -f test

.PHONY: test
test: test.c -lm
	$(CC) $(CFLAGS) -o $@ $^
	chmod +x test.sh
	./test.sh
