#!/bin/sh

make -C ./lib/

DESDIR=""

if [ $3 -eq 1 ]; then
	echo "desdir changed"
	DESDIR="./ourtests"
	echo $DESDIR
fi
./imatrix $1 > tmp.ll || {
    echo "FAILED"
    ./imatrix $1 2> $DESDIR/fail-$2.err
    cp $1 $DESDIR/fail-$2.im
    return 1
    }
clang++ -O2 -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o a.out tmp.ll ./lib/lib.a
./a.out > $DESDIR/test-$2.out &&
cp $1 $DESDIR/test-$2.im
