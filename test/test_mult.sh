#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_mult.lisp | $MNPTEST/../bin/mnplisp -M lisp lib integer --script $*
