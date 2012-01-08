#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_label.lisp | $MNPTEST/../bin/mnplisp --script $*
