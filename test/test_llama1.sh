#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_llama1.lisp | $MNPTEST/../bin/mnplisp \
    -M lisp lib llama1 --script $*
