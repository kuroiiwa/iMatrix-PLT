# iMatrix-PLT project
iMatrix, a language trying to make programming less painful for matrix and image processing.

---
## Test
Run ```./test.sh ```

## Aboout this branch
AST with array type  
Buggy semantic check  
Array type declaration with init is not supported  
Ugly type identifier  
var_symbols in semant now has type **(typ, dimension) StringMap.t**

### Known bugs
Array with only one element return common type instead of array type.  
Info about function type in AST is not complete therefore array type function is not supported.  






## Progress
Arbitrary position for global declarations, function declarations, local declarations and local statements.  
~~Syntactically allow inline initialization. Now inline initialization supports expression. (**TODO** codegen not finished)~~  
Allow inline initialization except for ASSIGN and FUNCTION CALL. (**TODO** expand functionality)  
~~Formals in function has no default initialization yet.  (**TODO** define default semantics and codegen)~~  
Possible bugs in AST, semantic check. (**TODO** need more test)  
Codegen finished. (**TODO** need more test)
Return check will make sure there is at least one return in non-void function and nothing follows return.

## Semantic check list
* Check global binds has no dups
* Check global variable and function declarations line by line
	* global var declaration -> check type match, initialization and add it to symbol table
	* function declaration -> go to check body line by line, add it to symbol table
	* return a list containing **SGlobaldcl** and **SFunc**
* Check global variable and function declarations line by line
	* add arguments to symbol table first
	* check all locals and formals have no void types and dup (**TODO** Should check void type for all blocks but dup only for main block)
	* local var declaration -> check type match, initialization and add it to symbol table
	* statement -> go to check statement
