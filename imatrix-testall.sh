#!/bin/sh

# Regression testing script for iMatrix
# Step through a list of files
#  Compile, run, and check the output of each expected-to-work test
#  Compile and check the error of each expected-to-fail test


IMATRIX="./imatrix"

CLANG="clang++"

LLC="llc"
LLI="lli"

LIB="./lib/lib.a"

CLANGFLAGS="-O2 -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o"

TESTDIR="./testbuild"

TESTFILESDIR=./ourtests
TESTFILES=$TESTFILESDIR/test-*.im
FAILFILES=$TESTFILESDIR/fail-*.im

ulimit -t 30
globallog=testall.log
rm -f $globallog
error=0
globalerror=0
keep=0

Usage() {
    echo "Usage: imatrix-testall.sh [options] [.im files]"
    echo "-k    Keep intermediate files"
    echo "-h    Print this help"
    exit 1
}

SignalError() {
    if [ $error -eq 0 ] ; then
    echo "FAILED"
    error=1
    fi
    echo "  $1"
}

# Run <args>
# Report the command, run it, and report any errors
Run() {
    echo $* 1>&2
    eval $* || {
    SignalError "$1 failed on $*"
    return 1
    }
}

# RunFail <args>
# Report the command, run it, and expect an error
RunFail() {
    echo $* 1>&2
    eval $* && {
    SignalError "failed: $* did not report an error"
    return 1
    }
    return 0
}

# Compare <outfile> <reffile> <difffile>
# Compares the outfile with reffile.  Differences, if any, written to difffile
Compare() {
    generatedfiles="$generatedfiles $3"
    echo diff -b $1 $2 ">" $3 1>&2
    diff -b "$1" "$2" > "$3" 2>&1 || {
    SignalError "$1 differs"
    echo "FAILED $1 differs from $2" 1>&2
    }
}

Check() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.im//'`
    reffile=`echo $1 | sed 's/.im$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."

    echo -n "$basename..."
    echo 1>&2
    echo "###### Testing $basename" 1>&2

    generatedfiles=""

    generatedfiles="$generatedfiles $TESTDIR/${basename}.ll $TESTDIR/${basename}.s $TESTDIR/${basename}.out" &&
    Run "$IMATRIX" "$1" ">" "$TESTDIR/${basename}.ll" &&
    Run "$LLC" "-relocation-model=pic" "$TESTDIR/${basename}.ll" ">" "$TESTDIR/${basename}.s" &&
    Run "$CLANG" "$CLANGFLAGS" "$TESTDIR/${basename}.exe" "$TESTDIR/${basename}.s" "$LIB" &&
    Run "$TESTDIR/${basename}.exe" > "$TESTDIR/${basename}.out"
    Compare $TESTDIR/${basename}.out ${reffile}.out $TESTDIR/${basename}.diff

    if [ $error -eq 0 ] ; then
    if [ $keep -eq 0 ] ; then
        rm -f $generatedfiles
    fi
    echo "OK"
    echo "###### SUCCESS" 1>&2
    else
    echo "###### FAILED" 1>&2
    globalerror=$error
    fi
}

CheckFail() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.im//'`
    reffile=`echo $1 | sed 's/.im$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."

    echo -n "$basename..."

    echo 1>&2
    echo "###### Testing $basename" 1>&2

    generatedfiles=""

    generatedfiles="$generatedfiles $TESTDIR/${basename}.err $TESTDIR/${basename}.diff" &&
    RunFail "$IMATRIX" "<" $1 "2>" "$TESTDIR/${basename}.err" ">>" $globallog &&
    Compare $TESTDIR/${basename}.err ${reffile}.err $TESTDIR/${basename}.diff

    # Report the status and clean up the generated files

    if [ $error -eq 0 ] ; then
    if [ $keep -eq 0 ] ; then
        rm -f $generatedfiles
    fi
    echo "OK"
    echo "###### SUCCESS" 1>&2
    else
    echo "###### FAILED" 1>&2
    globalerror=$error
    fi
}

while getopts kdpsh c; do
    case $c in
    k) # Keep intermediate files
        keep=1
        ;;
    h) # Help
        Usage
        ;;
    esac
done

shift `expr $OPTIND - 1`

LLIFail() {
  echo "Could not find the LLVM interpreter \"$LLI\"."
  echo "Check your LLVM installation and/or modify the LLI variable in testall.sh"
  exit 1
}

which "$LLI" >> $globallog || LLIFail

CLANGFail() {
  echo "Could not find clang \"$CLANG\"."
  echo "Check your clang installation"
  exit 1
}

which "$CLANG" >> $globallog || CLANGFail

if [ ! -f $IMATRIX ]
then
    make
fi
if [ ! -f $IMATRIX ]
then
    echo "compiler generation failed"
    exit 1
fi

if [ ! -d $TESTDIR ]
then
    mkdir $TESTDIR
fi


for file in $TESTFILES
do
    Check $file 2>> $globallog
done

for file in $FAILFILES
do
    CheckFail $file 2>> $globallog
done

if [ $keep -eq 0 ]; then
    rm -rf $TESTDIR
fi
exit $globalerror