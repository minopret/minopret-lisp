#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test
cat lisp.lisp lib.lisp integer.lisp binary.lisp $MNPTEST/test_binary.lisp | python mnplisp.py --script
