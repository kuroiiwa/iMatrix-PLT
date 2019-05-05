RESULT  = imatrix
SOURCES = src/scanner.mll src/microcparse.mly src/ast.ml src/sast.ml src/semant.ml src/codegen.ml src/microc.ml
PACKS = llvm llvm.analysis

all: native-code
	$(MAKE) -C ./lib

clean::
	cd ./lib && $(MAKE) clean

OCAMLMAKEFILE = OCamlMakefile
-include OCamlMakefile