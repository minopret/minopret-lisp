#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test
cat $MNPTEST/test_binary.lisp | python mnplisp.py \
    -M lisp lib integer binary ../test/binary --script $*
