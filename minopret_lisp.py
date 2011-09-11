#!/usr/bin/python

# A Lisp in the manner of John McCarthy (1960).
# Created: "minopret" (Aaron Mansheim), 2011-09-06 to 2011-09-09
#
# I think what I'd like to do is to design a really simple
# virtual machine that supports this Lisp, then port the VM
# to all the languages on coderwall that I have the patience for.
# 
# Follows Paul Graham's representation
# in "The Roots of Lisp" of John McCarthy's 1960 paper
# "Recursive Functions of Symbolic Expressions and Their
# Computation by Machine, Part I" (of which no other part
# was published).

# Thanks to William F. Dowling for reminding me,
# when I mentioned that I had written the "cond" builtin
# such that it returned its environment, that "cond" is a
# pure function. Oh, whoops.

# Many Lisp implementations consist of a
# "read-eval-print loop".
# We're going to let Python do the "read" and "print"
# parts and we're not going to loop.
# There's nothing here but "eval".
# That will be quite enough to occupy our attention.

# I have no illusions that this will break any speed records.
# That's totally beside the point. In fact,
# once I check that this works, I will be able to apply
# my formal logic skills (even Coq) to provide certified
# correct optimizations.


from types import StringTypes, FunctionType


# Primitive functions


def _quote(e):
    return e


def _atom(a):
    if a is () or isinstance(a, StringTypes):
        return "t"
    else:
        return ()


def _eq(a, b):
    if _atom(a) and _atom(b) and a == b:
        return "t"
    else:
        return ()


def _cons(a, b):
    return ((a, ) + b)


def _car(e):
    return e[0]


def _cdr(e):
    return e[1:]


# This takes control of which subexpressions are
# evaluated and which are unevaluated.
# For that reason it gets the environment "a" from
# the built-in "_eval" Python function that is not
# accessible within the Lisp. The "eval" within the
# Lisp is written in Lisp, not Python.
#
# See near the end of this file for the definition of _eval.
def _cond(c):
    result = ()
    for p in c:
        if _car(p) == "t":
            result = _car(_cdr(p))
            break
    return result


# "_definition" is a Python convenience function internal to the
# interpreter only, used for defining predefined but
# non-builtin functions:
#   null, and, not, list, 
# in terms of the builtins:
#   quote, atom, eq, cons, car, cdr, & cond
#
# Our language will also enable evaluating (that is, "eval" upon)
# its two auxiliary functions:
#   evcon & evlis
# Our language will also enable evaluating
# two more functions interpreted within the definition of "eval":
#   lambda & label
def _definition(env, name, arg_atom_list, expr):
    return _cons(
        (name, (("lambda", arg_atom_list), expr)),
        env,
    )
    

# Mechanism for self-referential definitions of
# append, pair, assoc, eval, evcon, & evlis.
# See definition of "lambda" within definition of "eval".
# This is the function that Paul Graham calls "defun".
def _fixpoint(env, name, arg_atom_list, expr):
    return _cons(
        (
            name,
            ("label", name, ("lambda", arg_atom_list, expr)),
        ),
        env
    )


def _load_primitives():
    return (
        ("quote", _quote),
        ("atom",  _atom),
        ("eq",    _eq),
        ("cons",  _cons),
        ("car",   _car),
        ("cdr",   _cdr),
        ("cond",  _cond),
    )


def _load_the_language():

    env = _load_primitives()
    
    # These capitalized variables are just visual reminders that
    # these few strings represent the primitives of the language.
    # It's crucial to notice where the coming predefines are
    # defined in terms of these primitives, and where they are not,
    # so that we know they're not defined by mutual circular
    # references. As we'll see, self-references are actually OK as
    # long as they involve input of decreasing size that always
    # ends at some base case.
    DATA = "quote"
    IS_ATOM = "atom"
    IS_EQ = "eq"
    UNSHIFT = "cons"
    FIRST = "car"
    REST = "cdr"
    MATCH = "cond"
    
    
    # The following predefines are defined only in terms of
    # primitives.
    
    Null = "null"
    And = "and"
    Not = "not"
    List = "list"
    Second = "cadr"
    Third = "caddr"
    FirstOfFirst = "caar"
    SecondOfFirst = "cadar"
    ThirdOfFirst = "caddar"

    # Test whether an expression equals the empty list.
    # In the returned boolean, use the traditional value representing
    # boolean "false", which is also the empty list.
    env = _definition(env, Null, ("x", ), (IS_EQ, "x", (DATA, ())), )

    # Boolean operator "and".
    # Use the traditional value representing
    # boolean "true", which is the atom "t"
    # (Note: NOT a value bound to atom "t",
    # but rather the atom itself).
    env = _definition(env, And, ("x", "y"), (
        MATCH,
        (
            "x",
            (
                MATCH,
                ("y",         (DATA, "t")),
                ((DATA, "t"), (DATA, ())),
            ),
        ),
        ((DATA, "t"), (DATA, ()), ),
    ))

    # Boolean operator "not", accepting any
    # argument except the empty list as boolean "true".
    env = _definition(env, Not, ("x", ), (
        MATCH,
        ("x",         (DATA, ())),
        ((DATA, "t"), (DATA, "t")),
    ))

    # Given two expressions, construct a list
    # that has them as its two elements.
    env = _definition(env, List, ("x", "y"), (
        (UNSHIFT, "x", (UNSHIFT, "y", (DATA, ()), )),
    ))
    
    # A few of the ways to use FIRST and REST together
    env = _definition(env, Second, ("x", ), (FIRST, (REST, "x")), )
    env = _definition(env, Third, ("x", ), (FIRST, (REST, (REST, "x"))), )
    env = _definition(env, FirstOfFirst, ("x", ), (FIRST, (FIRST, "x")), )
    env = _definition(
        env,
        SecondOfFirst,
        ("x", ),
        (FIRST, (REST, (FIRST, "x"))),
    )
    env = _definition(
        env,
        ThirdOfFirst,
        ("x", ),
        (FIRST, (REST, (REST, (FIRST, "x")))),
    )
    
    
    
    # The following predefines are ultimately
    # defined in terms of the semi-primitives above,
    # plus self-reference.

    # Given two lists,
    # construct a single list that contains all of
    # their elements in order.
    env = _fixpoint(env, "append", ("x", "y"), (
        MATCH,
        (
            (Null, "x"),
            "y"
        ),
        (
            (DATA, "t"),
            (
                UNSHIFT,
                (FIRST, "x"),
                ("append", (REST, "x"), "y"),
            ),
        ),
    ))

    # Given two lists, construct the list
    # of pairs of corresponding elements.
    env = _fixpoint(env, "pair", ("x", "y"), (
        MATCH,
        (
            (And, (Null, "x"), (Null, "y")),
            (DATA, ()),
        ),
        (
            (And, (Not, (IS_ATOM, "x")), (Not, (IS_ATOM, "y")), ),
            (
                UNSHIFT,
                (List, (FIRST, "x"), (FIRST, "y")),
                ("pair", (REST, "x"), (REST, "y")),
            ),
        ),
    ))

    # Given an element x and a list y of pairs,
    # return the second element in the pair
    # that has x as its first element.
    env = _fixpoint(env, "assoc", ("x", "y"), (
        MATCH,
        (
            (IS_EQ, (FirstOfFirst, "y"), "x"),
            (SecondOfFirst, "y"),
        ),
        (
            (DATA, "t"),
            ("assoc", "x", (REST, "y")),
        ),
    ))
    
    
    # "eval" is the crowning achievement that may refer
    # to any of the other predefines.
    #
    # None of the predefines that we have seen so far
    # refer back to "eval".
    #
    # However, as we define "eval", we will break out two
    # special cases of "eval" as separate predefines "evcon"
    # and "evlis" that will refer back to "eval".

    # In a sense, "eval e a" distributes "eval"
    # over the outer operator of e.
    # "a" is the list that pairs atoms with their bindings,
    # an "association list".
    env = _fixpoint(env, "eval", ("e", "a"), (
        MATCH,
        
        # An atom evaluates to its binding in association list "a".
        # Are we somehow preventing binding and evaluating the empty list??
        (
            (IS_ATOM, "e"),
            ("assoc", "e", "a")
        ),
            
        # An application of a primitive function is evaluated
        # according to which function it is.
        (
            (IS_ATOM, (FIRST, "e")),
            (
                MATCH,
                (
                    # An application of "quote" evaluates to
                    # the quoted expression.
                    (IS_EQ, (FIRST, "e"), (DATA, DATA)),
                    (Second, "e"),
                ),
                (
                    # An application of "atom" evaluates to
                    # the result of applying "atom" to
                    # the evaluated first argument.
                    (IS_EQ, (FIRST, "e"), (DATA, IS_ATOM)),
                    (IS_ATOM, ("eval", (Second, "e"), "a")),
                ),
                (
                    # An application of "eq" evaluates to
                    # the result of applying "eq" to
                    # the evaluated first and second arguments.
                    (IS_EQ, (FIRST, "e"), (DATA, IS_EQ)),
                    (
                        IS_EQ,
                        ("eval", (Second, "e"), "a"),
                        ("eval", (Third, "e"), "a"),
                    ),
                ),
                (
                    # An application of "car" evaluates to
                    # the result of applying "car" to
                    # the evaluated first argument.
                    (IS_EQ, (FIRST, "e"), (DATA, FIRST)),
                    (FIRST, ("eval", (Second, "e"), "a")),
                ),
                (
                    # An application of "cdr" evaluates to
                    # the result of applying "cdr" to
                    # the evaluated first argument.
                    (IS_EQ, (FIRST, "e"), (DATA, REST)),
                    (REST, ("eval", (Second, "e"), "a")),
                ),
                (
                    # An application of "cons" evaluates to
                    # the result of applying "cons" to
                    # the evaluted first and second arguments.
                    (IS_EQ, (FIRST, "e"), (DATA, UNSHIFT)),
                    (
                        UNSHIFT,
                        ("eval", (Second, "e"), "a"),
                        ("eval", (Third, "e"), "a"),
                    ),
                ),
                (
                    # An application of "cond" evaluates to
                    # the result of applying "evcon" (defined below)
                    # to the arguments.
                    (IS_EQ, (FIRST, "e"), (DATA, MATCH)),
                    ("evcon", (REST, "e"), "a"),
                ),
                (
                    # An application of any another name evaluates to
                    # the result of applying its binding in association list "a"
                    # to the arguments.
                    (DATA, "t"),
                    (
                        "eval",
                        (UNSHIFT, ("assoc", (FIRST, "e"), "a"), (REST, "e"), ),
                        "a",
                    ),
                ),
            ),
        ),  # (IS_ATOM, (FIRST, "e"))
        
        # An application of a list may be evaluated
        # if the list is itself an application of atom "lambda"
        # or atom "label".
        
        # Lambda is the quintessential function that defines any custom
        # function. It does not associate the function with any name.
        # Lambda's first argument is a list of atoms that are
        # the function's formal parameters.
        # When the function is called, these atoms become bound to the
        # evaluated arguments to the call.
        #
        # We are defining lambda in terms of another function "evlis"
        # (defined below) that returns a list after evaluating
        # each of its elements.
        #
        # Example: Let "a" be the current association list.
        # (eval ((lambda params body) args) a)
        # ==> (eval body b)
        # where b is "a" with all of the param-arg pairs prepended.
        
        (
            (IS_EQ, (FirstOfFirst, "e"), (DATA, "lambda")),
            (
                "eval",
                (ThirdOfFirst, "e"),
                (
                    "append",
                    (
                        "pair",
                        (SecondOfFirst, "e"),
                        ("evlis", (REST, "e"), "a"),
                    ),
                    "a",
                ),
            ),
        ),

# One final clause in eval: "label".
#
# This one is a humdinger. It's considered
# historical and obsolete. However, Paul Graham writes
# in his online article that it's actually easier to read
# than a modern equivalent such as the "y combinator"
# that he values so highly.
#
# Let's look at the abstract pattern and then we'll
# look at the practical case. Schematically:
# Let w have first element (label z x) and
# list y of remaining elements.
# That is, evaluating (cons '(label z x) y) gives w.
# Let a be the current association list.
# Then evaluating w gives:
#   ( eval (x y) b )
# where b is a with (z (label z x)) prepended to it.
#
# Not very clear, right? But when we consider what we actually
# want to do with it, it will work nicely. We want to use it
# to define functions that refer to themselves.
#
# Example, function "map_f_over_l" with argument "atom"
# for parameter f and a list of quoted expressions for
# parameter l.
#
# Conceptually we want to apply map_f_over_l like this:
#   (map_f_over_l 'atom '(() (u v) w))
# We expect, as our result, a list of results of applying
# "atom" to each element of the list "(() (u v) w)":
#   (t () t)
# 
# How to do it in actuality, using "label" and "lambda":
#
#   (
#       eval
#       (quote (
#           (
#               label
#               map_f_over_l
#               (lambda (f l) (
#                   cond
#                   ((null l) (quote ()))
#                   ((quote t) (cons (f (car l)) (map_f_over_l (cdr l))))
#               ))
#           )
#           atom
#           ((quote ()) (quote (u v)) (quote w))
#       ))
#       (quote a)
#   )
#
#   ==>
#
#   (
#       eval
#       (
#           (lambda (f l) (
#               cond
#               ((null l) (quote ()))
#               ((quote t) (cons (f (car l)) (map_f_over_l (cdr l))))
#           ))
#           atom
#           ((quote ()) (quote (u v)) (quote w))
#       )
#       b
#   )
#
# where "b" is a modification of "a" that incorporates a binding for "map_f_over_l". Specifically, "b" is given by evaluating this:
#
#   (
#       cons
#       (quote (
#           map_f_over_l
#           (
#               label
#               map_f_over_l
#               (lambda (f l) (
#                   cond
#                   ((null l) (quote ()))
#                   ((quote t) (cons (f (car l)) (map_f_over_l (cdr l))))
#               ))
#           )
#       ))
#       a
#   )
#
# Because this application of "label" in the association list
# is exactly the same that we started with, evaluating map_f_over_l
# using this binding will have the same desirable effect as we
# have already seen.

        (
            (IS_EQ, (FirstOfFirst, "e"), (DATA, "label")),
            (
                "eval",
                (
                    UNSHIFT,
                    (ThirdOfFirst, "e"),
                    (REST, "e"),
                ),
                (
                    UNSHIFT,
                    (List, (SecondOfFirst, "e"), (FIRST, "e"), ),
                    "a",
                ),
            ),
        ),
    ))  # eval

    # "evcon": Evaluate a cond whose arguments are the elements of the
    # list "c". The elements of "c" are condition-result pairs.
    env = _fixpoint(env, "evcon", ("c", "a"), (
        MATCH,
        (
            ("eval", (FirstOfFirst, "c"), "a"),
            ("eval", (SecondOfFirst, "c"), "a"),
        ),
        (
            (DATA, "t"),
            ("evcon", (REST, "c"), "a"),
        ),
    ))

    # "evlis": Eval each of the elements of a list.
    # In other words, map "eval" over the list.
    env = _fixpoint(env, "evlis", ("m", "a"), (
        MATCH,
        (
            (Null, "m"),
            (DATA, ()),
        ),
        (
            (DATA, "t"),
            (
                UNSHIFT,
                ("eval", (FIRST, "m"), "a"),
                ("evlis", (REST, "m"), "a"),
            ),
        ),
    ))
    
    return env

