#!/bin/sh
MNPBASE=`dirname $0`/../..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test/timing
cat $MNPTEST/test_bal3.lisp | $MNPTEST/../../bin/mnplisp -M lisp lib integer fib fact --script $*
