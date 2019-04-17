./imatrix minitest.im > comp.ll
clang -o a.out comp.ll lib/built_in_lib.o
./a.out
