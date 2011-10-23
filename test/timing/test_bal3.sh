#!/bin/sh
MNPBASE=`dirname $0`/../..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test/timing
cat lisp.lisp lib.lisp integer.lisp fib.lisp fact.lisp $MNPTEST/test_bal3.lisp | python mnplisp.py --script
