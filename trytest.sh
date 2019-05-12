#!/bin/sh

make -C ./lib/
./imatrix $1 > tmp.ll || {
    echo "FAILED"
    return 1
    }
clang++ -O2 -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o a.out tmp.ll ./lib/lib.a
./a.out