; ModuleID = 'iMatrix'
source_filename = "iMatrix"

%mat = type opaque
%img = type opaque

@fmt = global [4 x i8] c"%d\0A\00"
@fmt.1 = global [4 x i8] c"%g\0A\00"
@fmt.2 = global [4 x i8] c"%c\0A\00"
@fmt.3 = global [4 x i8] c"%s\0A\00"

declare i32 @printf(i8*, ...)

declare i32 @__printIntArr(i32***, i32, i32, i32)

declare i32 @__printFloatArr(double***, i32, i32, i32)

declare i32 @__printCharArr(i8***, i32, i32, i32)

declare i32 @printMat(%mat*)

declare i32 @printImg(%img*)

declare i32 @__setIntArray(i32, i32***, i32***, i32, i32*)

declare i32 @__setFloArray(i32, double***, double***, i32, i32*)

declare i32 @__setMat(%mat*, double**, i32, i32)

declare double @__returnMatVal(%mat*, i32, i32)

declare i32 @__returnImgVal(%img*, i32, i32, i32)

declare i32 @__setMatVal(double, %mat*, i32, i32)

declare i32 @__setImgVal(i32, %img*, i32, i32, i32)

declare %mat* @matOperator(%mat*, %mat*, i8)

declare %img* @imgOperator(%img*, %img*, i8)

declare i32 @__matRow(%mat*)

declare i32 @__imgRow(%img*)

declare %mat* @malloc_mat(i32, i32)

declare %img* @malloc_img(i32, i32)

declare i32 @free_mat(%mat*)

declare i32 @free_img(%img*)

declare %mat* @matAssign(%mat*, double)

declare %mat* @matMul(%mat*, %mat*)

declare %img* @imgAssign(%img*, i32)

declare %img* @aveFilter(%img*, i32)

declare %img* @edgeDetection(%img*, i32)

define i32 @main() {
entry:
  %a = alloca %mat*
  %malloc_mat_result = call %mat* @malloc_mat(i32 5, i32 3)
  store %mat* %malloc_mat_result, %mat** %a
  %a1 = load %mat*, %mat** %a
  %matAssign_result = call %mat* @matAssign(%mat* %a1, double 1.000000e+00)
  %a2 = load %mat*, %mat** %a
  %row = call i32 @__matRow(%mat* %a2)
  %0 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt, i32 0, i32 0), i32 %row)
  ret i32 0
}
