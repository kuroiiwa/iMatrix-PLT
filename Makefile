RESULT  = imatrix
SOURCES = src/scanner.mll src/microcparse.mly src/ast.ml src/semant.ml src/sast.ml src/codegen.ml src/microc.ml
PACKS = llvm llvm.analysis

all: native-code
	$(MAKE) -C ./lib

OCAMLMAKEFILE = OCamlMakefile
-include OCamlMakefile