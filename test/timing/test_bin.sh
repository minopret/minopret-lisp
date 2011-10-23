#!/bin/sh
MNPBASE=`dirname $0`/../..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test/timing
cat lisp.lisp lib.lisp integer.lisp fib.lisp fact.lisp $MNPTEST/test_bin.lisp | python mnplisp.py --script
