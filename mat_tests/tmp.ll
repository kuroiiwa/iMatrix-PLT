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

declare i32 @__printMat(%mat*)

declare i32 @__printImg(%img*)

declare i32 @__setIntArray(i32, i32***, i32***, i32, i32*)

declare i32 @__setFloArray(i32, double***, double***, i32, i32*)

declare i32 @__setMat(%mat*, double**, i32, i32)

declare i32 @__setMatVal(double, %mat*, i32, i32)

declare i32 @__setImgVal(i32, %img*, i32, i32, i32)

declare double @__returnMatVal(%mat*, i32, i32)

declare i32 @__returnImgVal(%img*, i32, i32, i32)

declare %mat* @__matOperator(%mat*, %mat*, i8)

declare %img* @__imgOperator(%img*, %img*, i8)

declare i32 @__matRow(%mat*)

declare i32 @__matCol(%mat*)

declare i32 @__imgRow(%img*)

declare i32 @__imgCol(%img*)

declare %mat* @__matMul(%mat*, %mat*)

declare i32 @__intPower(i32, i32)

declare double @__floatPower(double, double)

declare %mat* @__matTranspose(%mat*)

declare %mat* @__matPower(%mat*, i32)

declare %mat* @malloc_mat(i32, i32)

declare %img* @malloc_img(i32, i32)

declare i32 @free_mat(%mat*)

declare i32 @free_img(%img*)

declare %mat* @repMat(double, i32, i32)

declare %mat* @matAssign(%mat*, double)

declare %img* @imgAssign(%img*, i32)

declare %img* @readimg(i8*)

declare i32 @saveimg(i8*, %img*)

declare i32 @showimg(%img*)

declare %mat* @invert(%mat*)

declare %mat* @eigen_vector(%mat*)

declare %mat* @eigen_value(%mat*)

declare i32 @float2int(double)

declare i8 @float2char(double)

declare double @int2float(i32)

declare i8 @int2char(i32)

declare double @char2float(i8)

declare i32 @char2int(i8)

define i32 @main() {
entry:
  %m = alloca %mat*
  %malloc_mat_result = call %mat* @malloc_mat(i32 3, i32 3)
  store %mat* %malloc_mat_result, %mat** %m
  %_t = alloca [3 x double]
  %_t1 = bitcast [3 x double]* %_t to double*
  store double 1.000000e+00, double* %_t1
  %_t2 = getelementptr inbounds double, double* %_t1, i32 1
  store double 2.000000e+00, double* %_t2
  %_t3 = getelementptr inbounds double, double* %_t2, i32 1
  store double -1.000000e+00, double* %_t3
  %_t4 = getelementptr inbounds double, double* %_t3, i32 1
  %_t5 = alloca [3 x double]
  %_t6 = bitcast [3 x double]* %_t5 to double*
  store double -2.000000e+00, double* %_t6
  %_t7 = getelementptr inbounds double, double* %_t6, i32 1
  store double 0.000000e+00, double* %_t7
  %_t8 = getelementptr inbounds double, double* %_t7, i32 1
  store double 1.000000e+00, double* %_t8
  %_t9 = getelementptr inbounds double, double* %_t8, i32 1
  %_t10 = alloca [3 x double]
  %_t11 = bitcast [3 x double]* %_t10 to double*
  store double 1.000000e+00, double* %_t11
  %_t12 = getelementptr inbounds double, double* %_t11, i32 1
  store double -1.000000e+00, double* %_t12
  %_t13 = getelementptr inbounds double, double* %_t12, i32 1
  store double 0.000000e+00, double* %_t13
  %_t14 = getelementptr inbounds double, double* %_t13, i32 1
  %_t15 = alloca [3 x double*]
  %_t16 = bitcast [3 x double*]* %_t15 to double**
  store double* %_t1, double** %_t16
  %_t17 = getelementptr inbounds double*, double** %_t16, i32 1
  store double* %_t6, double** %_t17
  %_t18 = getelementptr inbounds double*, double** %_t17, i32 1
  store double* %_t11, double** %_t18
  %_t19 = getelementptr inbounds double*, double** %_t18, i32 1
  %m20 = load %mat*, %mat** %m
  %__setMat = call i32 @__setMat(%mat* %m20, double** %_t16, i32 3, i32 3)
  %b = alloca %mat*
  %m21 = load %mat*, %mat** %m
  %eigen_value_result = call %mat* @eigen_value(%mat* %m21)
  store %mat* %eigen_value_result, %mat** %b
  %m22 = load %mat*, %mat** %m
  %0 = call i32 @__printMat(%mat* %m22)
  %b23 = load %mat*, %mat** %b
  %1 = call i32 @__printMat(%mat* %b23)
  ret i32 0
}
