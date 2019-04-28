#!/bin/sh

make -C ./lib/
./imatrix minitest.im > tmp.ll
clang++ -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o a.out tmp.ll ./lib/lib.a
./a.out