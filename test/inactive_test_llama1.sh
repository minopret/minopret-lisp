#!/bin/sh
MNPBASE=`dirname $0`/..
MNPLIB=$MNPBASE/lib
cd $MNPLIB
cat ../test/test_llama1.lisp | python mnplisp.py \
    -M lisp lib llama1 --script $*
