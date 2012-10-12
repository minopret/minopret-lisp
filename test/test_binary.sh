#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_binary.lisp | $MNPTEST/../bin/mnplisp \
    -M lisp lib binary ../test/binary --script $*
