# iMatrix-PLT project
iMatrix, a language trying to make programming less painful for matrix and image processing.

---
## Test
Install opencv lib: ```sudo apt install libopencv-dev``` (Linux environment).  
Run ```make ``` to generate our compiler imatrix and library.  
(Run ```make ``` in lib directory to generate our buult-int library ```lib.a``` separately.)  
For single test file, run ```./imatrix (file) > tmp.ll```  
```clang++ -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o a.out tmp.ll ./lib/lib.a```.  
(opencv lib in compilation flags.)  
Or run ```trytest.sh``` to directly run minitest.im (make sure IR code is generated correctly)  
For our tests files, run ```./ourtest.sh```.  

### Known bugs
 

## Progress
Arbitrary position for global declarations, function declarations, local declarations and local statements.   
Allow inline initialization except for ASSIGN and FUNCTION CALL in global declarations.  
Return check will make sure there is at least one return in non-void function and nothing follows return.  
Array and slicing only for constant.  
Several print functions.  

Matrix and Image functionality needed.  
Struct needed.  

