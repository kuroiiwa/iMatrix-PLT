./microc.native micro-test/test-print.im > comp.ll
gcc -c built-in.c
g++ -c img_io.cpp
g++ edge_detection.cpp -o output `pkg-config --cflags --libs opencv`
clang++ `pkg-config --cflags opencv` `pkg-config --libs opencv` img_io.cpp built-in.o comp.ll -o main
clang -o a.out built-in.o img_io.o comp.ll
./a.out
