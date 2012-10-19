minopret lisp


    usage: mnplisp.py [-h] [--script] [--trace]

    A simple classic Lisp.

    optional arguments:
      -h, --help  show this help message and exit
      --script    process a batch of input with no prompt (default: prompt for
                  interactive input)
      --trace     list every function as it is evaluated or applied


Created: "minopret" (Aaron Mansheim), 2011-09-06 to 2012-10-18

The Lisp programming language interpreter that I have written for fun, "minopret-lisp" <https://github.com/minopret/minopret-lisp>, now has the following features.

Whether it looks like it or not, I'm trying to make it easy to understand. My strategy is to keep it simple and self-contained.

* Fundamental operations are exactly the seven classic ones: atom, car, cdr, cond, cons, eq, quote.

* The brief libraries that I have written and provided in this language include:
    * the "eval" function that treats an expression as a subroutine, runs it, performs the classic fundamental operations on its behalf, and provides the result value of the subroutine,
    * a variety of classic functions that are mostly those needed for "eval",
    * handling of modern character data (for those who know: quoted-printable, base64, hexadecimal, and binary) in the form of lists of characters, and
    * addition and multiplication without using the computer's own arithmetic operations. This last part is very unconventional to have in a programming language library, but it shows how to program these operations that we all learned to do in school. (I did a couple of unusual things with arithmetic and character data too, but I feel that an explanation of that part would only be confusing here.)

* The interpreter is written in Python, an easy-to-read language. Its parts are:
    1. handle command line options and print how to use them (104 commented lines of code),
    2. read a program (90 commented lines of code),
    3. "eval" (291 commented lines of code): run a program and perform its fundamental operations. The "eval" part provides two classic ways to create a value that is a subroutine: self-referencing (the unfashionable early Lisp "label" construct) or not self-referencing ("lambda"). It is more-or-less recreated in the "eval" function in the library that is mentioned above.
    4. print a result (55 commented lines of code).

Answers to unasked questions:
* Under what license is it provided?
    * Copyright by the author, all rights reserved. You are probably surprised and perhaps disappointed. The reason is that I the author have been as yet too lazy to consider which license would be helpful to the goals of the project, whatever they are.
* Does it work? Does it do what it's intended to do?
    * Yes. I mean, there are a lot of careful tests in the "test" directory and they all pass. Oh well, the "llama" and "llama1" tests fail, but they are experimental and even their names are a joke. If you're wondering what the joke could be, oh well, it's what a fan of Monty Python might think of if a Lisp programmer kept saying "lambda".
* Is it innovative?
    * No.
* Is it interesting?
    * Lisp programming languages are very interesting, in my arrogant opinion. I also think that this interpreter is interesting, but probably only to the degree that it may be (or at least become) easier for some of us to understand than similar alternative programs are.
* Is it compatible with my favorite Lisp programming language?
    * No. However, it should be easy to revise the "eval" library function to make it work in your favorite Lisp programming language. Then you can use that to run any program that is written in this language.
* Is it fast?
    * Hardly. However, it enables its programs that use "tail calls" to run much faster and smaller than they otherwise would. So you should look up "tail calls" in Wikipedia. When using tail calls, reasonable programs will probably finish, eventually. 
* Are programs in this language useful?
    * So far, no. I hope to develop some special programs in the language as it currently exists that can be useful. I also hope to develop the language to the point that most programs in the language can be useful.
* Is its behavior described completely somewhere?
    * No, but the intention of the design is that its formal description can be small and simple.
* Is its behavior predictable?
    * The text of programs doesn't say in what order operations will be performed. However, the interpreter proceeds with operations in an entirely predictable sequence, albeit that the sequence is not explained outside the source code.

I hope that lib/mnpeval.py (the "eval" part of the Python-coded
interpreter) makes clear to anyone who reads it
how an elementary Lisp runtime works. That file is in
essence a stripped down version of Peter Norvig's "lis.py".

Based on this (or any of quite a few other tutorial Lisp
implementations that I have seen out there) I expect that
others and I will be able to produce and enhance a Lisp
within any existing runtime system.

Many Lisp implementations consist of a "read-eval-print loop".
In the critical piece, mnpeval.py, we simply rely on other Python
code to do the "read" and "print" parts and
we refrain from looping. What is left is "eval".
That is enough to occupy a person's attention. The "read" part is in
mnpread.py. The "print" part is in mnpexpr.py.
The "read-eval-print loop" driver is in mnplisp.py.

The shell scripts in "test" provide examples using
the additional basic integer and string processing that I
have written in Lisp in the files in "lib".

I have no illusions that this will break any speed records.
That's totally beside the point. Little by little,
I may be able to apply my formal logic skills, particularly
the Coq proof assistant, to provide certifiably correct
optimizations. See directory "logic" for some of that.
 
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
Thanks to James Snavely for conversations and 
encouragement. Thanks to my Facebook friends and the
Philly Lambda functional programming user's group
for listening.
