lib.a: built_in_lib.o
	ar rcs lib.a built_in_lib.o

built_in_lib.o: built-in.c
	cc -c built-in.c -o built_in_lib.o

clean:
	rm -f *.o *a