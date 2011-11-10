#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
cat ../test/test_label.lisp | python mnplisp.py --script $*
