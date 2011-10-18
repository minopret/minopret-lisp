#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test
cat lisp.lisp lib.lisp integer.lisp $MNPTEST/test_mult.lisp | python mnplisp.py --script
