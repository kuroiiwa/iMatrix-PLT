MICROC="./microc.native"

CC="clang"

file="./micro-test/test-func.mc"


$MICROC $file > tmp.ll
$CC -o a.out tmp.ll
./a.out
rm a.out tmp.ll
