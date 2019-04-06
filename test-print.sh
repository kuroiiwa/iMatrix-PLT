./microc.native micro-test/test-print.im > comp.ll
gcc -c built-in.c
clang -o a.out built-in.o comp.ll
./a.out
