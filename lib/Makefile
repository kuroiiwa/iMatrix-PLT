CC = cc
CPP = g++

lib.a: built_in_lib.o opencv_lib.o
	ar rcs lib.a built_in_lib.o opencv_lib.o

opencv_lib.o: opencv_lib.cpp
	$(CPP) -g -c opencv_lib.cpp -o opencv_lib.o

built_in_lib.o: builtin.c
	$(CC) -g -c -fopenmp builtin.c -o built_in_lib.o

clean:
	rm -f *.o *a