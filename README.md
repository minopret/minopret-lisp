minopret lisp

Usage: echo "'(Hello World)" | python mnplisp.py 

A Lisp in the manner of John McCarthy (1960).
Created: "minopret" (Aaron Mansheim), 2011-09-06 to 2011-10-02

I hope that mnpeval.py makes clear to anyone who reads it
how an elementary Lisp runtime works. That file is in
essence a stripped down version of Peter Norvig's "lis.py".

Based on this (or any of quite a few other tutorial Lisp
implementations that I have seen out there) I expect that
others and I will be able to produce and enhance a Lisp
within any existing runtime system.

Many Lisp implementations consist of a "read-eval-print loop".
We could always let Python do the "read" and "print" parts and
refrain from looping. The critical piece in mnpeval.py is "eval".
That is enough to occupy a person's attention. Reading is in
mnpread.py. A read-eval-print driver is in mnplisp.py.

I have no illusions that this will break any speed records.
That's totally beside the point. Some time,
I may be able to apply my formal logic skills (even Coq) to
provide certifiably correct optimizations.
 
The functionality of this "eval" closely follows Paul
Graham's representation in "The Roots of Lisp" of John
McCarthy's 1960 paper "Recursive Functions of Symbolic
Expressions and Their Computation by Machine, Part I"
(of which no other part was published). "The Roots of
Lisp" mentions that major inconveniences of 1960 Lisp
are mostly resolved in MIT AI Memo No. 453 "The Art of
the Interpreter" which may be located via the Computer
History Museum:
<http://www.softwarepreservation.org/projects/LISP/scheme_family/>
The McCarthy paper may be located similarly:
<http://www.softwarepreservation.org/projects/LISP/lisp15_family/>

Thanks to William F. Dowling for reminding me,
when I mentioned that I had written the "cond" builtin
such that it consumed and returned its environment,
that "cond" is a pure function. Oh, whoops. I hope
I have already come a long way since then.
