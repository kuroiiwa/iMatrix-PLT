; ModuleID = 'iMatrix'
source_filename = "iMatrix"

%mat = type opaque
%img = type opaque

@fmt = global [4 x i8] c"%d\0A\00"
@fmt.2 = global [4 x i8] c"%g\0A\00"
@fmt.3 = global [4 x i8] c"%c\0A\00"
@fmt.4 = global [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [8 x i8] c"greater\00"
@str.5 = private unnamed_addr constant [5 x i8] c"less\00"
@str.6 = private unnamed_addr constant [8 x i8] c"greater\00"
@str.7 = private unnamed_addr constant [5 x i8] c"less\00"

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

declare %mat* @malloc_mat(i32, i32)

declare %img* @malloc_img(i32, i32)

declare i32 @free_mat(%mat*)

declare i32 @free_img(%img*)

declare %mat* @repMat(double, i32, i32)

declare %mat* @matAssign(%mat*, double)

declare %img* @imgAssign(%img*, i32)

declare %img* @edgeDetection(%img*, i32)

declare %img* @readimg(i8*)

declare i32 @saveimg(i8*, %img*)

declare i32 @showimg(%img*)

declare i32 @float2int(double)

declare i8 @float2char(double)

declare double @int2float(i32)

declare i8 @int2char(i32)

declare double @char2float(i8)

declare i32 @char2int(i8)

define i32 @main() {
entry:
  %m = alloca %mat*
  %malloc_mat_result = call %mat* @malloc_mat(i32 2, i32 3)
  store %mat* %malloc_mat_result, %mat** %m
  %b = alloca %mat*
  %m1 = load %mat*, %mat** %m
  %addconst_mat_result = call %mat* @addconst_mat(%mat* %m1, double 2.000000e+00)
  store %mat* %addconst_mat_result, %mat** %b
  %m2 = load %mat*, %mat** %m
  %0 = call i32 @__printMat(%mat* %m2)
  %b3 = load %mat*, %mat** %b
  %1 = call i32 @__printMat(%mat* %b3)
  ret i32 0
}

define %img* @addconst_img(%img* %imgIn, i32 %c) {
entry:
  %imgIn1 = alloca %img*
  store %img* %imgIn, %img** %imgIn1
  %c2 = alloca i32
  store i32 %c, i32* %c2
  %row = alloca i32
  %imgIn3 = load %img*, %img** %imgIn1
  %_row = call i32 @__imgRow(%img* %imgIn3)
  store i32 %_row, i32* %row
  %col = alloca i32
  %imgIn4 = load %img*, %img** %imgIn1
  %_col = call i32 @__imgCol(%img* %imgIn4)
  store i32 %_col, i32* %col
  %imgOut = alloca %img*
  %col5 = load i32, i32* %col
  %row6 = load i32, i32* %row
  %malloc_img_result = call %img* @malloc_img(i32 %row6, i32 %col5)
  store %img* %malloc_img_result, %img** %imgOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %i7 = load i32, i32* %i
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %merge34, %entry
  %i38 = load i32, i32* %i
  %row39 = load i32, i32* %row
  %_t40 = icmp slt i32 %i38, %row39
  br i1 %_t40, label %while_body, label %merge41

while_body:                                       ; preds = %while
  %j8 = load i32, i32* %j
  store i32 0, i32* %j
  br label %while9

while9:                                           ; preds = %merge, %while_body
  %j31 = load i32, i32* %j
  %col32 = load i32, i32* %col
  %_t33 = icmp slt i32 %j31, %col32
  br i1 %_t33, label %while_body10, label %merge34

while_body10:                                     ; preds = %while9
  %k11 = load i32, i32* %k
  store i32 0, i32* %k
  br label %while12

while12:                                          ; preds = %while_body13, %while_body10
  %k26 = load i32, i32* %k
  %_t27 = icmp slt i32 %k26, 3
  br i1 %_t27, label %while_body13, label %merge

while_body13:                                     ; preds = %while12
  %imgOut14 = load %img*, %img** %imgOut
  %imgIn15 = load %img*, %img** %imgIn1
  %i16 = load i32, i32* %i
  %j17 = load i32, i32* %j
  %k18 = load i32, i32* %k
  %0 = call i32 @__returnImgVal(%img* %imgIn15, i32 %i16, i32 %j17, i32 %k18)
  %c19 = load i32, i32* %c2
  %_t = add i32 %0, %c19
  %i20 = load i32, i32* %i
  %j21 = load i32, i32* %j
  %k22 = load i32, i32* %k
  %1 = call i32 @__setImgVal(i32 %_t, %img* %imgOut14, i32 %i20, i32 %j21, i32 %k22)
  %k23 = load i32, i32* %k
  %_t24 = add i32 %k23, 1
  %k25 = load i32, i32* %k
  store i32 %_t24, i32* %k
  br label %while12

merge:                                            ; preds = %while12
  %j28 = load i32, i32* %j
  %_t29 = add i32 %j28, 1
  %j30 = load i32, i32* %j
  store i32 %_t29, i32* %j
  br label %while9

merge34:                                          ; preds = %while9
  %i35 = load i32, i32* %i
  %_t36 = add i32 %i35, 1
  %i37 = load i32, i32* %i
  store i32 %_t36, i32* %i
  br label %while

merge41:                                          ; preds = %while
  %imgOut42 = load %img*, %img** %imgOut
  ret %img* %imgOut42
}

define %mat* @addconst_mat(%mat* %matIn, double %c) {
entry:
  %matIn1 = alloca %mat*
  store %mat* %matIn, %mat** %matIn1
  %c2 = alloca double
  store double %c, double* %c2
  %row = alloca i32
  %matIn3 = load %mat*, %mat** %matIn1
  %_row = call i32 @__matRow(%mat* %matIn3)
  store i32 %_row, i32* %row
  %col = alloca i32
  %matIn4 = load %mat*, %mat** %matIn1
  %_col = call i32 @__matCol(%mat* %matIn4)
  store i32 %_col, i32* %col
  %matOut = alloca %mat*
  %col5 = load i32, i32* %col
  %row6 = load i32, i32* %row
  %malloc_mat_result = call %mat* @malloc_mat(i32 %row6, i32 %col5)
  store %mat* %malloc_mat_result, %mat** %matOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %i7 = load i32, i32* %i
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %merge, %entry
  %i26 = load i32, i32* %i
  %row27 = load i32, i32* %row
  %_t28 = icmp slt i32 %i26, %row27
  br i1 %_t28, label %while_body, label %merge29

while_body:                                       ; preds = %while
  %j8 = load i32, i32* %j
  store i32 0, i32* %j
  br label %while9

while9:                                           ; preds = %while_body10, %while_body
  %j20 = load i32, i32* %j
  %col21 = load i32, i32* %col
  %_t22 = icmp slt i32 %j20, %col21
  br i1 %_t22, label %while_body10, label %merge

while_body10:                                     ; preds = %while9
  %matOut11 = load %mat*, %mat** %matOut
  %matIn12 = load %mat*, %mat** %matIn1
  %i13 = load i32, i32* %i
  %j14 = load i32, i32* %j
  %0 = call double @__returnMatVal(%mat* %matIn12, i32 %i13, i32 %j14)
  %c15 = load double, double* %c2
  %tmp = fadd double %0, %c15
  %i16 = load i32, i32* %i
  %j17 = load i32, i32* %j
  %1 = call i32 @__setMatVal(double %tmp, %mat* %matOut11, i32 %i16, i32 %j17)
  %j18 = load i32, i32* %j
  %_t = add i32 %j18, 1
  %j19 = load i32, i32* %j
  store i32 %_t, i32* %j
  br label %while9

merge:                                            ; preds = %while9
  %i23 = load i32, i32* %i
  %_t24 = add i32 %i23, 1
  %i25 = load i32, i32* %i
  store i32 %_t24, i32* %i
  br label %while

merge29:                                          ; preds = %while
  %matOut30 = load %mat*, %mat** %matOut
  ret %mat* %matOut30
}

define %img* @threshold_filter_together(%img* %imgIn, i32 %threshold, i8* %option) {
entry:
  %imgIn1 = alloca %img*
  store %img* %imgIn, %img** %imgIn1
  %threshold2 = alloca i32
  store i32 %threshold, i32* %threshold2
  %option3 = alloca i8*
  store i8* %option, i8** %option3
  %row = alloca i32
  %imgIn4 = load %img*, %img** %imgIn1
  %_row = call i32 @__imgRow(%img* %imgIn4)
  store i32 %_row, i32* %row
  %col = alloca i32
  %imgIn5 = load %img*, %img** %imgIn1
  %_col = call i32 @__imgCol(%img* %imgIn5)
  store i32 %_col, i32* %col
  %layer = alloca i32
  store i32 3, i32* %layer
  %imgOut = alloca %img*
  %col6 = load i32, i32* %col
  %row7 = load i32, i32* %row
  %malloc_img_result = call %img* @malloc_img(i32 %row7, i32 %col6)
  store %img* %malloc_img_result, %img** %imgOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %channel_sum = alloca i32
  store i32 0, i32* %channel_sum
  %channel_ave = alloca i32
  store i32 0, i32* %channel_ave
  %i8 = load i32, i32* %i
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %merge105, %entry
  %i109 = load i32, i32* %i
  %row110 = load i32, i32* %row
  %_t111 = icmp slt i32 %i109, %row110
  br i1 %_t111, label %while_body, label %merge112

while_body:                                       ; preds = %while
  %j9 = load i32, i32* %j
  store i32 0, i32* %j
  br label %while10

while10:                                          ; preds = %merge63, %while_body
  %j102 = load i32, i32* %j
  %col103 = load i32, i32* %col
  %_t104 = icmp slt i32 %j102, %col103
  br i1 %_t104, label %while_body11, label %merge105

while_body11:                                     ; preds = %while10
  %imgIn12 = load %img*, %img** %imgIn1
  %i13 = load i32, i32* %i
  %j14 = load i32, i32* %j
  %0 = call i32 @__returnImgVal(%img* %imgIn12, i32 %i13, i32 %j14, i32 0)
  %imgIn15 = load %img*, %img** %imgIn1
  %i16 = load i32, i32* %i
  %j17 = load i32, i32* %j
  %1 = call i32 @__returnImgVal(%img* %imgIn15, i32 %i16, i32 %j17, i32 1)
  %_t = add i32 %0, %1
  %imgIn18 = load %img*, %img** %imgIn1
  %i19 = load i32, i32* %i
  %j20 = load i32, i32* %j
  %2 = call i32 @__returnImgVal(%img* %imgIn18, i32 %i19, i32 %j20, i32 2)
  %_t21 = add i32 %_t, %2
  %channel_sum22 = load i32, i32* %channel_sum
  store i32 %_t21, i32* %channel_sum
  %channel_sum23 = load i32, i32* %channel_sum
  %_t24 = sdiv i32 %channel_sum23, 3
  %channel_ave25 = load i32, i32* %channel_ave
  store i32 %_t24, i32* %channel_ave
  %option26 = load i8*, i8** %option3
  %_t27 = icmp eq i8* %option26, getelementptr inbounds ([8 x i8], [8 x i8]* @str, i32 0, i32 0)
  br i1 %_t27, label %then, label %else60

merge:                                            ; preds = %else60, %merge31
  %option61 = load i8*, i8** %option3
  %_t62 = icmp eq i8* %option61, getelementptr inbounds ([5 x i8], [5 x i8]* @str.5, i32 0, i32 0)
  br i1 %_t62, label %then64, label %else98

then:                                             ; preds = %while_body11
  %channel_ave28 = load i32, i32* %channel_ave
  %threshold29 = load i32, i32* %threshold2
  %_t30 = icmp sgt i32 %channel_ave28, %threshold29
  br i1 %_t30, label %then32, label %else

merge31:                                          ; preds = %else, %then32
  br label %merge

then32:                                           ; preds = %then
  %imgOut33 = load %img*, %img** %imgOut
  %imgIn34 = load %img*, %img** %imgIn1
  %i35 = load i32, i32* %i
  %j36 = load i32, i32* %j
  %3 = call i32 @__returnImgVal(%img* %imgIn34, i32 %i35, i32 %j36, i32 0)
  %i37 = load i32, i32* %i
  %j38 = load i32, i32* %j
  %4 = call i32 @__setImgVal(i32 %3, %img* %imgOut33, i32 %i37, i32 %j38, i32 0)
  %imgOut39 = load %img*, %img** %imgOut
  %imgIn40 = load %img*, %img** %imgIn1
  %i41 = load i32, i32* %i
  %j42 = load i32, i32* %j
  %5 = call i32 @__returnImgVal(%img* %imgIn40, i32 %i41, i32 %j42, i32 1)
  %i43 = load i32, i32* %i
  %j44 = load i32, i32* %j
  %6 = call i32 @__setImgVal(i32 %5, %img* %imgOut39, i32 %i43, i32 %j44, i32 1)
  %imgOut45 = load %img*, %img** %imgOut
  %imgIn46 = load %img*, %img** %imgIn1
  %i47 = load i32, i32* %i
  %j48 = load i32, i32* %j
  %7 = call i32 @__returnImgVal(%img* %imgIn46, i32 %i47, i32 %j48, i32 2)
  %i49 = load i32, i32* %i
  %j50 = load i32, i32* %j
  %8 = call i32 @__setImgVal(i32 %7, %img* %imgOut45, i32 %i49, i32 %j50, i32 2)
  br label %merge31

else:                                             ; preds = %then
  %imgOut51 = load %img*, %img** %imgOut
  %i52 = load i32, i32* %i
  %j53 = load i32, i32* %j
  %9 = call i32 @__setImgVal(i32 0, %img* %imgOut51, i32 %i52, i32 %j53, i32 0)
  %imgOut54 = load %img*, %img** %imgOut
  %i55 = load i32, i32* %i
  %j56 = load i32, i32* %j
  %10 = call i32 @__setImgVal(i32 0, %img* %imgOut54, i32 %i55, i32 %j56, i32 1)
  %imgOut57 = load %img*, %img** %imgOut
  %i58 = load i32, i32* %i
  %j59 = load i32, i32* %j
  %11 = call i32 @__setImgVal(i32 0, %img* %imgOut57, i32 %i58, i32 %j59, i32 2)
  br label %merge31

else60:                                           ; preds = %while_body11
  br label %merge

merge63:                                          ; preds = %else98, %merge68
  %j99 = load i32, i32* %j
  %_t100 = add i32 %j99, 1
  %j101 = load i32, i32* %j
  store i32 %_t100, i32* %j
  br label %while10

then64:                                           ; preds = %merge
  %channel_ave65 = load i32, i32* %channel_ave
  %threshold66 = load i32, i32* %threshold2
  %_t67 = icmp slt i32 %channel_ave65, %threshold66
  br i1 %_t67, label %then69, label %else88

merge68:                                          ; preds = %else88, %then69
  br label %merge63

then69:                                           ; preds = %then64
  %imgOut70 = load %img*, %img** %imgOut
  %imgIn71 = load %img*, %img** %imgIn1
  %i72 = load i32, i32* %i
  %j73 = load i32, i32* %j
  %12 = call i32 @__returnImgVal(%img* %imgIn71, i32 %i72, i32 %j73, i32 0)
  %i74 = load i32, i32* %i
  %j75 = load i32, i32* %j
  %13 = call i32 @__setImgVal(i32 %12, %img* %imgOut70, i32 %i74, i32 %j75, i32 0)
  %imgOut76 = load %img*, %img** %imgOut
  %imgIn77 = load %img*, %img** %imgIn1
  %i78 = load i32, i32* %i
  %j79 = load i32, i32* %j
  %14 = call i32 @__returnImgVal(%img* %imgIn77, i32 %i78, i32 %j79, i32 1)
  %i80 = load i32, i32* %i
  %j81 = load i32, i32* %j
  %15 = call i32 @__setImgVal(i32 %14, %img* %imgOut76, i32 %i80, i32 %j81, i32 1)
  %imgOut82 = load %img*, %img** %imgOut
  %imgIn83 = load %img*, %img** %imgIn1
  %i84 = load i32, i32* %i
  %j85 = load i32, i32* %j
  %16 = call i32 @__returnImgVal(%img* %imgIn83, i32 %i84, i32 %j85, i32 2)
  %i86 = load i32, i32* %i
  %j87 = load i32, i32* %j
  %17 = call i32 @__setImgVal(i32 %16, %img* %imgOut82, i32 %i86, i32 %j87, i32 2)
  br label %merge68

else88:                                           ; preds = %then64
  %imgOut89 = load %img*, %img** %imgOut
  %i90 = load i32, i32* %i
  %j91 = load i32, i32* %j
  %18 = call i32 @__setImgVal(i32 0, %img* %imgOut89, i32 %i90, i32 %j91, i32 0)
  %imgOut92 = load %img*, %img** %imgOut
  %i93 = load i32, i32* %i
  %j94 = load i32, i32* %j
  %19 = call i32 @__setImgVal(i32 0, %img* %imgOut92, i32 %i93, i32 %j94, i32 1)
  %imgOut95 = load %img*, %img** %imgOut
  %i96 = load i32, i32* %i
  %j97 = load i32, i32* %j
  %20 = call i32 @__setImgVal(i32 0, %img* %imgOut95, i32 %i96, i32 %j97, i32 2)
  br label %merge68

else98:                                           ; preds = %merge
  br label %merge63

merge105:                                         ; preds = %while10
  %i106 = load i32, i32* %i
  %_t107 = add i32 %i106, 1
  %i108 = load i32, i32* %i
  store i32 %_t107, i32* %i
  br label %while

merge112:                                         ; preds = %while
  %imgOut113 = load %img*, %img** %imgOut
  ret %img* %imgOut113
}

define %img* @threshold_filter_separate(%img* %imgIn, i32 %r_threshold, i32 %g_threshold, i32 %b_threshold, i8* %option) {
entry:
  %imgIn1 = alloca %img*
  store %img* %imgIn, %img** %imgIn1
  %r_threshold2 = alloca i32
  store i32 %r_threshold, i32* %r_threshold2
  %g_threshold3 = alloca i32
  store i32 %g_threshold, i32* %g_threshold3
  %b_threshold4 = alloca i32
  store i32 %b_threshold, i32* %b_threshold4
  %option5 = alloca i8*
  store i8* %option, i8** %option5
  %row = alloca i32
  %imgIn6 = load %img*, %img** %imgIn1
  %_row = call i32 @__imgRow(%img* %imgIn6)
  store i32 %_row, i32* %row
  %col = alloca i32
  %imgIn7 = load %img*, %img** %imgIn1
  %_col = call i32 @__imgCol(%img* %imgIn7)
  store i32 %_col, i32* %col
  %layer = alloca i32
  store i32 3, i32* %layer
  %imgOut = alloca %img*
  %col8 = load i32, i32* %col
  %row9 = load i32, i32* %row
  %malloc_img_result = call %img* @malloc_img(i32 %row9, i32 %col8)
  store %img* %malloc_img_result, %img** %imgOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %i10 = load i32, i32* %i
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %merge128, %entry
  %i132 = load i32, i32* %i
  %row133 = load i32, i32* %row
  %_t134 = icmp slt i32 %i132, %row133
  br i1 %_t134, label %while_body, label %merge135

while_body:                                       ; preds = %while
  %j11 = load i32, i32* %j
  store i32 0, i32* %j
  br label %while12

while12:                                          ; preds = %merge68, %while_body
  %j125 = load i32, i32* %j
  %col126 = load i32, i32* %col
  %_t127 = icmp slt i32 %j125, %col126
  br i1 %_t127, label %while_body13, label %merge128

while_body13:                                     ; preds = %while12
  %option14 = load i8*, i8** %option5
  %_t = icmp eq i8* %option14, getelementptr inbounds ([8 x i8], [8 x i8]* @str.6, i32 0, i32 0)
  br i1 %_t, label %then, label %else65

merge:                                            ; preds = %else65, %merge53
  %option66 = load i8*, i8** %option5
  %_t67 = icmp eq i8* %option66, getelementptr inbounds ([5 x i8], [5 x i8]* @str.7, i32 0, i32 0)
  br i1 %_t67, label %then69, label %else121

then:                                             ; preds = %while_body13
  %imgIn15 = load %img*, %img** %imgIn1
  %i16 = load i32, i32* %i
  %j17 = load i32, i32* %j
  %0 = call i32 @__returnImgVal(%img* %imgIn15, i32 %i16, i32 %j17, i32 0)
  %r_threshold18 = load i32, i32* %r_threshold2
  %_t19 = icmp sgt i32 %0, %r_threshold18
  br i1 %_t19, label %then21, label %else

merge20:                                          ; preds = %else, %then21
  %imgIn31 = load %img*, %img** %imgIn1
  %i32 = load i32, i32* %i
  %j33 = load i32, i32* %j
  %1 = call i32 @__returnImgVal(%img* %imgIn31, i32 %i32, i32 %j33, i32 1)
  %g_threshold34 = load i32, i32* %g_threshold3
  %_t35 = icmp sgt i32 %1, %g_threshold34
  br i1 %_t35, label %then37, label %else44

then21:                                           ; preds = %then
  %imgOut22 = load %img*, %img** %imgOut
  %imgIn23 = load %img*, %img** %imgIn1
  %i24 = load i32, i32* %i
  %j25 = load i32, i32* %j
  %2 = call i32 @__returnImgVal(%img* %imgIn23, i32 %i24, i32 %j25, i32 0)
  %i26 = load i32, i32* %i
  %j27 = load i32, i32* %j
  %3 = call i32 @__setImgVal(i32 %2, %img* %imgOut22, i32 %i26, i32 %j27, i32 0)
  br label %merge20

else:                                             ; preds = %then
  %imgOut28 = load %img*, %img** %imgOut
  %i29 = load i32, i32* %i
  %j30 = load i32, i32* %j
  %4 = call i32 @__setImgVal(i32 0, %img* %imgOut28, i32 %i29, i32 %j30, i32 0)
  br label %merge20

merge36:                                          ; preds = %else44, %then37
  %imgIn48 = load %img*, %img** %imgIn1
  %i49 = load i32, i32* %i
  %j50 = load i32, i32* %j
  %5 = call i32 @__returnImgVal(%img* %imgIn48, i32 %i49, i32 %j50, i32 2)
  %b_threshold51 = load i32, i32* %b_threshold4
  %_t52 = icmp sgt i32 %5, %b_threshold51
  br i1 %_t52, label %then54, label %else61

then37:                                           ; preds = %merge20
  %imgOut38 = load %img*, %img** %imgOut
  %imgIn39 = load %img*, %img** %imgIn1
  %i40 = load i32, i32* %i
  %j41 = load i32, i32* %j
  %6 = call i32 @__returnImgVal(%img* %imgIn39, i32 %i40, i32 %j41, i32 1)
  %i42 = load i32, i32* %i
  %j43 = load i32, i32* %j
  %7 = call i32 @__setImgVal(i32 %6, %img* %imgOut38, i32 %i42, i32 %j43, i32 1)
  br label %merge36

else44:                                           ; preds = %merge20
  %imgOut45 = load %img*, %img** %imgOut
  %i46 = load i32, i32* %i
  %j47 = load i32, i32* %j
  %8 = call i32 @__setImgVal(i32 0, %img* %imgOut45, i32 %i46, i32 %j47, i32 1)
  br label %merge36

merge53:                                          ; preds = %else61, %then54
  br label %merge

then54:                                           ; preds = %merge36
  %imgOut55 = load %img*, %img** %imgOut
  %imgIn56 = load %img*, %img** %imgIn1
  %i57 = load i32, i32* %i
  %j58 = load i32, i32* %j
  %9 = call i32 @__returnImgVal(%img* %imgIn56, i32 %i57, i32 %j58, i32 2)
  %i59 = load i32, i32* %i
  %j60 = load i32, i32* %j
  %10 = call i32 @__setImgVal(i32 %9, %img* %imgOut55, i32 %i59, i32 %j60, i32 2)
  br label %merge53

else61:                                           ; preds = %merge36
  %imgOut62 = load %img*, %img** %imgOut
  %i63 = load i32, i32* %i
  %j64 = load i32, i32* %j
  %11 = call i32 @__setImgVal(i32 0, %img* %imgOut62, i32 %i63, i32 %j64, i32 2)
  br label %merge53

else65:                                           ; preds = %while_body13
  br label %merge

merge68:                                          ; preds = %else121, %merge109
  %j122 = load i32, i32* %j
  %_t123 = add i32 %j122, 1
  %j124 = load i32, i32* %j
  store i32 %_t123, i32* %j
  br label %while12

then69:                                           ; preds = %merge
  %imgIn70 = load %img*, %img** %imgIn1
  %i71 = load i32, i32* %i
  %j72 = load i32, i32* %j
  %12 = call i32 @__returnImgVal(%img* %imgIn70, i32 %i71, i32 %j72, i32 0)
  %r_threshold73 = load i32, i32* %r_threshold2
  %_t74 = icmp slt i32 %12, %r_threshold73
  br i1 %_t74, label %then76, label %else83

merge75:                                          ; preds = %else83, %then76
  %imgIn87 = load %img*, %img** %imgIn1
  %i88 = load i32, i32* %i
  %j89 = load i32, i32* %j
  %13 = call i32 @__returnImgVal(%img* %imgIn87, i32 %i88, i32 %j89, i32 1)
  %g_threshold90 = load i32, i32* %g_threshold3
  %_t91 = icmp slt i32 %13, %g_threshold90
  br i1 %_t91, label %then93, label %else100

then76:                                           ; preds = %then69
  %imgOut77 = load %img*, %img** %imgOut
  %imgIn78 = load %img*, %img** %imgIn1
  %i79 = load i32, i32* %i
  %j80 = load i32, i32* %j
  %14 = call i32 @__returnImgVal(%img* %imgIn78, i32 %i79, i32 %j80, i32 0)
  %i81 = load i32, i32* %i
  %j82 = load i32, i32* %j
  %15 = call i32 @__setImgVal(i32 %14, %img* %imgOut77, i32 %i81, i32 %j82, i32 0)
  br label %merge75

else83:                                           ; preds = %then69
  %imgOut84 = load %img*, %img** %imgOut
  %i85 = load i32, i32* %i
  %j86 = load i32, i32* %j
  %16 = call i32 @__setImgVal(i32 0, %img* %imgOut84, i32 %i85, i32 %j86, i32 0)
  br label %merge75

merge92:                                          ; preds = %else100, %then93
  %imgIn104 = load %img*, %img** %imgIn1
  %i105 = load i32, i32* %i
  %j106 = load i32, i32* %j
  %17 = call i32 @__returnImgVal(%img* %imgIn104, i32 %i105, i32 %j106, i32 2)
  %b_threshold107 = load i32, i32* %b_threshold4
  %_t108 = icmp slt i32 %17, %b_threshold107
  br i1 %_t108, label %then110, label %else117

then93:                                           ; preds = %merge75
  %imgOut94 = load %img*, %img** %imgOut
  %imgIn95 = load %img*, %img** %imgIn1
  %i96 = load i32, i32* %i
  %j97 = load i32, i32* %j
  %18 = call i32 @__returnImgVal(%img* %imgIn95, i32 %i96, i32 %j97, i32 1)
  %i98 = load i32, i32* %i
  %j99 = load i32, i32* %j
  %19 = call i32 @__setImgVal(i32 %18, %img* %imgOut94, i32 %i98, i32 %j99, i32 1)
  br label %merge92

else100:                                          ; preds = %merge75
  %imgOut101 = load %img*, %img** %imgOut
  %i102 = load i32, i32* %i
  %j103 = load i32, i32* %j
  %20 = call i32 @__setImgVal(i32 0, %img* %imgOut101, i32 %i102, i32 %j103, i32 1)
  br label %merge92

merge109:                                         ; preds = %else117, %then110
  br label %merge68

then110:                                          ; preds = %merge92
  %imgOut111 = load %img*, %img** %imgOut
  %imgIn112 = load %img*, %img** %imgIn1
  %i113 = load i32, i32* %i
  %j114 = load i32, i32* %j
  %21 = call i32 @__returnImgVal(%img* %imgIn112, i32 %i113, i32 %j114, i32 2)
  %i115 = load i32, i32* %i
  %j116 = load i32, i32* %j
  %22 = call i32 @__setImgVal(i32 %21, %img* %imgOut111, i32 %i115, i32 %j116, i32 2)
  br label %merge109

else117:                                          ; preds = %merge92
  %imgOut118 = load %img*, %img** %imgOut
  %i119 = load i32, i32* %i
  %j120 = load i32, i32* %j
  %23 = call i32 @__setImgVal(i32 0, %img* %imgOut118, i32 %i119, i32 %j120, i32 2)
  br label %merge109

else121:                                          ; preds = %merge
  br label %merge68

merge128:                                         ; preds = %while12
  %i129 = load i32, i32* %i
  %_t130 = add i32 %i129, 1
  %i131 = load i32, i32* %i
  store i32 %_t130, i32* %i
  br label %while

merge135:                                         ; preds = %while
  %imgOut136 = load %img*, %img** %imgOut
  ret %img* %imgOut136
}

define %img* @RBG_regularization(%img* %imgIn) {
entry:
  %imgIn1 = alloca %img*
  store %img* %imgIn, %img** %imgIn1
  %row = alloca i32
  %imgIn2 = load %img*, %img** %imgIn1
  %_row = call i32 @__imgRow(%img* %imgIn2)
  store i32 %_row, i32* %row
  %col = alloca i32
  %imgIn3 = load %img*, %img** %imgIn1
  %_col = call i32 @__imgCol(%img* %imgIn3)
  store i32 %_col, i32* %col
  %layer = alloca i32
  store i32 3, i32* %layer
  %imgOut = alloca %img*
  %col4 = load i32, i32* %col
  %row5 = load i32, i32* %row
  %malloc_img_result = call %img* @malloc_img(i32 %row5, i32 %col4)
  store %img* %malloc_img_result, %img** %imgOut
  %r_sum = alloca i32
  store i32 0, i32* %r_sum
  %b_sum = alloca i32
  store i32 0, i32* %b_sum
  %g_sum = alloca i32
  store i32 0, i32* %g_sum
  %pixel_count = alloca i32
  store i32 0, i32* %pixel_count
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %i6 = load i32, i32* %i
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %merge, %entry
  %i39 = load i32, i32* %i
  %row40 = load i32, i32* %row
  %_t41 = icmp slt i32 %i39, %row40
  br i1 %_t41, label %while_body, label %merge42

while_body:                                       ; preds = %while
  %j7 = load i32, i32* %j
  store i32 0, i32* %j
  br label %while8

while8:                                           ; preds = %while_body9, %while_body
  %j33 = load i32, i32* %j
  %col34 = load i32, i32* %col
  %_t35 = icmp slt i32 %j33, %col34
  br i1 %_t35, label %while_body9, label %merge

while_body9:                                      ; preds = %while8
  %r_sum10 = load i32, i32* %r_sum
  %imgIn11 = load %img*, %img** %imgIn1
  %i12 = load i32, i32* %i
  %j13 = load i32, i32* %j
  %0 = call i32 @__returnImgVal(%img* %imgIn11, i32 %i12, i32 %j13, i32 0)
  %_t = add i32 %r_sum10, %0
  %r_sum14 = load i32, i32* %r_sum
  store i32 %_t, i32* %r_sum
  %g_sum15 = load i32, i32* %g_sum
  %imgIn16 = load %img*, %img** %imgIn1
  %i17 = load i32, i32* %i
  %j18 = load i32, i32* %j
  %1 = call i32 @__returnImgVal(%img* %imgIn16, i32 %i17, i32 %j18, i32 1)
  %_t19 = add i32 %g_sum15, %1
  %g_sum20 = load i32, i32* %g_sum
  store i32 %_t19, i32* %g_sum
  %b_sum21 = load i32, i32* %b_sum
  %imgIn22 = load %img*, %img** %imgIn1
  %i23 = load i32, i32* %i
  %j24 = load i32, i32* %j
  %2 = call i32 @__returnImgVal(%img* %imgIn22, i32 %i23, i32 %j24, i32 2)
  %_t25 = add i32 %b_sum21, %2
  %b_sum26 = load i32, i32* %b_sum
  store i32 %_t25, i32* %b_sum
  %pixel_count27 = load i32, i32* %pixel_count
  %_t28 = add i32 %pixel_count27, 1
  %pixel_count29 = load i32, i32* %pixel_count
  store i32 %_t28, i32* %pixel_count
  %j30 = load i32, i32* %j
  %_t31 = add i32 %j30, 1
  %j32 = load i32, i32* %j
  store i32 %_t31, i32* %j
  br label %while8

merge:                                            ; preds = %while8
  %i36 = load i32, i32* %i
  %_t37 = add i32 %i36, 1
  %i38 = load i32, i32* %i
  store i32 %_t37, i32* %i
  br label %while

merge42:                                          ; preds = %while
  %all_sum = alloca i32
  %r_sum43 = load i32, i32* %r_sum
  %g_sum44 = load i32, i32* %g_sum
  %_t45 = add i32 %r_sum43, %g_sum44
  %b_sum46 = load i32, i32* %b_sum
  %_t47 = add i32 %_t45, %b_sum46
  store i32 %_t47, i32* %all_sum
  %r_factor = alloca double
  %all_sum48 = load i32, i32* %all_sum
  %int2float_result = call double @int2float(i32 %all_sum48)
  %r_sum49 = load i32, i32* %r_sum
  %int2float_result50 = call double @int2float(i32 %r_sum49)
  %tmp = fmul double %int2float_result50, 3.000000e+00
  %tmp51 = fdiv double %int2float_result, %tmp
  store double %tmp51, double* %r_factor
  %g_factor = alloca double
  %all_sum52 = load i32, i32* %all_sum
  %int2float_result53 = call double @int2float(i32 %all_sum52)
  %g_sum54 = load i32, i32* %g_sum
  %int2float_result55 = call double @int2float(i32 %g_sum54)
  %tmp56 = fmul double %int2float_result55, 3.000000e+00
  %tmp57 = fdiv double %int2float_result53, %tmp56
  store double %tmp57, double* %g_factor
  %b_factor = alloca double
  %all_sum58 = load i32, i32* %all_sum
  %int2float_result59 = call double @int2float(i32 %all_sum58)
  %b_sum60 = load i32, i32* %b_sum
  %int2float_result61 = call double @int2float(i32 %b_sum60)
  %tmp62 = fmul double %int2float_result61, 3.000000e+00
  %tmp63 = fdiv double %int2float_result59, %tmp62
  store double %tmp63, double* %b_factor
  %temp_r = alloca double
  store double 0.000000e+00, double* %temp_r
  %temp_g = alloca double
  store double 0.000000e+00, double* %temp_g
  %temp_b = alloca double
  store double 0.000000e+00, double* %temp_b
  %i64 = load i32, i32* %i
  store i32 0, i32* %i
  br label %while65

while65:                                          ; preds = %merge113, %merge42
  %i117 = load i32, i32* %i
  %row118 = load i32, i32* %row
  %_t119 = icmp slt i32 %i117, %row118
  br i1 %_t119, label %while_body66, label %merge120

while_body66:                                     ; preds = %while65
  %j67 = load i32, i32* %j
  store i32 0, i32* %j
  br label %while68

while68:                                          ; preds = %while_body69, %while_body66
  %j110 = load i32, i32* %j
  %col111 = load i32, i32* %col
  %_t112 = icmp slt i32 %j110, %col111
  br i1 %_t112, label %while_body69, label %merge113

while_body69:                                     ; preds = %while68
  %imgIn70 = load %img*, %img** %imgIn1
  %i71 = load i32, i32* %i
  %j72 = load i32, i32* %j
  %3 = call i32 @__returnImgVal(%img* %imgIn70, i32 %i71, i32 %j72, i32 0)
  %int2float_result73 = call double @int2float(i32 %3)
  %r_factor74 = load double, double* %r_factor
  %tmp75 = fmul double %int2float_result73, %r_factor74
  %temp_r76 = load double, double* %temp_r
  store double %tmp75, double* %temp_r
  %imgIn77 = load %img*, %img** %imgIn1
  %i78 = load i32, i32* %i
  %j79 = load i32, i32* %j
  %4 = call i32 @__returnImgVal(%img* %imgIn77, i32 %i78, i32 %j79, i32 1)
  %int2float_result80 = call double @int2float(i32 %4)
  %g_factor81 = load double, double* %g_factor
  %tmp82 = fmul double %int2float_result80, %g_factor81
  %temp_g83 = load double, double* %temp_g
  store double %tmp82, double* %temp_g
  %imgIn84 = load %img*, %img** %imgIn1
  %i85 = load i32, i32* %i
  %j86 = load i32, i32* %j
  %5 = call i32 @__returnImgVal(%img* %imgIn84, i32 %i85, i32 %j86, i32 2)
  %int2float_result87 = call double @int2float(i32 %5)
  %b_factor88 = load double, double* %b_factor
  %tmp89 = fmul double %int2float_result87, %b_factor88
  %temp_b90 = load double, double* %temp_b
  store double %tmp89, double* %temp_b
  %imgOut91 = load %img*, %img** %imgOut
  %temp_r92 = load double, double* %temp_r
  %float2int_result = call i32 @float2int(double %temp_r92)
  %relu_int_result = call i32 @relu_int(i32 %float2int_result)
  %i93 = load i32, i32* %i
  %j94 = load i32, i32* %j
  %6 = call i32 @__setImgVal(i32 %relu_int_result, %img* %imgOut91, i32 %i93, i32 %j94, i32 0)
  %imgOut95 = load %img*, %img** %imgOut
  %temp_g96 = load double, double* %temp_g
  %float2int_result97 = call i32 @float2int(double %temp_g96)
  %relu_int_result98 = call i32 @relu_int(i32 %float2int_result97)
  %i99 = load i32, i32* %i
  %j100 = load i32, i32* %j
  %7 = call i32 @__setImgVal(i32 %relu_int_result98, %img* %imgOut95, i32 %i99, i32 %j100, i32 1)
  %imgOut101 = load %img*, %img** %imgOut
  %temp_b102 = load double, double* %temp_b
  %float2int_result103 = call i32 @float2int(double %temp_b102)
  %relu_int_result104 = call i32 @relu_int(i32 %float2int_result103)
  %i105 = load i32, i32* %i
  %j106 = load i32, i32* %j
  %8 = call i32 @__setImgVal(i32 %relu_int_result104, %img* %imgOut101, i32 %i105, i32 %j106, i32 2)
  %j107 = load i32, i32* %j
  %_t108 = add i32 %j107, 1
  %j109 = load i32, i32* %j
  store i32 %_t108, i32* %j
  br label %while68

merge113:                                         ; preds = %while68
  %i114 = load i32, i32* %i
  %_t115 = add i32 %i114, 1
  %i116 = load i32, i32* %i
  store i32 %_t115, i32* %i
  br label %while65

merge120:                                         ; preds = %while65
  %imgOut121 = load %img*, %img** %imgOut
  ret %img* %imgOut121
}

define %img* @edgeDetection.1(%img* %imgIn, i32 %threshold) {
entry:
  %imgIn1 = alloca %img*
  store %img* %imgIn, %img** %imgIn1
  %threshold2 = alloca i32
  store i32 %threshold, i32* %threshold2
  %row = alloca i32
  %imgIn3 = load %img*, %img** %imgIn1
  %_row = call i32 @__imgRow(%img* %imgIn3)
  store i32 %_row, i32* %row
  %col = alloca i32
  %imgIn4 = load %img*, %img** %imgIn1
  %_col = call i32 @__imgCol(%img* %imgIn4)
  store i32 %_col, i32* %col
  %layer = alloca i32
  store i32 3, i32* %layer
  %imgOut = alloca %img*
  %col5 = load i32, i32* %col
  %row6 = load i32, i32* %row
  %malloc_img_result = call %img* @malloc_img(i32 %row6, i32 %col5)
  store %img* %malloc_img_result, %img** %imgOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %i_n1 = alloca i32
  store i32 0, i32* %i_n1
  %i_p1 = alloca i32
  store i32 0, i32* %i_p1
  %j_n1 = alloca i32
  store i32 0, i32* %j_n1
  %j_p1 = alloca i32
  store i32 0, i32* %j_p1
  %gradSumTemp = alloca i32
  store i32 0, i32* %gradSumTemp
  %gradSum = alloca i32
  store i32 0, i32* %gradSum
  %i7 = load i32, i32* %i
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %merge168, %entry
  %i172 = load i32, i32* %i
  %row173 = load i32, i32* %row
  %_t174 = icmp slt i32 %i172, %row173
  br i1 %_t174, label %while_body, label %merge175

while_body:                                       ; preds = %while
  %j8 = load i32, i32* %j
  store i32 0, i32* %j
  br label %while9

while9:                                           ; preds = %merge, %while_body
  %j165 = load i32, i32* %j
  %col166 = load i32, i32* %col
  %_t167 = icmp slt i32 %j165, %col166
  br i1 %_t167, label %while_body10, label %merge168

while_body10:                                     ; preds = %while9
  %i11 = load i32, i32* %i
  %_t = icmp eq i32 %i11, 0
  %j12 = load i32, i32* %j
  %_t13 = icmp eq i32 %j12, 0
  %_t14 = or i1 %_t, %_t13
  %i15 = load i32, i32* %i
  %row16 = load i32, i32* %row
  %_t17 = sub i32 %row16, 1
  %_t18 = icmp eq i32 %i15, %_t17
  %_t19 = or i1 %_t14, %_t18
  %j20 = load i32, i32* %j
  %col21 = load i32, i32* %col
  %_t22 = sub i32 %col21, 1
  %_t23 = icmp eq i32 %j20, %_t22
  %_t24 = or i1 %_t19, %_t23
  br i1 %_t24, label %then, label %else

merge:                                            ; preds = %merge127, %merge38
  %j162 = load i32, i32* %j
  %_t163 = add i32 %j162, 1
  %j164 = load i32, i32* %j
  store i32 %_t163, i32* %j
  br label %while9

then:                                             ; preds = %while_body10
  %k25 = load i32, i32* %k
  store i32 0, i32* %k
  br label %while26

while26:                                          ; preds = %while_body27, %then
  %k35 = load i32, i32* %k
  %layer36 = load i32, i32* %layer
  %_t37 = icmp slt i32 %k35, %layer36
  br i1 %_t37, label %while_body27, label %merge38

while_body27:                                     ; preds = %while26
  %imgOut28 = load %img*, %img** %imgOut
  %i29 = load i32, i32* %i
  %j30 = load i32, i32* %j
  %k31 = load i32, i32* %k
  %0 = call i32 @__setImgVal(i32 0, %img* %imgOut28, i32 %i29, i32 %j30, i32 %k31)
  %k32 = load i32, i32* %k
  %_t33 = add i32 %k32, 1
  %k34 = load i32, i32* %k
  store i32 %_t33, i32* %k
  br label %while26

merge38:                                          ; preds = %while26
  br label %merge

else:                                             ; preds = %while_body10
  %gradSum39 = load i32, i32* %gradSum
  store i32 0, i32* %gradSum
  %k40 = load i32, i32* %k
  store i32 0, i32* %k
  br label %while41

while41:                                          ; preds = %merge103, %else
  %k116 = load i32, i32* %k
  %layer117 = load i32, i32* %layer
  %_t118 = icmp slt i32 %k116, %layer117
  br i1 %_t118, label %while_body42, label %merge119

while_body42:                                     ; preds = %while41
  %i43 = load i32, i32* %i
  %_t44 = sub i32 %i43, 1
  %i_n145 = load i32, i32* %i_n1
  store i32 %_t44, i32* %i_n1
  %i46 = load i32, i32* %i
  %_t47 = add i32 %i46, 1
  %i_p148 = load i32, i32* %i_p1
  store i32 %_t47, i32* %i_p1
  %j49 = load i32, i32* %j
  %_t50 = sub i32 %j49, 1
  %j_n151 = load i32, i32* %j_n1
  store i32 %_t50, i32* %j_n1
  %j52 = load i32, i32* %j
  %_t53 = add i32 %j52, 1
  %j_p154 = load i32, i32* %j_p1
  store i32 %_t53, i32* %j_p1
  %imgIn55 = load %img*, %img** %imgIn1
  %i56 = load i32, i32* %i
  %j57 = load i32, i32* %j
  %k58 = load i32, i32* %k
  %1 = call i32 @__returnImgVal(%img* %imgIn55, i32 %i56, i32 %j57, i32 %k58)
  %_t59 = mul i32 8, %1
  %imgIn60 = load %img*, %img** %imgIn1
  %i_n161 = load i32, i32* %i_n1
  %j_n162 = load i32, i32* %j_n1
  %k63 = load i32, i32* %k
  %2 = call i32 @__returnImgVal(%img* %imgIn60, i32 %i_n161, i32 %j_n162, i32 %k63)
  %_t64 = sub i32 %_t59, %2
  %imgIn65 = load %img*, %img** %imgIn1
  %i_n166 = load i32, i32* %i_n1
  %j67 = load i32, i32* %j
  %k68 = load i32, i32* %k
  %3 = call i32 @__returnImgVal(%img* %imgIn65, i32 %i_n166, i32 %j67, i32 %k68)
  %_t69 = sub i32 %_t64, %3
  %imgIn70 = load %img*, %img** %imgIn1
  %i_n171 = load i32, i32* %i_n1
  %j_p172 = load i32, i32* %j_p1
  %k73 = load i32, i32* %k
  %4 = call i32 @__returnImgVal(%img* %imgIn70, i32 %i_n171, i32 %j_p172, i32 %k73)
  %_t74 = sub i32 %_t69, %4
  %imgIn75 = load %img*, %img** %imgIn1
  %i76 = load i32, i32* %i
  %j_n177 = load i32, i32* %j_n1
  %k78 = load i32, i32* %k
  %5 = call i32 @__returnImgVal(%img* %imgIn75, i32 %i76, i32 %j_n177, i32 %k78)
  %_t79 = sub i32 %_t74, %5
  %imgIn80 = load %img*, %img** %imgIn1
  %i81 = load i32, i32* %i
  %j_p182 = load i32, i32* %j_p1
  %k83 = load i32, i32* %k
  %6 = call i32 @__returnImgVal(%img* %imgIn80, i32 %i81, i32 %j_p182, i32 %k83)
  %_t84 = sub i32 %_t79, %6
  %imgIn85 = load %img*, %img** %imgIn1
  %i_p186 = load i32, i32* %i_p1
  %j_n187 = load i32, i32* %j_n1
  %k88 = load i32, i32* %k
  %7 = call i32 @__returnImgVal(%img* %imgIn85, i32 %i_p186, i32 %j_n187, i32 %k88)
  %_t89 = sub i32 %_t84, %7
  %imgIn90 = load %img*, %img** %imgIn1
  %i_p191 = load i32, i32* %i_p1
  %j92 = load i32, i32* %j
  %k93 = load i32, i32* %k
  %8 = call i32 @__returnImgVal(%img* %imgIn90, i32 %i_p191, i32 %j92, i32 %k93)
  %_t94 = sub i32 %_t89, %8
  %imgIn95 = load %img*, %img** %imgIn1
  %i_p196 = load i32, i32* %i_p1
  %j_p197 = load i32, i32* %j_p1
  %k98 = load i32, i32* %k
  %9 = call i32 @__returnImgVal(%img* %imgIn95, i32 %i_p196, i32 %j_p197, i32 %k98)
  %_t99 = sub i32 %_t94, %9
  %gradSumTemp100 = load i32, i32* %gradSumTemp
  store i32 %_t99, i32* %gradSumTemp
  %gradSumTemp101 = load i32, i32* %gradSumTemp
  %_t102 = icmp slt i32 %gradSumTemp101, 0
  br i1 %_t102, label %then104, label %else108

merge103:                                         ; preds = %else108, %then104
  %gradSum109 = load i32, i32* %gradSum
  %gradSumTemp110 = load i32, i32* %gradSumTemp
  %_t111 = add i32 %gradSum109, %gradSumTemp110
  %gradSum112 = load i32, i32* %gradSum
  store i32 %_t111, i32* %gradSum
  %k113 = load i32, i32* %k
  %_t114 = add i32 %k113, 1
  %k115 = load i32, i32* %k
  store i32 %_t114, i32* %k
  br label %while41

then104:                                          ; preds = %while_body42
  %gradSumTemp105 = load i32, i32* %gradSumTemp
  %_t106 = sub i32 0, %gradSumTemp105
  %gradSumTemp107 = load i32, i32* %gradSumTemp
  store i32 %_t106, i32* %gradSumTemp
  br label %merge103

else108:                                          ; preds = %while_body42
  br label %merge103

merge119:                                         ; preds = %while41
  %gradSum120 = load i32, i32* %gradSum
  %layer121 = load i32, i32* %layer
  %_t122 = sdiv i32 %gradSum120, %layer121
  %gradSum123 = load i32, i32* %gradSum
  store i32 %_t122, i32* %gradSum
  %gradSum124 = load i32, i32* %gradSum
  %threshold125 = load i32, i32* %threshold2
  %_t126 = icmp sge i32 %gradSum124, %threshold125
  br i1 %_t126, label %then128, label %else147

merge127:                                         ; preds = %merge161, %merge146
  br label %merge

then128:                                          ; preds = %merge119
  %k129 = load i32, i32* %k
  store i32 0, i32* %k
  br label %while130

while130:                                         ; preds = %while_body131, %then128
  %k143 = load i32, i32* %k
  %layer144 = load i32, i32* %layer
  %_t145 = icmp slt i32 %k143, %layer144
  br i1 %_t145, label %while_body131, label %merge146

while_body131:                                    ; preds = %while130
  %imgOut132 = load %img*, %img** %imgOut
  %imgIn133 = load %img*, %img** %imgIn1
  %i134 = load i32, i32* %i
  %j135 = load i32, i32* %j
  %k136 = load i32, i32* %k
  %10 = call i32 @__returnImgVal(%img* %imgIn133, i32 %i134, i32 %j135, i32 %k136)
  %i137 = load i32, i32* %i
  %j138 = load i32, i32* %j
  %k139 = load i32, i32* %k
  %11 = call i32 @__setImgVal(i32 %10, %img* %imgOut132, i32 %i137, i32 %j138, i32 %k139)
  %k140 = load i32, i32* %k
  %_t141 = add i32 %k140, 1
  %k142 = load i32, i32* %k
  store i32 %_t141, i32* %k
  br label %while130

merge146:                                         ; preds = %while130
  br label %merge127

else147:                                          ; preds = %merge119
  %k148 = load i32, i32* %k
  store i32 0, i32* %k
  br label %while149

while149:                                         ; preds = %while_body150, %else147
  %k158 = load i32, i32* %k
  %layer159 = load i32, i32* %layer
  %_t160 = icmp slt i32 %k158, %layer159
  br i1 %_t160, label %while_body150, label %merge161

while_body150:                                    ; preds = %while149
  %imgOut151 = load %img*, %img** %imgOut
  %i152 = load i32, i32* %i
  %j153 = load i32, i32* %j
  %k154 = load i32, i32* %k
  %12 = call i32 @__setImgVal(i32 0, %img* %imgOut151, i32 %i152, i32 %j153, i32 %k154)
  %k155 = load i32, i32* %k
  %_t156 = add i32 %k155, 1
  %k157 = load i32, i32* %k
  store i32 %_t156, i32* %k
  br label %while149

merge161:                                         ; preds = %while149
  br label %merge127

merge168:                                         ; preds = %while9
  %i169 = load i32, i32* %i
  %_t170 = add i32 %i169, 1
  %i171 = load i32, i32* %i
  store i32 %_t170, i32* %i
  br label %while

merge175:                                         ; preds = %while
  %imgOut176 = load %img*, %img** %imgOut
  ret %img* %imgOut176
}

define %img* @aveFilter(%img* %imgIn, i32 %fWidth) {
entry:
  %imgIn1 = alloca %img*
  store %img* %imgIn, %img** %imgIn1
  %fWidth2 = alloca i32
  store i32 %fWidth, i32* %fWidth2
  %row = alloca i32
  %imgIn3 = load %img*, %img** %imgIn1
  %_row = call i32 @__imgRow(%img* %imgIn3)
  store i32 %_row, i32* %row
  %col = alloca i32
  %imgIn4 = load %img*, %img** %imgIn1
  %_col = call i32 @__imgCol(%img* %imgIn4)
  store i32 %_col, i32* %col
  %layer = alloca i32
  store i32 3, i32* %layer
  %imgOut = alloca %img*
  %col5 = load i32, i32* %col
  %row6 = load i32, i32* %row
  %malloc_img_result = call %img* @malloc_img(i32 %row6, i32 %col5)
  store %img* %malloc_img_result, %img** %imgOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %count = alloca i32
  store i32 0, i32* %count
  %sum = alloca i32
  store i32 0, i32* %sum
  %m = alloca i32
  store i32 0, i32* %m
  %n = alloca i32
  store i32 0, i32* %n
  %ii = alloca i32
  store i32 0, i32* %ii
  %jj = alloca i32
  store i32 0, i32* %jj
  %aveResult = alloca i32
  store i32 0, i32* %aveResult
  %i7 = load i32, i32* %i
  store i32 0, i32* %i
  br label %while

while:                                            ; preds = %merge102, %entry
  %i106 = load i32, i32* %i
  %row107 = load i32, i32* %row
  %_t108 = icmp slt i32 %i106, %row107
  br i1 %_t108, label %while_body, label %merge109

while_body:                                       ; preds = %while
  %j8 = load i32, i32* %j
  store i32 0, i32* %j
  br label %while9

while9:                                           ; preds = %merge95, %while_body
  %j99 = load i32, i32* %j
  %col100 = load i32, i32* %col
  %_t101 = icmp slt i32 %j99, %col100
  br i1 %_t101, label %while_body10, label %merge102

while_body10:                                     ; preds = %while9
  %k11 = load i32, i32* %k
  store i32 0, i32* %k
  br label %while12

while12:                                          ; preds = %merge79, %while_body10
  %k92 = load i32, i32* %k
  %layer93 = load i32, i32* %layer
  %_t94 = icmp slt i32 %k92, %layer93
  br i1 %_t94, label %while_body13, label %merge95

while_body13:                                     ; preds = %while12
  %count14 = load i32, i32* %count
  store i32 0, i32* %count
  %sum15 = load i32, i32* %sum
  store i32 0, i32* %sum
  %fWidth16 = load i32, i32* %fWidth2
  %_t = sub i32 0, %fWidth16
  %m17 = load i32, i32* %m
  store i32 %_t, i32* %m
  br label %while18

while18:                                          ; preds = %merge72, %while_body13
  %m76 = load i32, i32* %m
  %fWidth77 = load i32, i32* %fWidth2
  %_t78 = icmp sle i32 %m76, %fWidth77
  br i1 %_t78, label %while_body19, label %merge79

while_body19:                                     ; preds = %while18
  %fWidth20 = load i32, i32* %fWidth2
  %_t21 = sub i32 0, %fWidth20
  %n22 = load i32, i32* %n
  store i32 %_t21, i32* %n
  br label %while23

while23:                                          ; preds = %merge, %while_body19
  %n69 = load i32, i32* %n
  %fWidth70 = load i32, i32* %fWidth2
  %_t71 = icmp sle i32 %n69, %fWidth70
  br i1 %_t71, label %while_body24, label %merge72

while_body24:                                     ; preds = %while23
  %i25 = load i32, i32* %i
  %m26 = load i32, i32* %m
  %_t27 = add i32 %i25, %m26
  %_t28 = icmp sge i32 %_t27, 0
  %i29 = load i32, i32* %i
  %m30 = load i32, i32* %m
  %_t31 = add i32 %i29, %m30
  %row32 = load i32, i32* %row
  %_t33 = sub i32 %row32, 1
  %_t34 = icmp slt i32 %_t31, %_t33
  %_t35 = and i1 %_t28, %_t34
  %j36 = load i32, i32* %j
  %n37 = load i32, i32* %n
  %_t38 = add i32 %j36, %n37
  %_t39 = icmp sge i32 %_t38, 0
  %_t40 = and i1 %_t35, %_t39
  %j41 = load i32, i32* %j
  %n42 = load i32, i32* %n
  %_t43 = add i32 %j41, %n42
  %col44 = load i32, i32* %col
  %_t45 = sub i32 %col44, 1
  %_t46 = icmp slt i32 %_t43, %_t45
  %_t47 = and i1 %_t40, %_t46
  br i1 %_t47, label %then, label %else

merge:                                            ; preds = %else, %then
  %n66 = load i32, i32* %n
  %_t67 = add i32 %n66, 1
  %n68 = load i32, i32* %n
  store i32 %_t67, i32* %n
  br label %while23

then:                                             ; preds = %while_body24
  %count48 = load i32, i32* %count
  %_t49 = add i32 %count48, 1
  %count50 = load i32, i32* %count
  store i32 %_t49, i32* %count
  %i51 = load i32, i32* %i
  %m52 = load i32, i32* %m
  %_t53 = add i32 %i51, %m52
  %ii54 = load i32, i32* %ii
  store i32 %_t53, i32* %ii
  %j55 = load i32, i32* %j
  %n56 = load i32, i32* %n
  %_t57 = add i32 %j55, %n56
  %jj58 = load i32, i32* %jj
  store i32 %_t57, i32* %jj
  %sum59 = load i32, i32* %sum
  %imgIn60 = load %img*, %img** %imgIn1
  %ii61 = load i32, i32* %ii
  %jj62 = load i32, i32* %jj
  %k63 = load i32, i32* %k
  %0 = call i32 @__returnImgVal(%img* %imgIn60, i32 %ii61, i32 %jj62, i32 %k63)
  %_t64 = add i32 %sum59, %0
  %sum65 = load i32, i32* %sum
  store i32 %_t64, i32* %sum
  br label %merge

else:                                             ; preds = %while_body24
  br label %merge

merge72:                                          ; preds = %while23
  %m73 = load i32, i32* %m
  %_t74 = add i32 %m73, 1
  %m75 = load i32, i32* %m
  store i32 %_t74, i32* %m
  br label %while18

merge79:                                          ; preds = %while18
  %sum80 = load i32, i32* %sum
  %count81 = load i32, i32* %count
  %_t82 = sdiv i32 %sum80, %count81
  %aveResult83 = load i32, i32* %aveResult
  store i32 %_t82, i32* %aveResult
  %imgOut84 = load %img*, %img** %imgOut
  %aveResult85 = load i32, i32* %aveResult
  %i86 = load i32, i32* %i
  %j87 = load i32, i32* %j
  %k88 = load i32, i32* %k
  %1 = call i32 @__setImgVal(i32 %aveResult85, %img* %imgOut84, i32 %i86, i32 %j87, i32 %k88)
  %k89 = load i32, i32* %k
  %_t90 = add i32 %k89, 1
  %k91 = load i32, i32* %k
  store i32 %_t90, i32* %k
  br label %while12

merge95:                                          ; preds = %while12
  %j96 = load i32, i32* %j
  %_t97 = add i32 %j96, 1
  %j98 = load i32, i32* %j
  store i32 %_t97, i32* %j
  br label %while9

merge102:                                         ; preds = %while9
  %i103 = load i32, i32* %i
  %_t104 = add i32 %i103, 1
  %i105 = load i32, i32* %i
  store i32 %_t104, i32* %i
  br label %while

merge109:                                         ; preds = %while
  %imgOut110 = load %img*, %img** %imgOut
  ret %img* %imgOut110
}

define i32 @relu_int(i32 %input) {
entry:
  %input1 = alloca i32
  store i32 %input, i32* %input1
  %result = alloca i32
  store i32 0, i32* %result
  %input2 = load i32, i32* %input1
  %_t = icmp sge i32 %input2, 255
  br i1 %_t, label %then, label %else

merge:                                            ; preds = %else, %then
  %input4 = load i32, i32* %input1
  %_t5 = icmp sle i32 %input4, -255
  br i1 %_t5, label %then7, label %else9

then:                                             ; preds = %entry
  %input3 = load i32, i32* %input1
  store i32 255, i32* %input1
  br label %merge

else:                                             ; preds = %entry
  br label %merge

merge6:                                           ; preds = %else9, %then7
  %input10 = load i32, i32* %input1
  %_t11 = icmp sge i32 %input10, 0
  br i1 %_t11, label %then13, label %else16

then7:                                            ; preds = %merge
  %input8 = load i32, i32* %input1
  store i32 -255, i32* %input1
  br label %merge6

else9:                                            ; preds = %merge
  br label %merge6

merge12:                                          ; preds = %else16, %then13
  %result18 = load i32, i32* %result
  ret i32 %result18

then13:                                           ; preds = %merge6
  %input14 = load i32, i32* %input1
  %result15 = load i32, i32* %result
  store i32 %input14, i32* %result
  br label %merge12

else16:                                           ; preds = %merge6
  %result17 = load i32, i32* %result
  store i32 0, i32* %result
  br label %merge12
}

define i32 @abs_int(i32 %input) {
entry:
  %input1 = alloca i32
  store i32 %input, i32* %input1
  %result = alloca i32
  store i32 0, i32* %result
  %input2 = load i32, i32* %input1
  %_t = icmp sge i32 %input2, 255
  br i1 %_t, label %then, label %else

merge:                                            ; preds = %else, %then
  %input4 = load i32, i32* %input1
  %_t5 = icmp sle i32 %input4, -255
  br i1 %_t5, label %then7, label %else9

then:                                             ; preds = %entry
  %input3 = load i32, i32* %input1
  store i32 255, i32* %input1
  br label %merge

else:                                             ; preds = %entry
  br label %merge

merge6:                                           ; preds = %else9, %then7
  %input10 = load i32, i32* %input1
  %_t11 = icmp sge i32 %input10, 0
  br i1 %_t11, label %then13, label %else16

then7:                                            ; preds = %merge
  %input8 = load i32, i32* %input1
  store i32 -255, i32* %input1
  br label %merge6

else9:                                            ; preds = %merge
  br label %merge6

merge12:                                          ; preds = %else16, %then13
  %result20 = load i32, i32* %result
  ret i32 %result20

then13:                                           ; preds = %merge6
  %input14 = load i32, i32* %input1
  %result15 = load i32, i32* %result
  store i32 %input14, i32* %result
  br label %merge12

else16:                                           ; preds = %merge6
  %input17 = load i32, i32* %input1
  %_t18 = sub i32 0, %input17
  %result19 = load i32, i32* %result
  store i32 %_t18, i32* %result
  br label %merge12
}
