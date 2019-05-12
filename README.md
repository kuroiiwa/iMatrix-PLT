# iMatrix-PLT project
iMatrix, a language trying to make programming less painful for matrix and image processing.

## Prerequisite
Install opencv lib: ```sudo apt install libopencv-dev``` (Linux environment).  
Install clang

---
## Test
Run ```make ``` to generate our compiler imatrix and library.  
(Run ```make ``` in lib directory to generate our buult-int library ```lib.a``` separately.)  
For single test file, run ```./imatrix (file) > tmp.ll```   
```clang++ -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o a.out tmp.ll ./lib/lib.a```.  
(opencv lib in compilation flags.)  
Or run ```./trytest.sh {filename}``` to test $filename (make sure IR code is generated correctly)  
For our tests files, run ```./imatrix-testall.sh```.  

### Known bugs
variables can't be declared inside nested blocks(brackets, if, while, for)  

## Progress
Fix potential bugs...  
Improve syntax...  
Writing tests...  
Eliminate memory leak...   
