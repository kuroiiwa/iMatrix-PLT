# iMatrix-PLT project
iMatrix, a language trying to make programming less painful for matrix and image processing.

# Note
	'pureAst' branch is for testing AST and semantic check

---

# Progress
Arbitrary position for global declarations, function declarations, local declarations and local statements.  
Syntactically allow inline initialization. (**TODO** codegen not finished)  
Possible bugs in AST, semantic check. (**TODO** need more test)  
Codegen finished. (**TODO** need more test)

# Semantic check list
* Check global binds has no void types or dup (could be merged into following checks)
* **Check global variable and function declarations line by line **
	* global var declaration -> check type match, add it to symbol table
	* function declaration -> go to check body line by line, add it to symbol table
	* return a list containing **SGlobaldcl** and **SFunc**
* **Check global variable and function declarations line by line **
	* add arguments to symbol table first
	* check all locals and formals have no void types and dup (**TODO** Should check void type for all blocks but dup only for main block)
	* local var declaration -> check type match and add it to symbol table
	* statement -> go to check statement
