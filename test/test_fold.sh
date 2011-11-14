#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
cat ../test/test_fold.lisp | python mnplisp.py -M lisp lib --script $*
