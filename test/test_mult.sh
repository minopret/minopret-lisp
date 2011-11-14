#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test
cat $MNPTEST/test_mult.lisp | python mnplisp.py -M lisp lib integer --script $*
