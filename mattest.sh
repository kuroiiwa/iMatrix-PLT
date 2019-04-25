#!/bin/sh

./imatrix mat_tests/test.im > tmp.ll
clang -o a.out tmp.ll lib/built_in_lib.o
./a.out
