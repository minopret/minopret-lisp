minopret lisp

A Lisp in the manner of John McCarthy (1960).
Created: "minopret" (Aaron Mansheim), 2011-09-06 to 2011-09-11

I hope this makes clear to anyone who reads it
how an elementary Lisp runtime works. Based on this
(or any of what I suppose must be many other tutorial
Lisp implementations) I expect that others and I will
be able to produce and enhance a Lisp within any existing
runtime system.

Many Lisp implementations consist of a
"read-eval-print loop".
We're going to let Python do the "read" and "print"
parts and we're not going to loop.
There's nothing here but "eval".
That will be quite enough to occupy our attention.

I have no illusions that this will break any speed records.
That's totally beside the point. Once I check that this works,
I may be able to apply my formal logic skills (even Coq) to
provide certifiably correct optimizations.
 
This closely follows Paul Graham's representation
in "The Roots of Lisp" of John McCarthy's 1960 paper
"Recursive Functions of Symbolic Expressions and Their
Computation by Machine, Part I" (of which no other part
was published). "The Roots of Lisp" mentions that
major inconveniences of 1960 Lisp are mostly resolved
in MIT AI Memo No. 453 "The Art of the Interpreter"
which may be located via the Computer History Museum:
<http://www.softwarepreservation.org/projects/LISP/scheme_family/>
The McCarthy paper may be located similarly:
<http://www.softwarepreservation.org/projects/LISP/lisp15_family/>

Thanks to William F. Dowling for reminding me,
when I mentioned that I had written the "cond" builtin
such that it consumed and returned its environment,
that "cond" is a pure function. Oh, whoops.