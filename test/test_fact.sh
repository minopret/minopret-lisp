#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_fact.lisp | $MNPTEST/../bin/mnplisp -M lisp lib integer fact --script $*
