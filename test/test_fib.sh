#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test
cat lisp.lisp lib.lisp integer.lisp fib.lisp $MNPTEST/test_fib.lisp | python mnplisp.py
