#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
MNPTEST=../test
cat lisp.lisp lib.lisp integer.lisp fact.lisp $MNPTEST/test_fact.lisp | python mnplisp.py
