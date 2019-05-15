; ModuleID = 'iMatrix'
source_filename = "iMatrix"

%mat = type opaque
%img = type opaque

@fmt = global [4 x i8] c"%d\0A\00"
@fmt.1 = global [4 x i8] c"%g\0A\00"
@fmt.2 = global [4 x i8] c"%c\0A\00"
@fmt.3 = global [4 x i8] c"%s\0A\00"
@str = private unnamed_addr constant [8 x i8] c"greater\00"
@str.4 = private unnamed_addr constant [5 x i8] c"less\00"
@str.5 = private unnamed_addr constant [8 x i8] c"greater\00"
@str.6 = private unnamed_addr constant [5 x i8] c"less\00"
@str.7 = private unnamed_addr constant [17 x i8] c"../lib/puppy.jpg\00"
@str.8 = private unnamed_addr constant [34 x i8] c"../generated_images/aveFilter.jpg\00"

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

declare i32 @float2int(double)

declare i8 @float2char(double)

declare double @int2float(i32)

declare i8 @int2char(i32)

declare double @char2float(i8)

declare i32 @char2int(i8)

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
  %input5 = load i32, i32* %input1
  %_t6 = icmp sle i32 %input5, -255
  br i1 %_t6, label %then8, label %else11

then:                                             ; preds = %entry
  %input3 = load i32, i32* %input1
  store i32 255, i32* %input1
  %_t4 = load i32, i32* %input1
  br label %merge

else:                                             ; preds = %entry
  br label %merge

merge7:                                           ; preds = %else11, %then8
  %input12 = load i32, i32* %input1
  %_t13 = icmp sge i32 %input12, 0
  br i1 %_t13, label %then15, label %else19

then8:                                            ; preds = %merge
  %input9 = load i32, i32* %input1
  store i32 -255, i32* %input1
  %_t10 = load i32, i32* %input1
  br label %merge7

else11:                                           ; preds = %merge
  br label %merge7

merge14:                                          ; preds = %else19, %then15
  %result24 = load i32, i32* %result
  ret i32 %result24

then15:                                           ; preds = %merge7
  %input16 = load i32, i32* %input1
  %result17 = load i32, i32* %result
  store i32 %input16, i32* %result
  %_t18 = load i32, i32* %result
  br label %merge14

else19:                                           ; preds = %merge7
  %input20 = load i32, i32* %input1
  %_t21 = sub i32 0, %input20
  %result22 = load i32, i32* %result
  store i32 %_t21, i32* %result
  %_t23 = load i32, i32* %result
  br label %merge14
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
  %input5 = load i32, i32* %input1
  %_t6 = icmp sge i32 %input5, 0
  br i1 %_t6, label %then8, label %else12

then:                                             ; preds = %entry
  %input3 = load i32, i32* %input1
  store i32 255, i32* %input1
  %_t4 = load i32, i32* %input1
  br label %merge

else:                                             ; preds = %entry
  br label %merge

merge7:                                           ; preds = %else12, %then8
  %result15 = load i32, i32* %result
  ret i32 %result15

then8:                                            ; preds = %merge
  %input9 = load i32, i32* %input1
  %result10 = load i32, i32* %result
  store i32 %input9, i32* %result
  %_t11 = load i32, i32* %result
  br label %merge7

else12:                                           ; preds = %merge
  %result13 = load i32, i32* %result
  store i32 0, i32* %result
  %_t14 = load i32, i32* %result
  br label %merge7
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
  %row5 = load i32, i32* %row
  %col6 = load i32, i32* %col
  %malloc_img_result = call %img* @malloc_img(i32 %row5, i32 %col6)
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
  %_t = load i32, i32* %i
  br label %while

while:                                            ; preds = %merge116, %entry
  %i121 = load i32, i32* %i
  %row122 = load i32, i32* %row
  %_t123 = icmp slt i32 %i121, %row122
  br i1 %_t123, label %while_body, label %merge124

while_body:                                       ; preds = %while
  %j8 = load i32, i32* %j
  store i32 0, i32* %j
  %_t9 = load i32, i32* %j
  br label %while10

while10:                                          ; preds = %merge108, %while_body
  %j113 = load i32, i32* %j
  %col114 = load i32, i32* %col
  %_t115 = icmp slt i32 %j113, %col114
  br i1 %_t115, label %while_body11, label %merge116

while_body11:                                     ; preds = %while10
  %k12 = load i32, i32* %k
  store i32 0, i32* %k
  %_t13 = load i32, i32* %k
  br label %while14

while14:                                          ; preds = %merge90, %while_body11
  %k105 = load i32, i32* %k
  %layer106 = load i32, i32* %layer
  %_t107 = icmp slt i32 %k105, %layer106
  br i1 %_t107, label %while_body15, label %merge108

while_body15:                                     ; preds = %while14
  %count16 = load i32, i32* %count
  store i32 0, i32* %count
  %_t17 = load i32, i32* %count
  %sum18 = load i32, i32* %sum
  store i32 0, i32* %sum
  %_t19 = load i32, i32* %sum
  %fWidth20 = load i32, i32* %fWidth2
  %_t21 = sub i32 0, %fWidth20
  %m22 = load i32, i32* %m
  store i32 %_t21, i32* %m
  %_t23 = load i32, i32* %m
  br label %while24

while24:                                          ; preds = %merge82, %while_body15
  %m87 = load i32, i32* %m
  %fWidth88 = load i32, i32* %fWidth2
  %_t89 = icmp sle i32 %m87, %fWidth88
  br i1 %_t89, label %while_body25, label %merge90

while_body25:                                     ; preds = %while24
  %fWidth26 = load i32, i32* %fWidth2
  %_t27 = sub i32 0, %fWidth26
  %n28 = load i32, i32* %n
  store i32 %_t27, i32* %n
  %_t29 = load i32, i32* %n
  br label %while30

while30:                                          ; preds = %merge, %while_body25
  %n79 = load i32, i32* %n
  %fWidth80 = load i32, i32* %fWidth2
  %_t81 = icmp sle i32 %n79, %fWidth80
  br i1 %_t81, label %while_body31, label %merge82

while_body31:                                     ; preds = %while30
  %i32 = load i32, i32* %i
  %m33 = load i32, i32* %m
  %_t34 = add i32 %i32, %m33
  %_t35 = icmp sge i32 %_t34, 0
  %i36 = load i32, i32* %i
  %m37 = load i32, i32* %m
  %_t38 = add i32 %i36, %m37
  %row39 = load i32, i32* %row
  %_t40 = sub i32 %row39, 1
  %_t41 = icmp slt i32 %_t38, %_t40
  %_t42 = and i1 %_t35, %_t41
  %j43 = load i32, i32* %j
  %n44 = load i32, i32* %n
  %_t45 = add i32 %j43, %n44
  %_t46 = icmp sge i32 %_t45, 0
  %_t47 = and i1 %_t42, %_t46
  %j48 = load i32, i32* %j
  %n49 = load i32, i32* %n
  %_t50 = add i32 %j48, %n49
  %col51 = load i32, i32* %col
  %_t52 = sub i32 %col51, 1
  %_t53 = icmp slt i32 %_t50, %_t52
  %_t54 = and i1 %_t47, %_t53
  br i1 %_t54, label %then, label %else

merge:                                            ; preds = %else, %then
  %n75 = load i32, i32* %n
  %_t76 = add i32 %n75, 1
  %n77 = load i32, i32* %n
  store i32 %_t76, i32* %n
  %_t78 = load i32, i32* %n
  br label %while30

then:                                             ; preds = %while_body31
  %count55 = load i32, i32* %count
  %_t56 = add i32 %count55, 1
  %count57 = load i32, i32* %count
  store i32 %_t56, i32* %count
  %_t58 = load i32, i32* %count
  %ii59 = alloca i32
  %i60 = load i32, i32* %i
  %m61 = load i32, i32* %m
  %_t62 = add i32 %i60, %m61
  store i32 %_t62, i32* %ii59
  %jj63 = alloca i32
  %j64 = load i32, i32* %j
  %n65 = load i32, i32* %n
  %_t66 = add i32 %j64, %n65
  store i32 %_t66, i32* %jj63
  %sum67 = load i32, i32* %sum
  %imgIn68 = load %img*, %img** %imgIn1
  %ii69 = load i32, i32* %ii59
  %jj70 = load i32, i32* %jj63
  %k71 = load i32, i32* %k
  %0 = call i32 @__returnImgVal(%img* %imgIn68, i32 %ii69, i32 %jj70, i32 %k71)
  %_t72 = add i32 %sum67, %0
  %sum73 = load i32, i32* %sum
  store i32 %_t72, i32* %sum
  %_t74 = load i32, i32* %sum
  br label %merge

else:                                             ; preds = %while_body31
  br label %merge

merge82:                                          ; preds = %while30
  %m83 = load i32, i32* %m
  %_t84 = add i32 %m83, 1
  %m85 = load i32, i32* %m
  store i32 %_t84, i32* %m
  %_t86 = load i32, i32* %m
  br label %while24

merge90:                                          ; preds = %while24
  %sum91 = load i32, i32* %sum
  %count92 = load i32, i32* %count
  %_t93 = sdiv i32 %sum91, %count92
  %aveResult94 = load i32, i32* %aveResult
  store i32 %_t93, i32* %aveResult
  %_t95 = load i32, i32* %aveResult
  %imgOut96 = load %img*, %img** %imgOut
  %aveResult97 = load i32, i32* %aveResult
  %i98 = load i32, i32* %i
  %j99 = load i32, i32* %j
  %k100 = load i32, i32* %k
  %1 = call i32 @__setImgVal(i32 %aveResult97, %img* %imgOut96, i32 %i98, i32 %j99, i32 %k100)
  %k101 = load i32, i32* %k
  %_t102 = add i32 %k101, 1
  %k103 = load i32, i32* %k
  store i32 %_t102, i32* %k
  %_t104 = load i32, i32* %k
  br label %while14

merge108:                                         ; preds = %while14
  %j109 = load i32, i32* %j
  %_t110 = add i32 %j109, 1
  %j111 = load i32, i32* %j
  store i32 %_t110, i32* %j
  %_t112 = load i32, i32* %j
  br label %while10

merge116:                                         ; preds = %while10
  %i117 = load i32, i32* %i
  %_t118 = add i32 %i117, 1
  %i119 = load i32, i32* %i
  store i32 %_t118, i32* %i
  %_t120 = load i32, i32* %i
  br label %while

merge124:                                         ; preds = %while
  %imgOut125 = load %img*, %img** %imgOut
  ret %img* %imgOut125
}

define %img* @edgeDetection(%img* %imgIn, i32 %threshold) {
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
  %row5 = load i32, i32* %row
  %col6 = load i32, i32* %col
  %malloc_img_result = call %img* @malloc_img(i32 %row5, i32 %col6)
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
  %_t = load i32, i32* %i
  br label %while

while:                                            ; preds = %merge188, %entry
  %i193 = load i32, i32* %i
  %row194 = load i32, i32* %row
  %_t195 = icmp slt i32 %i193, %row194
  br i1 %_t195, label %while_body, label %merge196

while_body:                                       ; preds = %while
  %j8 = load i32, i32* %j
  store i32 0, i32* %j
  %_t9 = load i32, i32* %j
  br label %while10

while10:                                          ; preds = %merge, %while_body
  %j185 = load i32, i32* %j
  %col186 = load i32, i32* %col
  %_t187 = icmp slt i32 %j185, %col186
  br i1 %_t187, label %while_body11, label %merge188

while_body11:                                     ; preds = %while10
  %i12 = load i32, i32* %i
  %_t13 = icmp eq i32 %i12, 0
  %j14 = load i32, i32* %j
  %_t15 = icmp eq i32 %j14, 0
  %_t16 = or i1 %_t13, %_t15
  %i17 = load i32, i32* %i
  %row18 = load i32, i32* %row
  %_t19 = sub i32 %row18, 1
  %_t20 = icmp eq i32 %i17, %_t19
  %_t21 = or i1 %_t16, %_t20
  %j22 = load i32, i32* %j
  %col23 = load i32, i32* %col
  %_t24 = sub i32 %col23, 1
  %_t25 = icmp eq i32 %j22, %_t24
  %_t26 = or i1 %_t21, %_t25
  br i1 %_t26, label %then, label %else

merge:                                            ; preds = %merge142, %merge42
  %j181 = load i32, i32* %j
  %_t182 = add i32 %j181, 1
  %j183 = load i32, i32* %j
  store i32 %_t182, i32* %j
  %_t184 = load i32, i32* %j
  br label %while10

then:                                             ; preds = %while_body11
  %k27 = load i32, i32* %k
  store i32 0, i32* %k
  %_t28 = load i32, i32* %k
  br label %while29

while29:                                          ; preds = %while_body30, %then
  %k39 = load i32, i32* %k
  %layer40 = load i32, i32* %layer
  %_t41 = icmp slt i32 %k39, %layer40
  br i1 %_t41, label %while_body30, label %merge42

while_body30:                                     ; preds = %while29
  %imgOut31 = load %img*, %img** %imgOut
  %i32 = load i32, i32* %i
  %j33 = load i32, i32* %j
  %k34 = load i32, i32* %k
  %0 = call i32 @__setImgVal(i32 0, %img* %imgOut31, i32 %i32, i32 %j33, i32 %k34)
  %k35 = load i32, i32* %k
  %_t36 = add i32 %k35, 1
  %k37 = load i32, i32* %k
  store i32 %_t36, i32* %k
  %_t38 = load i32, i32* %k
  br label %while29

merge42:                                          ; preds = %while29
  br label %merge

else:                                             ; preds = %while_body11
  %gradSum43 = load i32, i32* %gradSum
  store i32 0, i32* %gradSum
  %_t44 = load i32, i32* %gradSum
  %k45 = load i32, i32* %k
  store i32 0, i32* %k
  %_t46 = load i32, i32* %k
  br label %while47

while47:                                          ; preds = %merge114, %else
  %k130 = load i32, i32* %k
  %layer131 = load i32, i32* %layer
  %_t132 = icmp slt i32 %k130, %layer131
  br i1 %_t132, label %while_body48, label %merge133

while_body48:                                     ; preds = %while47
  %i49 = load i32, i32* %i
  %_t50 = sub i32 %i49, 1
  %i_n151 = load i32, i32* %i_n1
  store i32 %_t50, i32* %i_n1
  %_t52 = load i32, i32* %i_n1
  %i53 = load i32, i32* %i
  %_t54 = add i32 %i53, 1
  %i_p155 = load i32, i32* %i_p1
  store i32 %_t54, i32* %i_p1
  %_t56 = load i32, i32* %i_p1
  %j57 = load i32, i32* %j
  %_t58 = sub i32 %j57, 1
  %j_n159 = load i32, i32* %j_n1
  store i32 %_t58, i32* %j_n1
  %_t60 = load i32, i32* %j_n1
  %j61 = load i32, i32* %j
  %_t62 = add i32 %j61, 1
  %j_p163 = load i32, i32* %j_p1
  store i32 %_t62, i32* %j_p1
  %_t64 = load i32, i32* %j_p1
  %imgIn65 = load %img*, %img** %imgIn1
  %i66 = load i32, i32* %i
  %j67 = load i32, i32* %j
  %k68 = load i32, i32* %k
  %1 = call i32 @__returnImgVal(%img* %imgIn65, i32 %i66, i32 %j67, i32 %k68)
  %_t69 = mul i32 8, %1
  %imgIn70 = load %img*, %img** %imgIn1
  %i_n171 = load i32, i32* %i_n1
  %j_n172 = load i32, i32* %j_n1
  %k73 = load i32, i32* %k
  %2 = call i32 @__returnImgVal(%img* %imgIn70, i32 %i_n171, i32 %j_n172, i32 %k73)
  %_t74 = sub i32 %_t69, %2
  %imgIn75 = load %img*, %img** %imgIn1
  %i_n176 = load i32, i32* %i_n1
  %j77 = load i32, i32* %j
  %k78 = load i32, i32* %k
  %3 = call i32 @__returnImgVal(%img* %imgIn75, i32 %i_n176, i32 %j77, i32 %k78)
  %_t79 = sub i32 %_t74, %3
  %imgIn80 = load %img*, %img** %imgIn1
  %i_n181 = load i32, i32* %i_n1
  %j_p182 = load i32, i32* %j_p1
  %k83 = load i32, i32* %k
  %4 = call i32 @__returnImgVal(%img* %imgIn80, i32 %i_n181, i32 %j_p182, i32 %k83)
  %_t84 = sub i32 %_t79, %4
  %imgIn85 = load %img*, %img** %imgIn1
  %i86 = load i32, i32* %i
  %j_n187 = load i32, i32* %j_n1
  %k88 = load i32, i32* %k
  %5 = call i32 @__returnImgVal(%img* %imgIn85, i32 %i86, i32 %j_n187, i32 %k88)
  %_t89 = sub i32 %_t84, %5
  %imgIn90 = load %img*, %img** %imgIn1
  %i91 = load i32, i32* %i
  %j_p192 = load i32, i32* %j_p1
  %k93 = load i32, i32* %k
  %6 = call i32 @__returnImgVal(%img* %imgIn90, i32 %i91, i32 %j_p192, i32 %k93)
  %_t94 = sub i32 %_t89, %6
  %imgIn95 = load %img*, %img** %imgIn1
  %i_p196 = load i32, i32* %i_p1
  %j_n197 = load i32, i32* %j_n1
  %k98 = load i32, i32* %k
  %7 = call i32 @__returnImgVal(%img* %imgIn95, i32 %i_p196, i32 %j_n197, i32 %k98)
  %_t99 = sub i32 %_t94, %7
  %imgIn100 = load %img*, %img** %imgIn1
  %i_p1101 = load i32, i32* %i_p1
  %j102 = load i32, i32* %j
  %k103 = load i32, i32* %k
  %8 = call i32 @__returnImgVal(%img* %imgIn100, i32 %i_p1101, i32 %j102, i32 %k103)
  %_t104 = sub i32 %_t99, %8
  %imgIn105 = load %img*, %img** %imgIn1
  %i_p1106 = load i32, i32* %i_p1
  %j_p1107 = load i32, i32* %j_p1
  %k108 = load i32, i32* %k
  %9 = call i32 @__returnImgVal(%img* %imgIn105, i32 %i_p1106, i32 %j_p1107, i32 %k108)
  %_t109 = sub i32 %_t104, %9
  %gradSumTemp110 = load i32, i32* %gradSumTemp
  store i32 %_t109, i32* %gradSumTemp
  %_t111 = load i32, i32* %gradSumTemp
  %gradSumTemp112 = load i32, i32* %gradSumTemp
  %_t113 = icmp slt i32 %gradSumTemp112, 0
  br i1 %_t113, label %then115, label %else120

merge114:                                         ; preds = %else120, %then115
  %gradSum121 = load i32, i32* %gradSum
  %gradSumTemp122 = load i32, i32* %gradSumTemp
  %_t123 = add i32 %gradSum121, %gradSumTemp122
  %gradSum124 = load i32, i32* %gradSum
  store i32 %_t123, i32* %gradSum
  %_t125 = load i32, i32* %gradSum
  %k126 = load i32, i32* %k
  %_t127 = add i32 %k126, 1
  %k128 = load i32, i32* %k
  store i32 %_t127, i32* %k
  %_t129 = load i32, i32* %k
  br label %while47

then115:                                          ; preds = %while_body48
  %gradSumTemp116 = load i32, i32* %gradSumTemp
  %_t117 = sub i32 0, %gradSumTemp116
  %gradSumTemp118 = load i32, i32* %gradSumTemp
  store i32 %_t117, i32* %gradSumTemp
  %_t119 = load i32, i32* %gradSumTemp
  br label %merge114

else120:                                          ; preds = %while_body48
  br label %merge114

merge133:                                         ; preds = %while47
  %gradSum134 = load i32, i32* %gradSum
  %layer135 = load i32, i32* %layer
  %_t136 = sdiv i32 %gradSum134, %layer135
  %gradSum137 = load i32, i32* %gradSum
  store i32 %_t136, i32* %gradSum
  %_t138 = load i32, i32* %gradSum
  %gradSum139 = load i32, i32* %gradSum
  %threshold140 = load i32, i32* %threshold2
  %_t141 = icmp sge i32 %gradSum139, %threshold140
  br i1 %_t141, label %then143, label %else164

merge142:                                         ; preds = %merge180, %merge163
  br label %merge

then143:                                          ; preds = %merge133
  %k144 = load i32, i32* %k
  store i32 0, i32* %k
  %_t145 = load i32, i32* %k
  br label %while146

while146:                                         ; preds = %while_body147, %then143
  %k160 = load i32, i32* %k
  %layer161 = load i32, i32* %layer
  %_t162 = icmp slt i32 %k160, %layer161
  br i1 %_t162, label %while_body147, label %merge163

while_body147:                                    ; preds = %while146
  %imgOut148 = load %img*, %img** %imgOut
  %imgIn149 = load %img*, %img** %imgIn1
  %i150 = load i32, i32* %i
  %j151 = load i32, i32* %j
  %k152 = load i32, i32* %k
  %10 = call i32 @__returnImgVal(%img* %imgIn149, i32 %i150, i32 %j151, i32 %k152)
  %i153 = load i32, i32* %i
  %j154 = load i32, i32* %j
  %k155 = load i32, i32* %k
  %11 = call i32 @__setImgVal(i32 %10, %img* %imgOut148, i32 %i153, i32 %j154, i32 %k155)
  %k156 = load i32, i32* %k
  %_t157 = add i32 %k156, 1
  %k158 = load i32, i32* %k
  store i32 %_t157, i32* %k
  %_t159 = load i32, i32* %k
  br label %while146

merge163:                                         ; preds = %while146
  br label %merge142

else164:                                          ; preds = %merge133
  %k165 = load i32, i32* %k
  store i32 0, i32* %k
  %_t166 = load i32, i32* %k
  br label %while167

while167:                                         ; preds = %while_body168, %else164
  %k177 = load i32, i32* %k
  %layer178 = load i32, i32* %layer
  %_t179 = icmp slt i32 %k177, %layer178
  br i1 %_t179, label %while_body168, label %merge180

while_body168:                                    ; preds = %while167
  %imgOut169 = load %img*, %img** %imgOut
  %i170 = load i32, i32* %i
  %j171 = load i32, i32* %j
  %k172 = load i32, i32* %k
  %12 = call i32 @__setImgVal(i32 0, %img* %imgOut169, i32 %i170, i32 %j171, i32 %k172)
  %k173 = load i32, i32* %k
  %_t174 = add i32 %k173, 1
  %k175 = load i32, i32* %k
  store i32 %_t174, i32* %k
  %_t176 = load i32, i32* %k
  br label %while167

merge180:                                         ; preds = %while167
  br label %merge142

merge188:                                         ; preds = %while10
  %i189 = load i32, i32* %i
  %_t190 = add i32 %i189, 1
  %i191 = load i32, i32* %i
  store i32 %_t190, i32* %i
  %_t192 = load i32, i32* %i
  br label %while

merge196:                                         ; preds = %while
  %imgOut197 = load %img*, %img** %imgOut
  ret %img* %imgOut197
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
  %row4 = load i32, i32* %row
  %col5 = load i32, i32* %col
  %malloc_img_result = call %img* @malloc_img(i32 %row4, i32 %col5)
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
  %_t = load i32, i32* %i
  br label %while

while:                                            ; preds = %merge, %entry
  %i47 = load i32, i32* %i
  %row48 = load i32, i32* %row
  %_t49 = icmp slt i32 %i47, %row48
  br i1 %_t49, label %while_body, label %merge50

while_body:                                       ; preds = %while
  %j7 = load i32, i32* %j
  store i32 0, i32* %j
  %_t8 = load i32, i32* %j
  br label %while9

while9:                                           ; preds = %while_body10, %while_body
  %j40 = load i32, i32* %j
  %col41 = load i32, i32* %col
  %_t42 = icmp slt i32 %j40, %col41
  br i1 %_t42, label %while_body10, label %merge

while_body10:                                     ; preds = %while9
  %r_sum11 = load i32, i32* %r_sum
  %imgIn12 = load %img*, %img** %imgIn1
  %i13 = load i32, i32* %i
  %j14 = load i32, i32* %j
  %0 = call i32 @__returnImgVal(%img* %imgIn12, i32 %i13, i32 %j14, i32 0)
  %_t15 = add i32 %r_sum11, %0
  %r_sum16 = load i32, i32* %r_sum
  store i32 %_t15, i32* %r_sum
  %_t17 = load i32, i32* %r_sum
  %g_sum18 = load i32, i32* %g_sum
  %imgIn19 = load %img*, %img** %imgIn1
  %i20 = load i32, i32* %i
  %j21 = load i32, i32* %j
  %1 = call i32 @__returnImgVal(%img* %imgIn19, i32 %i20, i32 %j21, i32 1)
  %_t22 = add i32 %g_sum18, %1
  %g_sum23 = load i32, i32* %g_sum
  store i32 %_t22, i32* %g_sum
  %_t24 = load i32, i32* %g_sum
  %b_sum25 = load i32, i32* %b_sum
  %imgIn26 = load %img*, %img** %imgIn1
  %i27 = load i32, i32* %i
  %j28 = load i32, i32* %j
  %2 = call i32 @__returnImgVal(%img* %imgIn26, i32 %i27, i32 %j28, i32 2)
  %_t29 = add i32 %b_sum25, %2
  %b_sum30 = load i32, i32* %b_sum
  store i32 %_t29, i32* %b_sum
  %_t31 = load i32, i32* %b_sum
  %pixel_count32 = load i32, i32* %pixel_count
  %_t33 = add i32 %pixel_count32, 1
  %pixel_count34 = load i32, i32* %pixel_count
  store i32 %_t33, i32* %pixel_count
  %_t35 = load i32, i32* %pixel_count
  %j36 = load i32, i32* %j
  %_t37 = add i32 %j36, 1
  %j38 = load i32, i32* %j
  store i32 %_t37, i32* %j
  %_t39 = load i32, i32* %j
  br label %while9

merge:                                            ; preds = %while9
  %i43 = load i32, i32* %i
  %_t44 = add i32 %i43, 1
  %i45 = load i32, i32* %i
  store i32 %_t44, i32* %i
  %_t46 = load i32, i32* %i
  br label %while

merge50:                                          ; preds = %while
  %all_sum = alloca i32
  %r_sum51 = load i32, i32* %r_sum
  %g_sum52 = load i32, i32* %g_sum
  %_t53 = add i32 %r_sum51, %g_sum52
  %b_sum54 = load i32, i32* %b_sum
  %_t55 = add i32 %_t53, %b_sum54
  store i32 %_t55, i32* %all_sum
  %r_factor = alloca double
  %all_sum56 = load i32, i32* %all_sum
  %int2float_result = call double @int2float(i32 %all_sum56)
  %r_sum57 = load i32, i32* %r_sum
  %int2float_result58 = call double @int2float(i32 %r_sum57)
  %tmp = fmul double %int2float_result58, 3.000000e+00
  %tmp59 = fdiv double %int2float_result, %tmp
  store double %tmp59, double* %r_factor
  %g_factor = alloca double
  %all_sum60 = load i32, i32* %all_sum
  %int2float_result61 = call double @int2float(i32 %all_sum60)
  %g_sum62 = load i32, i32* %g_sum
  %int2float_result63 = call double @int2float(i32 %g_sum62)
  %tmp64 = fmul double %int2float_result63, 3.000000e+00
  %tmp65 = fdiv double %int2float_result61, %tmp64
  store double %tmp65, double* %g_factor
  %b_factor = alloca double
  %all_sum66 = load i32, i32* %all_sum
  %int2float_result67 = call double @int2float(i32 %all_sum66)
  %b_sum68 = load i32, i32* %b_sum
  %int2float_result69 = call double @int2float(i32 %b_sum68)
  %tmp70 = fmul double %int2float_result69, 3.000000e+00
  %tmp71 = fdiv double %int2float_result67, %tmp70
  store double %tmp71, double* %b_factor
  %temp_r = alloca double
  store double 0.000000e+00, double* %temp_r
  %temp_g = alloca double
  store double 0.000000e+00, double* %temp_g
  %temp_b = alloca double
  store double 0.000000e+00, double* %temp_b
  %i72 = load i32, i32* %i
  store i32 0, i32* %i
  %_t73 = load i32, i32* %i
  br label %while74

while74:                                          ; preds = %merge127, %merge50
  %i132 = load i32, i32* %i
  %row133 = load i32, i32* %row
  %_t134 = icmp slt i32 %i132, %row133
  br i1 %_t134, label %while_body75, label %merge135

while_body75:                                     ; preds = %while74
  %j76 = load i32, i32* %j
  store i32 0, i32* %j
  %_t77 = load i32, i32* %j
  br label %while78

while78:                                          ; preds = %while_body79, %while_body75
  %j124 = load i32, i32* %j
  %col125 = load i32, i32* %col
  %_t126 = icmp slt i32 %j124, %col125
  br i1 %_t126, label %while_body79, label %merge127

while_body79:                                     ; preds = %while78
  %imgIn80 = load %img*, %img** %imgIn1
  %i81 = load i32, i32* %i
  %j82 = load i32, i32* %j
  %3 = call i32 @__returnImgVal(%img* %imgIn80, i32 %i81, i32 %j82, i32 0)
  %int2float_result83 = call double @int2float(i32 %3)
  %r_factor84 = load double, double* %r_factor
  %tmp85 = fmul double %int2float_result83, %r_factor84
  %temp_r86 = load double, double* %temp_r
  store double %tmp85, double* %temp_r
  %_t87 = load double, double* %temp_r
  %imgIn88 = load %img*, %img** %imgIn1
  %i89 = load i32, i32* %i
  %j90 = load i32, i32* %j
  %4 = call i32 @__returnImgVal(%img* %imgIn88, i32 %i89, i32 %j90, i32 1)
  %int2float_result91 = call double @int2float(i32 %4)
  %g_factor92 = load double, double* %g_factor
  %tmp93 = fmul double %int2float_result91, %g_factor92
  %temp_g94 = load double, double* %temp_g
  store double %tmp93, double* %temp_g
  %_t95 = load double, double* %temp_g
  %imgIn96 = load %img*, %img** %imgIn1
  %i97 = load i32, i32* %i
  %j98 = load i32, i32* %j
  %5 = call i32 @__returnImgVal(%img* %imgIn96, i32 %i97, i32 %j98, i32 2)
  %int2float_result99 = call double @int2float(i32 %5)
  %b_factor100 = load double, double* %b_factor
  %tmp101 = fmul double %int2float_result99, %b_factor100
  %temp_b102 = load double, double* %temp_b
  store double %tmp101, double* %temp_b
  %_t103 = load double, double* %temp_b
  %imgOut104 = load %img*, %img** %imgOut
  %temp_r105 = load double, double* %temp_r
  %float2int_result = call i32 @float2int(double %temp_r105)
  %relu_int_result = call i32 @relu_int(i32 %float2int_result)
  %i106 = load i32, i32* %i
  %j107 = load i32, i32* %j
  %6 = call i32 @__setImgVal(i32 %relu_int_result, %img* %imgOut104, i32 %i106, i32 %j107, i32 0)
  %imgOut108 = load %img*, %img** %imgOut
  %temp_g109 = load double, double* %temp_g
  %float2int_result110 = call i32 @float2int(double %temp_g109)
  %relu_int_result111 = call i32 @relu_int(i32 %float2int_result110)
  %i112 = load i32, i32* %i
  %j113 = load i32, i32* %j
  %7 = call i32 @__setImgVal(i32 %relu_int_result111, %img* %imgOut108, i32 %i112, i32 %j113, i32 1)
  %imgOut114 = load %img*, %img** %imgOut
  %temp_b115 = load double, double* %temp_b
  %float2int_result116 = call i32 @float2int(double %temp_b115)
  %relu_int_result117 = call i32 @relu_int(i32 %float2int_result116)
  %i118 = load i32, i32* %i
  %j119 = load i32, i32* %j
  %8 = call i32 @__setImgVal(i32 %relu_int_result117, %img* %imgOut114, i32 %i118, i32 %j119, i32 2)
  %j120 = load i32, i32* %j
  %_t121 = add i32 %j120, 1
  %j122 = load i32, i32* %j
  store i32 %_t121, i32* %j
  %_t123 = load i32, i32* %j
  br label %while78

merge127:                                         ; preds = %while78
  %i128 = load i32, i32* %i
  %_t129 = add i32 %i128, 1
  %i130 = load i32, i32* %i
  store i32 %_t129, i32* %i
  %_t131 = load i32, i32* %i
  br label %while74

merge135:                                         ; preds = %while74
  %imgOut136 = load %img*, %img** %imgOut
  ret %img* %imgOut136
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
  %row8 = load i32, i32* %row
  %col9 = load i32, i32* %col
  %malloc_img_result = call %img* @malloc_img(i32 %row8, i32 %col9)
  store %img* %malloc_img_result, %img** %imgOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %i10 = load i32, i32* %i
  store i32 0, i32* %i
  %_t = load i32, i32* %i
  br label %while

while:                                            ; preds = %merge131, %entry
  %i136 = load i32, i32* %i
  %row137 = load i32, i32* %row
  %_t138 = icmp slt i32 %i136, %row137
  br i1 %_t138, label %while_body, label %merge139

while_body:                                       ; preds = %while
  %j11 = load i32, i32* %j
  store i32 0, i32* %j
  %_t12 = load i32, i32* %j
  br label %while13

while13:                                          ; preds = %merge70, %while_body
  %j128 = load i32, i32* %j
  %col129 = load i32, i32* %col
  %_t130 = icmp slt i32 %j128, %col129
  br i1 %_t130, label %while_body14, label %merge131

while_body14:                                     ; preds = %while13
  %option15 = load i8*, i8** %option5
  %_t16 = icmp eq i8* %option15, getelementptr inbounds ([8 x i8], [8 x i8]* @str, i32 0, i32 0)
  br i1 %_t16, label %then, label %else67

merge:                                            ; preds = %else67, %merge55
  %option68 = load i8*, i8** %option5
  %_t69 = icmp eq i8* %option68, getelementptr inbounds ([5 x i8], [5 x i8]* @str.4, i32 0, i32 0)
  br i1 %_t69, label %then71, label %else123

then:                                             ; preds = %while_body14
  %imgIn17 = load %img*, %img** %imgIn1
  %i18 = load i32, i32* %i
  %j19 = load i32, i32* %j
  %0 = call i32 @__returnImgVal(%img* %imgIn17, i32 %i18, i32 %j19, i32 0)
  %r_threshold20 = load i32, i32* %r_threshold2
  %_t21 = icmp sgt i32 %0, %r_threshold20
  br i1 %_t21, label %then23, label %else

merge22:                                          ; preds = %else, %then23
  %imgIn33 = load %img*, %img** %imgIn1
  %i34 = load i32, i32* %i
  %j35 = load i32, i32* %j
  %1 = call i32 @__returnImgVal(%img* %imgIn33, i32 %i34, i32 %j35, i32 1)
  %g_threshold36 = load i32, i32* %g_threshold3
  %_t37 = icmp sgt i32 %1, %g_threshold36
  br i1 %_t37, label %then39, label %else46

then23:                                           ; preds = %then
  %imgOut24 = load %img*, %img** %imgOut
  %imgIn25 = load %img*, %img** %imgIn1
  %i26 = load i32, i32* %i
  %j27 = load i32, i32* %j
  %2 = call i32 @__returnImgVal(%img* %imgIn25, i32 %i26, i32 %j27, i32 0)
  %i28 = load i32, i32* %i
  %j29 = load i32, i32* %j
  %3 = call i32 @__setImgVal(i32 %2, %img* %imgOut24, i32 %i28, i32 %j29, i32 0)
  br label %merge22

else:                                             ; preds = %then
  %imgOut30 = load %img*, %img** %imgOut
  %i31 = load i32, i32* %i
  %j32 = load i32, i32* %j
  %4 = call i32 @__setImgVal(i32 0, %img* %imgOut30, i32 %i31, i32 %j32, i32 0)
  br label %merge22

merge38:                                          ; preds = %else46, %then39
  %imgIn50 = load %img*, %img** %imgIn1
  %i51 = load i32, i32* %i
  %j52 = load i32, i32* %j
  %5 = call i32 @__returnImgVal(%img* %imgIn50, i32 %i51, i32 %j52, i32 2)
  %b_threshold53 = load i32, i32* %b_threshold4
  %_t54 = icmp sgt i32 %5, %b_threshold53
  br i1 %_t54, label %then56, label %else63

then39:                                           ; preds = %merge22
  %imgOut40 = load %img*, %img** %imgOut
  %imgIn41 = load %img*, %img** %imgIn1
  %i42 = load i32, i32* %i
  %j43 = load i32, i32* %j
  %6 = call i32 @__returnImgVal(%img* %imgIn41, i32 %i42, i32 %j43, i32 1)
  %i44 = load i32, i32* %i
  %j45 = load i32, i32* %j
  %7 = call i32 @__setImgVal(i32 %6, %img* %imgOut40, i32 %i44, i32 %j45, i32 1)
  br label %merge38

else46:                                           ; preds = %merge22
  %imgOut47 = load %img*, %img** %imgOut
  %i48 = load i32, i32* %i
  %j49 = load i32, i32* %j
  %8 = call i32 @__setImgVal(i32 0, %img* %imgOut47, i32 %i48, i32 %j49, i32 1)
  br label %merge38

merge55:                                          ; preds = %else63, %then56
  br label %merge

then56:                                           ; preds = %merge38
  %imgOut57 = load %img*, %img** %imgOut
  %imgIn58 = load %img*, %img** %imgIn1
  %i59 = load i32, i32* %i
  %j60 = load i32, i32* %j
  %9 = call i32 @__returnImgVal(%img* %imgIn58, i32 %i59, i32 %j60, i32 2)
  %i61 = load i32, i32* %i
  %j62 = load i32, i32* %j
  %10 = call i32 @__setImgVal(i32 %9, %img* %imgOut57, i32 %i61, i32 %j62, i32 2)
  br label %merge55

else63:                                           ; preds = %merge38
  %imgOut64 = load %img*, %img** %imgOut
  %i65 = load i32, i32* %i
  %j66 = load i32, i32* %j
  %11 = call i32 @__setImgVal(i32 0, %img* %imgOut64, i32 %i65, i32 %j66, i32 2)
  br label %merge55

else67:                                           ; preds = %while_body14
  br label %merge

merge70:                                          ; preds = %else123, %merge111
  %j124 = load i32, i32* %j
  %_t125 = add i32 %j124, 1
  %j126 = load i32, i32* %j
  store i32 %_t125, i32* %j
  %_t127 = load i32, i32* %j
  br label %while13

then71:                                           ; preds = %merge
  %imgIn72 = load %img*, %img** %imgIn1
  %i73 = load i32, i32* %i
  %j74 = load i32, i32* %j
  %12 = call i32 @__returnImgVal(%img* %imgIn72, i32 %i73, i32 %j74, i32 0)
  %r_threshold75 = load i32, i32* %r_threshold2
  %_t76 = icmp slt i32 %12, %r_threshold75
  br i1 %_t76, label %then78, label %else85

merge77:                                          ; preds = %else85, %then78
  %imgIn89 = load %img*, %img** %imgIn1
  %i90 = load i32, i32* %i
  %j91 = load i32, i32* %j
  %13 = call i32 @__returnImgVal(%img* %imgIn89, i32 %i90, i32 %j91, i32 1)
  %g_threshold92 = load i32, i32* %g_threshold3
  %_t93 = icmp slt i32 %13, %g_threshold92
  br i1 %_t93, label %then95, label %else102

then78:                                           ; preds = %then71
  %imgOut79 = load %img*, %img** %imgOut
  %imgIn80 = load %img*, %img** %imgIn1
  %i81 = load i32, i32* %i
  %j82 = load i32, i32* %j
  %14 = call i32 @__returnImgVal(%img* %imgIn80, i32 %i81, i32 %j82, i32 0)
  %i83 = load i32, i32* %i
  %j84 = load i32, i32* %j
  %15 = call i32 @__setImgVal(i32 %14, %img* %imgOut79, i32 %i83, i32 %j84, i32 0)
  br label %merge77

else85:                                           ; preds = %then71
  %imgOut86 = load %img*, %img** %imgOut
  %i87 = load i32, i32* %i
  %j88 = load i32, i32* %j
  %16 = call i32 @__setImgVal(i32 0, %img* %imgOut86, i32 %i87, i32 %j88, i32 0)
  br label %merge77

merge94:                                          ; preds = %else102, %then95
  %imgIn106 = load %img*, %img** %imgIn1
  %i107 = load i32, i32* %i
  %j108 = load i32, i32* %j
  %17 = call i32 @__returnImgVal(%img* %imgIn106, i32 %i107, i32 %j108, i32 2)
  %b_threshold109 = load i32, i32* %b_threshold4
  %_t110 = icmp slt i32 %17, %b_threshold109
  br i1 %_t110, label %then112, label %else119

then95:                                           ; preds = %merge77
  %imgOut96 = load %img*, %img** %imgOut
  %imgIn97 = load %img*, %img** %imgIn1
  %i98 = load i32, i32* %i
  %j99 = load i32, i32* %j
  %18 = call i32 @__returnImgVal(%img* %imgIn97, i32 %i98, i32 %j99, i32 1)
  %i100 = load i32, i32* %i
  %j101 = load i32, i32* %j
  %19 = call i32 @__setImgVal(i32 %18, %img* %imgOut96, i32 %i100, i32 %j101, i32 1)
  br label %merge94

else102:                                          ; preds = %merge77
  %imgOut103 = load %img*, %img** %imgOut
  %i104 = load i32, i32* %i
  %j105 = load i32, i32* %j
  %20 = call i32 @__setImgVal(i32 0, %img* %imgOut103, i32 %i104, i32 %j105, i32 1)
  br label %merge94

merge111:                                         ; preds = %else119, %then112
  br label %merge70

then112:                                          ; preds = %merge94
  %imgOut113 = load %img*, %img** %imgOut
  %imgIn114 = load %img*, %img** %imgIn1
  %i115 = load i32, i32* %i
  %j116 = load i32, i32* %j
  %21 = call i32 @__returnImgVal(%img* %imgIn114, i32 %i115, i32 %j116, i32 2)
  %i117 = load i32, i32* %i
  %j118 = load i32, i32* %j
  %22 = call i32 @__setImgVal(i32 %21, %img* %imgOut113, i32 %i117, i32 %j118, i32 2)
  br label %merge111

else119:                                          ; preds = %merge94
  %imgOut120 = load %img*, %img** %imgOut
  %i121 = load i32, i32* %i
  %j122 = load i32, i32* %j
  %23 = call i32 @__setImgVal(i32 0, %img* %imgOut120, i32 %i121, i32 %j122, i32 2)
  br label %merge111

else123:                                          ; preds = %merge
  br label %merge70

merge131:                                         ; preds = %while13
  %i132 = load i32, i32* %i
  %_t133 = add i32 %i132, 1
  %i134 = load i32, i32* %i
  store i32 %_t133, i32* %i
  %_t135 = load i32, i32* %i
  br label %while

merge139:                                         ; preds = %while
  %imgOut140 = load %img*, %img** %imgOut
  ret %img* %imgOut140
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
  %row6 = load i32, i32* %row
  %col7 = load i32, i32* %col
  %malloc_img_result = call %img* @malloc_img(i32 %row6, i32 %col7)
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
  %_t = load i32, i32* %i
  br label %while

while:                                            ; preds = %merge110, %entry
  %i115 = load i32, i32* %i
  %row116 = load i32, i32* %row
  %_t117 = icmp slt i32 %i115, %row116
  br i1 %_t117, label %while_body, label %merge118

while_body:                                       ; preds = %while
  %j9 = load i32, i32* %j
  store i32 0, i32* %j
  %_t10 = load i32, i32* %j
  br label %while11

while11:                                          ; preds = %merge67, %while_body
  %j107 = load i32, i32* %j
  %col108 = load i32, i32* %col
  %_t109 = icmp slt i32 %j107, %col108
  br i1 %_t109, label %while_body12, label %merge110

while_body12:                                     ; preds = %while11
  %imgIn13 = load %img*, %img** %imgIn1
  %i14 = load i32, i32* %i
  %j15 = load i32, i32* %j
  %0 = call i32 @__returnImgVal(%img* %imgIn13, i32 %i14, i32 %j15, i32 0)
  %imgIn16 = load %img*, %img** %imgIn1
  %i17 = load i32, i32* %i
  %j18 = load i32, i32* %j
  %1 = call i32 @__returnImgVal(%img* %imgIn16, i32 %i17, i32 %j18, i32 1)
  %_t19 = add i32 %0, %1
  %imgIn20 = load %img*, %img** %imgIn1
  %i21 = load i32, i32* %i
  %j22 = load i32, i32* %j
  %2 = call i32 @__returnImgVal(%img* %imgIn20, i32 %i21, i32 %j22, i32 2)
  %_t23 = add i32 %_t19, %2
  %channel_sum24 = load i32, i32* %channel_sum
  store i32 %_t23, i32* %channel_sum
  %_t25 = load i32, i32* %channel_sum
  %channel_sum26 = load i32, i32* %channel_sum
  %_t27 = sdiv i32 %channel_sum26, 3
  %channel_ave28 = load i32, i32* %channel_ave
  store i32 %_t27, i32* %channel_ave
  %_t29 = load i32, i32* %channel_ave
  %option30 = load i8*, i8** %option3
  %_t31 = icmp eq i8* %option30, getelementptr inbounds ([8 x i8], [8 x i8]* @str.5, i32 0, i32 0)
  br i1 %_t31, label %then, label %else64

merge:                                            ; preds = %else64, %merge35
  %option65 = load i8*, i8** %option3
  %_t66 = icmp eq i8* %option65, getelementptr inbounds ([5 x i8], [5 x i8]* @str.6, i32 0, i32 0)
  br i1 %_t66, label %then68, label %else102

then:                                             ; preds = %while_body12
  %channel_ave32 = load i32, i32* %channel_ave
  %threshold33 = load i32, i32* %threshold2
  %_t34 = icmp sgt i32 %channel_ave32, %threshold33
  br i1 %_t34, label %then36, label %else

merge35:                                          ; preds = %else, %then36
  br label %merge

then36:                                           ; preds = %then
  %imgOut37 = load %img*, %img** %imgOut
  %imgIn38 = load %img*, %img** %imgIn1
  %i39 = load i32, i32* %i
  %j40 = load i32, i32* %j
  %3 = call i32 @__returnImgVal(%img* %imgIn38, i32 %i39, i32 %j40, i32 0)
  %i41 = load i32, i32* %i
  %j42 = load i32, i32* %j
  %4 = call i32 @__setImgVal(i32 %3, %img* %imgOut37, i32 %i41, i32 %j42, i32 0)
  %imgOut43 = load %img*, %img** %imgOut
  %imgIn44 = load %img*, %img** %imgIn1
  %i45 = load i32, i32* %i
  %j46 = load i32, i32* %j
  %5 = call i32 @__returnImgVal(%img* %imgIn44, i32 %i45, i32 %j46, i32 1)
  %i47 = load i32, i32* %i
  %j48 = load i32, i32* %j
  %6 = call i32 @__setImgVal(i32 %5, %img* %imgOut43, i32 %i47, i32 %j48, i32 1)
  %imgOut49 = load %img*, %img** %imgOut
  %imgIn50 = load %img*, %img** %imgIn1
  %i51 = load i32, i32* %i
  %j52 = load i32, i32* %j
  %7 = call i32 @__returnImgVal(%img* %imgIn50, i32 %i51, i32 %j52, i32 2)
  %i53 = load i32, i32* %i
  %j54 = load i32, i32* %j
  %8 = call i32 @__setImgVal(i32 %7, %img* %imgOut49, i32 %i53, i32 %j54, i32 2)
  br label %merge35

else:                                             ; preds = %then
  %imgOut55 = load %img*, %img** %imgOut
  %i56 = load i32, i32* %i
  %j57 = load i32, i32* %j
  %9 = call i32 @__setImgVal(i32 0, %img* %imgOut55, i32 %i56, i32 %j57, i32 0)
  %imgOut58 = load %img*, %img** %imgOut
  %i59 = load i32, i32* %i
  %j60 = load i32, i32* %j
  %10 = call i32 @__setImgVal(i32 0, %img* %imgOut58, i32 %i59, i32 %j60, i32 1)
  %imgOut61 = load %img*, %img** %imgOut
  %i62 = load i32, i32* %i
  %j63 = load i32, i32* %j
  %11 = call i32 @__setImgVal(i32 0, %img* %imgOut61, i32 %i62, i32 %j63, i32 2)
  br label %merge35

else64:                                           ; preds = %while_body12
  br label %merge

merge67:                                          ; preds = %else102, %merge72
  %j103 = load i32, i32* %j
  %_t104 = add i32 %j103, 1
  %j105 = load i32, i32* %j
  store i32 %_t104, i32* %j
  %_t106 = load i32, i32* %j
  br label %while11

then68:                                           ; preds = %merge
  %channel_ave69 = load i32, i32* %channel_ave
  %threshold70 = load i32, i32* %threshold2
  %_t71 = icmp slt i32 %channel_ave69, %threshold70
  br i1 %_t71, label %then73, label %else92

merge72:                                          ; preds = %else92, %then73
  br label %merge67

then73:                                           ; preds = %then68
  %imgOut74 = load %img*, %img** %imgOut
  %imgIn75 = load %img*, %img** %imgIn1
  %i76 = load i32, i32* %i
  %j77 = load i32, i32* %j
  %12 = call i32 @__returnImgVal(%img* %imgIn75, i32 %i76, i32 %j77, i32 0)
  %i78 = load i32, i32* %i
  %j79 = load i32, i32* %j
  %13 = call i32 @__setImgVal(i32 %12, %img* %imgOut74, i32 %i78, i32 %j79, i32 0)
  %imgOut80 = load %img*, %img** %imgOut
  %imgIn81 = load %img*, %img** %imgIn1
  %i82 = load i32, i32* %i
  %j83 = load i32, i32* %j
  %14 = call i32 @__returnImgVal(%img* %imgIn81, i32 %i82, i32 %j83, i32 1)
  %i84 = load i32, i32* %i
  %j85 = load i32, i32* %j
  %15 = call i32 @__setImgVal(i32 %14, %img* %imgOut80, i32 %i84, i32 %j85, i32 1)
  %imgOut86 = load %img*, %img** %imgOut
  %imgIn87 = load %img*, %img** %imgIn1
  %i88 = load i32, i32* %i
  %j89 = load i32, i32* %j
  %16 = call i32 @__returnImgVal(%img* %imgIn87, i32 %i88, i32 %j89, i32 2)
  %i90 = load i32, i32* %i
  %j91 = load i32, i32* %j
  %17 = call i32 @__setImgVal(i32 %16, %img* %imgOut86, i32 %i90, i32 %j91, i32 2)
  br label %merge72

else92:                                           ; preds = %then68
  %imgOut93 = load %img*, %img** %imgOut
  %i94 = load i32, i32* %i
  %j95 = load i32, i32* %j
  %18 = call i32 @__setImgVal(i32 0, %img* %imgOut93, i32 %i94, i32 %j95, i32 0)
  %imgOut96 = load %img*, %img** %imgOut
  %i97 = load i32, i32* %i
  %j98 = load i32, i32* %j
  %19 = call i32 @__setImgVal(i32 0, %img* %imgOut96, i32 %i97, i32 %j98, i32 1)
  %imgOut99 = load %img*, %img** %imgOut
  %i100 = load i32, i32* %i
  %j101 = load i32, i32* %j
  %20 = call i32 @__setImgVal(i32 0, %img* %imgOut99, i32 %i100, i32 %j101, i32 2)
  br label %merge72

else102:                                          ; preds = %merge
  br label %merge67

merge110:                                         ; preds = %while11
  %i111 = load i32, i32* %i
  %_t112 = add i32 %i111, 1
  %i113 = load i32, i32* %i
  store i32 %_t112, i32* %i
  %_t114 = load i32, i32* %i
  br label %while

merge118:                                         ; preds = %while
  %imgOut119 = load %img*, %img** %imgOut
  ret %img* %imgOut119
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
  %row5 = load i32, i32* %row
  %col6 = load i32, i32* %col
  %malloc_mat_result = call %mat* @malloc_mat(i32 %row5, i32 %col6)
  store %mat* %malloc_mat_result, %mat** %matOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %i7 = load i32, i32* %i
  store i32 0, i32* %i
  %_t = load i32, i32* %i
  br label %while

while:                                            ; preds = %merge, %entry
  %i30 = load i32, i32* %i
  %row31 = load i32, i32* %row
  %_t32 = icmp slt i32 %i30, %row31
  br i1 %_t32, label %while_body, label %merge33

while_body:                                       ; preds = %while
  %j8 = load i32, i32* %j
  store i32 0, i32* %j
  %_t9 = load i32, i32* %j
  br label %while10

while10:                                          ; preds = %while_body11, %while_body
  %j23 = load i32, i32* %j
  %col24 = load i32, i32* %col
  %_t25 = icmp slt i32 %j23, %col24
  br i1 %_t25, label %while_body11, label %merge

while_body11:                                     ; preds = %while10
  %matOut12 = load %mat*, %mat** %matOut
  %matIn13 = load %mat*, %mat** %matIn1
  %i14 = load i32, i32* %i
  %j15 = load i32, i32* %j
  %0 = call double @__returnMatVal(%mat* %matIn13, i32 %i14, i32 %j15)
  %c16 = load double, double* %c2
  %tmp = fadd double %0, %c16
  %i17 = load i32, i32* %i
  %j18 = load i32, i32* %j
  %1 = call i32 @__setMatVal(double %tmp, %mat* %matOut12, i32 %i17, i32 %j18)
  %j19 = load i32, i32* %j
  %_t20 = add i32 %j19, 1
  %j21 = load i32, i32* %j
  store i32 %_t20, i32* %j
  %_t22 = load i32, i32* %j
  br label %while10

merge:                                            ; preds = %while10
  %i26 = load i32, i32* %i
  %_t27 = add i32 %i26, 1
  %i28 = load i32, i32* %i
  store i32 %_t27, i32* %i
  %_t29 = load i32, i32* %i
  br label %while

merge33:                                          ; preds = %while
  %matOut34 = load %mat*, %mat** %matOut
  ret %mat* %matOut34
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
  %row5 = load i32, i32* %row
  %col6 = load i32, i32* %col
  %malloc_img_result = call %img* @malloc_img(i32 %row5, i32 %col6)
  store %img* %malloc_img_result, %img** %imgOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %i7 = load i32, i32* %i
  store i32 0, i32* %i
  %_t = load i32, i32* %i
  br label %while

while:                                            ; preds = %merge39, %entry
  %i44 = load i32, i32* %i
  %row45 = load i32, i32* %row
  %_t46 = icmp slt i32 %i44, %row45
  br i1 %_t46, label %while_body, label %merge47

while_body:                                       ; preds = %while
  %j8 = load i32, i32* %j
  store i32 0, i32* %j
  %_t9 = load i32, i32* %j
  br label %while10

while10:                                          ; preds = %merge, %while_body
  %j36 = load i32, i32* %j
  %col37 = load i32, i32* %col
  %_t38 = icmp slt i32 %j36, %col37
  br i1 %_t38, label %while_body11, label %merge39

while_body11:                                     ; preds = %while10
  %k12 = load i32, i32* %k
  store i32 0, i32* %k
  %_t13 = load i32, i32* %k
  br label %while14

while14:                                          ; preds = %while_body15, %while_body11
  %k30 = load i32, i32* %k
  %_t31 = icmp slt i32 %k30, 3
  br i1 %_t31, label %while_body15, label %merge

while_body15:                                     ; preds = %while14
  %imgOut16 = load %img*, %img** %imgOut
  %imgIn17 = load %img*, %img** %imgIn1
  %i18 = load i32, i32* %i
  %j19 = load i32, i32* %j
  %k20 = load i32, i32* %k
  %0 = call i32 @__returnImgVal(%img* %imgIn17, i32 %i18, i32 %j19, i32 %k20)
  %c21 = load i32, i32* %c2
  %_t22 = add i32 %0, %c21
  %relu_int_result = call i32 @relu_int(i32 %_t22)
  %i23 = load i32, i32* %i
  %j24 = load i32, i32* %j
  %k25 = load i32, i32* %k
  %1 = call i32 @__setImgVal(i32 %relu_int_result, %img* %imgOut16, i32 %i23, i32 %j24, i32 %k25)
  %k26 = load i32, i32* %k
  %_t27 = add i32 %k26, 1
  %k28 = load i32, i32* %k
  store i32 %_t27, i32* %k
  %_t29 = load i32, i32* %k
  br label %while14

merge:                                            ; preds = %while14
  %j32 = load i32, i32* %j
  %_t33 = add i32 %j32, 1
  %j34 = load i32, i32* %j
  store i32 %_t33, i32* %j
  %_t35 = load i32, i32* %j
  br label %while10

merge39:                                          ; preds = %while10
  %i40 = load i32, i32* %i
  %_t41 = add i32 %i40, 1
  %i42 = load i32, i32* %i
  store i32 %_t41, i32* %i
  %_t43 = load i32, i32* %i
  br label %while

merge47:                                          ; preds = %while
  %imgOut48 = load %img*, %img** %imgOut
  ret %img* %imgOut48
}

define %img* @img_conv(%img* %imgIn, %img* %conv) {
entry:
  %imgIn1 = alloca %img*
  store %img* %imgIn, %img** %imgIn1
  %conv2 = alloca %img*
  store %img* %conv, %img** %conv2
  %conv_w = alloca i32
  %conv3 = load %img*, %img** %conv2
  %_col = call i32 @__imgCol(%img* %conv3)
  %_t = sdiv i32 %_col, 2
  store i32 %_t, i32* %conv_w
  %conv_h = alloca i32
  %conv4 = load %img*, %img** %conv2
  %_row = call i32 @__imgRow(%img* %conv4)
  %_t5 = sdiv i32 %_row, 2
  store i32 %_t5, i32* %conv_h
  %fac_i = alloca i32
  store i32 0, i32* %fac_i
  %fac_j = alloca i32
  store i32 0, i32* %fac_j
  %fac_k = alloca i32
  store i32 0, i32* %fac_k
  %factor_i = alloca i32
  store i32 0, i32* %factor_i
  %factor_j = alloca i32
  store i32 0, i32* %factor_j
  %factor_k = alloca i32
  store i32 0, i32* %factor_k
  %fac_i6 = load i32, i32* %fac_i
  store i32 0, i32* %fac_i
  %_t7 = load i32, i32* %fac_i
  br label %while

while:                                            ; preds = %merge, %entry
  %fac_i47 = load i32, i32* %fac_i
  %conv48 = load %img*, %img** %conv2
  %_row49 = call i32 @__imgRow(%img* %conv48)
  %_t50 = icmp slt i32 %fac_i47, %_row49
  br i1 %_t50, label %while_body, label %merge51

while_body:                                       ; preds = %while
  %fac_j8 = load i32, i32* %fac_j
  store i32 0, i32* %fac_j
  %_t9 = load i32, i32* %fac_j
  br label %while10

while10:                                          ; preds = %while_body11, %while_body
  %fac_j39 = load i32, i32* %fac_j
  %conv40 = load %img*, %img** %conv2
  %_col41 = call i32 @__imgCol(%img* %conv40)
  %_t42 = icmp slt i32 %fac_j39, %_col41
  br i1 %_t42, label %while_body11, label %merge

while_body11:                                     ; preds = %while10
  %factor_i12 = load i32, i32* %factor_i
  %conv13 = load %img*, %img** %conv2
  %fac_i14 = load i32, i32* %fac_i
  %fac_j15 = load i32, i32* %fac_j
  %0 = call i32 @__returnImgVal(%img* %conv13, i32 %fac_i14, i32 %fac_j15, i32 0)
  %abs_int_result = call i32 @abs_int(i32 %0)
  %_t16 = add i32 %factor_i12, %abs_int_result
  %factor_i17 = load i32, i32* %factor_i
  store i32 %_t16, i32* %factor_i
  %_t18 = load i32, i32* %factor_i
  %factor_j19 = load i32, i32* %factor_j
  %conv20 = load %img*, %img** %conv2
  %fac_i21 = load i32, i32* %fac_i
  %fac_j22 = load i32, i32* %fac_j
  %1 = call i32 @__returnImgVal(%img* %conv20, i32 %fac_i21, i32 %fac_j22, i32 1)
  %abs_int_result23 = call i32 @abs_int(i32 %1)
  %_t24 = add i32 %factor_j19, %abs_int_result23
  %factor_j25 = load i32, i32* %factor_j
  store i32 %_t24, i32* %factor_j
  %_t26 = load i32, i32* %factor_j
  %factor_k27 = load i32, i32* %factor_k
  %conv28 = load %img*, %img** %conv2
  %fac_i29 = load i32, i32* %fac_i
  %fac_j30 = load i32, i32* %fac_j
  %2 = call i32 @__returnImgVal(%img* %conv28, i32 %fac_i29, i32 %fac_j30, i32 2)
  %abs_int_result31 = call i32 @abs_int(i32 %2)
  %_t32 = add i32 %factor_k27, %abs_int_result31
  %factor_k33 = load i32, i32* %factor_k
  store i32 %_t32, i32* %factor_k
  %_t34 = load i32, i32* %factor_k
  %fac_j35 = load i32, i32* %fac_j
  %_t36 = add i32 %fac_j35, 1
  %fac_j37 = load i32, i32* %fac_j
  store i32 %_t36, i32* %fac_j
  %_t38 = load i32, i32* %fac_j
  br label %while10

merge:                                            ; preds = %while10
  %fac_i43 = load i32, i32* %fac_i
  %_t44 = add i32 %fac_i43, 1
  %fac_i45 = load i32, i32* %fac_i
  store i32 %_t44, i32* %fac_i
  %_t46 = load i32, i32* %fac_i
  br label %while

merge51:                                          ; preds = %while
  %row = alloca i32
  %imgIn52 = load %img*, %img** %imgIn1
  %_row53 = call i32 @__imgRow(%img* %imgIn52)
  store i32 %_row53, i32* %row
  %col = alloca i32
  %imgIn54 = load %img*, %img** %imgIn1
  %_col55 = call i32 @__imgCol(%img* %imgIn54)
  store i32 %_col55, i32* %col
  %imgOut = alloca %img*
  %row56 = load i32, i32* %row
  %conv_h57 = load i32, i32* %conv_h
  %_t58 = mul i32 2, %conv_h57
  %_t59 = sub i32 %row56, %_t58
  %col60 = load i32, i32* %col
  %conv_w61 = load i32, i32* %conv_w
  %_t62 = mul i32 2, %conv_w61
  %_t63 = sub i32 %col60, %_t62
  %malloc_img_result = call %img* @malloc_img(i32 %_t59, i32 %_t63)
  store %img* %malloc_img_result, %img** %imgOut
  %i = alloca i32
  store i32 0, i32* %i
  %j = alloca i32
  store i32 0, i32* %j
  %k = alloca i32
  store i32 0, i32* %k
  %m = alloca i32
  store i32 0, i32* %m
  %n = alloca i32
  store i32 0, i32* %n
  %p = alloca i32
  store i32 0, i32* %p
  %temp = alloca i32
  store i32 0, i32* %temp
  %img_i = alloca i32
  store i32 0, i32* %img_i
  %img_j = alloca i32
  store i32 0, i32* %img_j
  %img_k = alloca i32
  store i32 0, i32* %img_k
  %conv_i = alloca i32
  store i32 0, i32* %conv_i
  %conv_j = alloca i32
  store i32 0, i32* %conv_j
  %conv_k = alloca i32
  store i32 0, i32* %conv_k
  %i64 = load i32, i32* %i
  store i32 0, i32* %i
  %_t65 = load i32, i32* %i
  br label %while66

while66:                                          ; preds = %merge201, %merge51
  %i206 = load i32, i32* %i
  %row207 = load i32, i32* %row
  %conv_h208 = load i32, i32* %conv_h
  %_t209 = mul i32 2, %conv_h208
  %_t210 = sub i32 %row207, %_t209
  %_t211 = icmp slt i32 %i206, %_t210
  br i1 %_t211, label %while_body67, label %merge212

while_body67:                                     ; preds = %while66
  %j68 = load i32, i32* %j
  store i32 0, i32* %j
  %_t69 = load i32, i32* %j
  br label %while70

while70:                                          ; preds = %merge190, %while_body67
  %j195 = load i32, i32* %j
  %col196 = load i32, i32* %col
  %conv_w197 = load i32, i32* %conv_w
  %_t198 = mul i32 2, %conv_w197
  %_t199 = sub i32 %col196, %_t198
  %_t200 = icmp slt i32 %j195, %_t199
  br i1 %_t200, label %while_body71, label %merge201

while_body71:                                     ; preds = %while70
  %k72 = load i32, i32* %k
  store i32 0, i32* %k
  %_t73 = load i32, i32* %k
  br label %while74

while74:                                          ; preds = %merge170, %while_body71
  %k188 = load i32, i32* %k
  %_t189 = icmp slt i32 %k188, 3
  br i1 %_t189, label %while_body75, label %merge190

while_body75:                                     ; preds = %while74
  %temp76 = load i32, i32* %temp
  store i32 0, i32* %temp
  %_t77 = load i32, i32* %temp
  %conv_h78 = load i32, i32* %conv_h
  %_t79 = sub i32 0, %conv_h78
  %m80 = load i32, i32* %m
  store i32 %_t79, i32* %m
  %_t81 = load i32, i32* %m
  br label %while82

while82:                                          ; preds = %merge140, %while_body75
  %m145 = load i32, i32* %m
  %conv_h146 = load i32, i32* %conv_h
  %_t147 = icmp slt i32 %m145, %conv_h146
  br i1 %_t147, label %while_body83, label %merge148

while_body83:                                     ; preds = %while82
  %conv_w84 = load i32, i32* %conv_w
  %_t85 = sub i32 0, %conv_w84
  %n86 = load i32, i32* %n
  store i32 %_t85, i32* %n
  %_t87 = load i32, i32* %n
  br label %while88

while88:                                          ; preds = %while_body89, %while_body83
  %n137 = load i32, i32* %n
  %conv_w138 = load i32, i32* %conv_w
  %_t139 = icmp slt i32 %n137, %conv_w138
  br i1 %_t139, label %while_body89, label %merge140

while_body89:                                     ; preds = %while88
  %i90 = load i32, i32* %i
  %m91 = load i32, i32* %m
  %_t92 = add i32 %i90, %m91
  %conv_h93 = load i32, i32* %conv_h
  %_t94 = add i32 %_t92, %conv_h93
  %img_i95 = load i32, i32* %img_i
  store i32 %_t94, i32* %img_i
  %_t96 = load i32, i32* %img_i
  %j97 = load i32, i32* %j
  %n98 = load i32, i32* %n
  %_t99 = add i32 %j97, %n98
  %conv_w100 = load i32, i32* %conv_w
  %_t101 = add i32 %_t99, %conv_w100
  %img_j102 = load i32, i32* %img_j
  store i32 %_t101, i32* %img_j
  %_t103 = load i32, i32* %img_j
  %k104 = load i32, i32* %k
  %img_k105 = load i32, i32* %img_k
  store i32 %k104, i32* %img_k
  %_t106 = load i32, i32* %img_k
  %m107 = load i32, i32* %m
  %conv_h108 = load i32, i32* %conv_h
  %_t109 = add i32 %m107, %conv_h108
  %conv_i110 = load i32, i32* %conv_i
  store i32 %_t109, i32* %conv_i
  %_t111 = load i32, i32* %conv_i
  %n112 = load i32, i32* %n
  %conv_w113 = load i32, i32* %conv_w
  %_t114 = add i32 %n112, %conv_w113
  %conv_j115 = load i32, i32* %conv_j
  store i32 %_t114, i32* %conv_j
  %_t116 = load i32, i32* %conv_j
  %k117 = load i32, i32* %k
  %conv_k118 = load i32, i32* %conv_k
  store i32 %k117, i32* %conv_k
  %_t119 = load i32, i32* %conv_k
  %temp120 = load i32, i32* %temp
  %imgIn121 = load %img*, %img** %imgIn1
  %img_i122 = load i32, i32* %img_i
  %img_j123 = load i32, i32* %img_j
  %img_k124 = load i32, i32* %img_k
  %3 = call i32 @__returnImgVal(%img* %imgIn121, i32 %img_i122, i32 %img_j123, i32 %img_k124)
  %conv125 = load %img*, %img** %conv2
  %conv_i126 = load i32, i32* %conv_i
  %conv_j127 = load i32, i32* %conv_j
  %conv_k128 = load i32, i32* %conv_k
  %4 = call i32 @__returnImgVal(%img* %conv125, i32 %conv_i126, i32 %conv_j127, i32 %conv_k128)
  %_t129 = mul i32 %3, %4
  %_t130 = add i32 %temp120, %_t129
  %temp131 = load i32, i32* %temp
  store i32 %_t130, i32* %temp
  %_t132 = load i32, i32* %temp
  %n133 = load i32, i32* %n
  %_t134 = add i32 %n133, 1
  %n135 = load i32, i32* %n
  store i32 %_t134, i32* %n
  %_t136 = load i32, i32* %n
  br label %while88

merge140:                                         ; preds = %while88
  %m141 = load i32, i32* %m
  %_t142 = add i32 %m141, 1
  %m143 = load i32, i32* %m
  store i32 %_t142, i32* %m
  %_t144 = load i32, i32* %m
  br label %while82

merge148:                                         ; preds = %while82
  %k149 = load i32, i32* %k
  %_t150 = icmp eq i32 %k149, 0
  br i1 %_t150, label %then, label %else

merge151:                                         ; preds = %else, %then
  %k157 = load i32, i32* %k
  %_t158 = icmp eq i32 %k157, 1
  br i1 %_t158, label %then160, label %else167

then:                                             ; preds = %merge148
  %temp152 = load i32, i32* %temp
  %factor_i153 = load i32, i32* %factor_i
  %_t154 = sdiv i32 %temp152, %factor_i153
  %relu_int_result = call i32 @relu_int(i32 %_t154)
  %temp155 = load i32, i32* %temp
  store i32 %relu_int_result, i32* %temp
  %_t156 = load i32, i32* %temp
  br label %merge151

else:                                             ; preds = %merge148
  br label %merge151

merge159:                                         ; preds = %else167, %then160
  %k168 = load i32, i32* %k
  %_t169 = icmp eq i32 %k168, 2
  br i1 %_t169, label %then171, label %else178

then160:                                          ; preds = %merge151
  %temp161 = load i32, i32* %temp
  %factor_j162 = load i32, i32* %factor_j
  %_t163 = sdiv i32 %temp161, %factor_j162
  %relu_int_result164 = call i32 @relu_int(i32 %_t163)
  %temp165 = load i32, i32* %temp
  store i32 %relu_int_result164, i32* %temp
  %_t166 = load i32, i32* %temp
  br label %merge159

else167:                                          ; preds = %merge151
  br label %merge159

merge170:                                         ; preds = %else178, %then171
  %imgOut179 = load %img*, %img** %imgOut
  %temp180 = load i32, i32* %temp
  %i181 = load i32, i32* %i
  %j182 = load i32, i32* %j
  %k183 = load i32, i32* %k
  %5 = call i32 @__setImgVal(i32 %temp180, %img* %imgOut179, i32 %i181, i32 %j182, i32 %k183)
  %k184 = load i32, i32* %k
  %_t185 = add i32 %k184, 1
  %k186 = load i32, i32* %k
  store i32 %_t185, i32* %k
  %_t187 = load i32, i32* %k
  br label %while74

then171:                                          ; preds = %merge159
  %temp172 = load i32, i32* %temp
  %factor_k173 = load i32, i32* %factor_k
  %_t174 = sdiv i32 %temp172, %factor_k173
  %relu_int_result175 = call i32 @relu_int(i32 %_t174)
  %temp176 = load i32, i32* %temp
  store i32 %relu_int_result175, i32* %temp
  %_t177 = load i32, i32* %temp
  br label %merge170

else178:                                          ; preds = %merge159
  br label %merge170

merge190:                                         ; preds = %while74
  %j191 = load i32, i32* %j
  %_t192 = add i32 %j191, 1
  %j193 = load i32, i32* %j
  store i32 %_t192, i32* %j
  %_t194 = load i32, i32* %j
  br label %while70

merge201:                                         ; preds = %while70
  %i202 = load i32, i32* %i
  %_t203 = add i32 %i202, 1
  %i204 = load i32, i32* %i
  store i32 %_t203, i32* %i
  %_t205 = load i32, i32* %i
  br label %while66

merge212:                                         ; preds = %while66
  %imgOut213 = load %img*, %img** %imgOut
  ret %img* %imgOut213
}

define i32 @main() {
entry:
  %a = alloca %img*
  %readimg_result = call %img* @readimg(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @str.7, i32 0, i32 0))
  store %img* %readimg_result, %img** %a
  %aveFilter = alloca %img*
  %a1 = load %img*, %img** %a
  %aveFilter_result = call %img* @aveFilter(%img* %a1, i32 5)
  store %img* %aveFilter_result, %img** %aveFilter
  %aveFilter2 = load %img*, %img** %aveFilter
  %0 = call i32 @saveimg(i8* getelementptr inbounds ([34 x i8], [34 x i8]* @str.8, i32 0, i32 0), %img* %aveFilter2)
  ret i32 0
}
