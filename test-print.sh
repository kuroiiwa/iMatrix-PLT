./microc.native micro-test/test-print.im > comp.ll
gcc -c built-in.c
gcc -c array_functions/print_array.c
clang -o a.out print_array.o comp.ll
./a.out
