CC=g++
ASMBIN=as

all : asm cc link
asm : 
	$(ASMBIN) -msyntax=intel -mnaked-reg -o encode128.o -g encode128.asm
cc :
	$(CC) -c -g -O0 main.c &> errors.txt
link :
	$(CC) -g -o encode128 main.o encode128.o
clean :
	rm *.o
	rm encode128
	rm errors.txt	
	rm encode128.lst

