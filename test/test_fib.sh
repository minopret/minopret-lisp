#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_fib.lisp | $MNPTEST/../bin/mnplisp -M lisp lib integer fib --script $*
