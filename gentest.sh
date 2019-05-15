#!/bin/sh

make -C ./lib/
basename=`echo $1 | sed 's/.*\\///
                         s/.im//'`
./imatrix $1 > tmp.ll || {
    echo "FAILED"
    ./imatrix $1 2> fail-$2.err
    cp $1 > fail-$2.im
    return 1
    }
clang++ -O2 -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o a.out tmp.ll ./lib/lib.a
./a.out > test-$2.out
cp $1 test-$2.im
