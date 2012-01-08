#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_fold.lisp | $MNPTEST/../bin/mnplisp -M lisp lib --script $*
