#!/bin/sh
MNPTEST=`dirname $0`
cat $MNPTEST/test_llama.lisp | $MNPTEST/../bin/mnplisp \
    -M lisp lib llama ../test/llama --script $*
