#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_integer.lisp | $MNPTEST/../bin/mnplisp -M lisp lib integer --script $*
