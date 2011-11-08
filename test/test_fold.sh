#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
cat lisp.lisp lib.lisp ../test/test_fold.lisp | python mnplisp.py --script $*
