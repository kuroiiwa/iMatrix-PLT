rm a.out *.ll
make -C ../lib/
../imatrix ./test-aveFilter.im > tmp.ll
clang++ -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o a.out tmp.ll ../lib/lib.a
./a.out
#cat ./test-img_conv.out
