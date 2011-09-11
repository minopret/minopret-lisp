#!/usr/bin/python

# Created: "minopret" (Aaron Mansheim), 2011-09-06 to 2011-09-09
#
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
    if a is () or isinstance(a, StringTypes) or isinstance(a, FunctionType):
        return "t"
    else:
        return ()


def _eq(a, b):
    if (a == b):
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
def _cond(c, a):
    result = ()
    for p in c:
        (e0, a0) = _eval(_car(p), a)
        if e0 is not ():
            result = _car(_cdr(p))
            break
    return result


# "_defun" is a Python convenience function internal to the
# interpreter only, used for defining predefined but
# non-builtin functions:
#   null, and, not, append, list, pair, assoc, eval, evcon, & evlis
# in terms of the builtins:
#   quote, atom, eq, cons, car, cdr, & cond
#
# Our language will not enable evaluating (that is, eval)
# its two auxiliary functions:
#   evcon & evlis
# On the other hand, our language will enable evaluating
# two more functions via the definition of "eval":
#   lambda & label
#
# In addition, our language will enable evaluating
# (that is, transforming by "eval") and applying
# additional atoms that programs give bindings
# by means of the non-primitive functions "lambda" and "label".
# I think it's possible to define "defun" on top of "label"
# and "lambda", but initially I don't care to try it.
def _defun(env, name, arg_atom_list, expr):
    return _cons(
        (name, (("lambda", arg_atom_list), expr)),
        env,
    )


def _load_the_builtins():
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

    env = _load_the_builtins()
    
    # These capitalized variables are just visual reminders that
    # these few strings represent the primitives of the language.
    # It's a really, really important distinction between
    # these strings and the rest.
    QUOTE = "quote"
    ATOM = "atom"
    EQ = "eq"
    CONS = "cons"
    CAR = "car"
    CDR = "cdr"
    COND = "cond"

    # Test whether an expression equals the empty list.
    # In the returned boolean, use the traditional value representing
    # boolean "false", which is also the empty list.
    env = _defun(env, "null", ("x"), (EQ, "x", (QUOTE, ())), )

    # Boolean operator "and".
    # Use the traditional value representing
    # boolean "true", which is the atom "t"
    # (Note: NOT a value bound to atom "t",
    # but rather the atom itself).
    env = _defun(env, "and", ("x", "y"), (
        COND,
        (
            "x",
            (
                COND,
                ("y",          (QUOTE, "t")),
                ((QUOTE, "t"), (QUOTE, ())),
            ),
        ),
        ((QUOTE, "t"), (QUOTE, ()), ),
    ))

    # Boolean operator "not", accepting any
    # argument except the empty list as boolean "true".
    env = _defun(env, "not", ("x"), (
        COND,
        ("x",          (QUOTE, ())),
        ((QUOTE, "t"), (QUOTE, "t")),
    ))

    # Given two lists,
    # construct a single list that contains all of
    # their elements in order.
    env = _defun(env, "append", ("x", "y"), (
        COND,
        (
            ("null", "x"),
            "y"
        ),
        (
            (QUOTE, "t"),
            (
                CONS,
                (CAR, "x"),
                ("append", (CDR, "x"), "y"),
            ),
        ),
    ))

    # Given two expressions, construct a list
    # that has them as its two elements.
    env = _defun(env, "list", ("x", "y"), (
        (CONS, "x", (CONS, "y", (QUOTE, ()), )),
    ))

    # Given two lists, construct the list
    # of pairs of corresponding elements.
    env = _defun(env, "pair", ("x", "y"), (
        COND,
        (
            ("and", ("null", "x"), ("null", "y")),
            (QUOTE, ()),
        ),
        (
            ("and", ("not", (ATOM, "x")), ("not", (ATOM, "y")), ),
            (
                CONS,
                ("list", (CAR, "x"), (CAR, "y")),
                ("pair", (CDR, "x"), (CDR, "y")),
            ),
        ),
    ))

    # Given an element x and a list y of pairs,
    # return the second element in the pair
    # that has x as its first element.
    env = _defun(env, "assoc", ("x", "y"), (
        COND,
        (
            (EQ, (CAR, (CAR, "y")), "x", ),
            (CAR, (CDR, (CAR, "y")), ),
        ),
        (
            (QUOTE, "t"),
            ("assoc", "x", (CDR, "y")),
        ),
    ))

    # "eval e a" sort of distributes "eval"
    # over the outer operator of e.
    # "a" is the list that pairs atoms with their bindings,
    # an "association list".
    env = _defun(env, "eval", ("e", "a"), (
        COND,
        
        # An atom evaluates to its binding in association list "a".
        (
            (ATOM, "e"),
            ("assoc", "e", "a")
        ),
            
        # An application of a primitive function is evaluated
        # according to which function it is.
        (
            (ATOM, (CAR, "e")),
            (
                COND,
                (
                    # An application of "quote" evaluates to
                    # the quoted expression.
                    (EQ, (CAR, "e"), (QUOTE, QUOTE)),
                    (CAR, (CDR, "e")),
                ),
                (
                    # An application of "atom" evaluates to
                    # the result of applying "atom" to
                    # the evaluated first argument.
                    (EQ, (CAR, "e"), (QUOTE, ATOM)),
                    (ATOM, ("eval", (CAR, (CDR, "e")), "a")),
                ),
                (
                    # An application of "eq" evaluates to
                    # the result of applying "eq" to
                    # the evaluted first and second arguments.
                    (EQ, (CAR, "e"), (QUOTE, EQ)),
                    (
                        EQ,
                        ("eval", (CAR, (CDR, "e")), "a"),
                        ("eval", (CAR, (CDR, (CDR, "e"))), "a"),
                    ),
                ),
                (
                    # An application of "car" evaluates to
                    # the result of applying "car" to
                    # the evaluated first argument.
                    (EQ, (CAR, "e"), (QUOTE, CAR)),
                    (CAR, ("eval", (CAR, (CDR, "e")), "a")),
                ),
                (
                    # An application of "cdr" evaluates to
                    # the result of applying "cdr" to
                    # the evaluated first argument.
                    (EQ, (CAR, "e"), (QUOTE, CDR)),
                    (CDR, ("eval", (CAR, (CDR, "e")), "a")),
                ),
                (
                    # An application of "cons" evaluates to
                    # the result of applying "cons" to
                    # the evaluted first and second arguments.
                    (EQ, (CAR, "e"), (QUOTE, CONS)),
                    (
                        CONS,
                        ("eval", (CAR, (CDR, "e")), "a"),
                        ("eval", (CAR, (CDR, (CDR, "e"))), "a"),
                    ),
                ),
                (
                    # An application of "cond" evaluates to
                    # the result of applying "evcon" (defined below)
                    # to the arguments.
                    (EQ, (CAR, "e"), (QUOTE, COND)),
                    ("evcon", (CDR, "e"), "a"),
                ),
                (
                    # An application of any another name evaluates to
                    # the result of applying its binding in association list "a"
                    # to the arguments.
                    (QUOTE, "t"),
                    (
                        "eval",
                        (CONS, ("assoc", (CAR, "e"), "a"), (CDR, "e"), ),
                        "a",
                    ),
                ),
            ),
        ),  # (ATOM, (CAR, "e"))
        
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
            (EQ, (CAR, (CAR, "e")), (QUOTE, "lambda")),
            (
                "eval",
                (CAR, (CDR, (CDR, (CAR, "e")))),
                (
                    "append",
                    (
                        "pair",
                        (CAR, (CDR, (CAR, "e"))),
                        ("evlis", (CDR, "e"), "a"),
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
        # That is, w is (cons '(label z x) 'y), evaluated.
        # Let a be the current association list.
        # Then w evaluates to:
        #   ( eval (x y) b )
        # where b is a with (z (label z x)) prepended to it.
        #
        # Not very clear, right? But when we consider what we actually
        # want to do with it, it will work nicely. We want to use it
        # to define functions that refer to themselves.
        #
        # Example, function "map_f_over_l" with argument "atom"
        # for parameter f and a list of quoted expressions for
        # parameter l:
        #
        #   (eval ((label map_f_over_l (lambda (f l) (
        #       cond
        #       ((null l) (quote ()))
        #       ((quote t) (
        #           cons
        #           (f (car l))
        #           (map_f_over_l (cdr l))
        #       ))
        #   ))) atom ((quote atom) (quote ()) (quote (car cdr))) ) a)
        #   ==> (eval ((lambda (f l) (
        #           cond
        #           ((null l) (quote ()))
        #           ((quote t) (
        #               cons
        #               (f (car l))
        #               (map_f_over_l (cdr l))
        #           ))
        #       )) atom ((quote atom) (quote ()) (quote (car cdr))) ) b)
        # where b is a with the following binding of map_f_over_l
        # prepended to it:
        #
        # (map_f_over_l (label map_f_over_l (lambda (f l) (
        #     cond
        #     ((null l) (quote ()))
        #     ((quote t) (
        #         cons
        #         (f (car l))
        #         (map_f_over_l (cdr l))
        #     ))
        # ))))
        #
        # Because this application of "label" in the association list
        # is the same one that we started with, evaluating map_f_over_l
        # using this binding will have the same desirable effect as we
        # have already seen.

        (
            (EQ, (CAR, (CAR, "e")), (QUOTE, "label")),
            (
                "eval",
                (
                    CONS,
                    (CAR, (CDR, (CDR, (CAR, "e")))),
                    (CDR, "e"),
                ),
                (
                    CONS,
                    ("list", (CAR, (CDR, (CAR, "e"))), (CAR, "e"), ),
                    "a",
                ),
            ),
        ),
    ))  # eval

    # "evcon": Evaluate a cond whose arguments are the elements of the
    # list "c". The elements of "c" are condition-result pairs.
    env = _defun(env, "evcon", ("c", "a"), (
        COND,
        (
            ("eval", (CAR, (CAR, "c")), "a"),
            ("eval", (CAR, (CDR, (CAR, "c"))), "a"),
        ),
        (
            (QUOTE, "t"),
            ("evcon", (CDR, "c"), "a"),
        ),
    ))

    # "evlis": Eval each of the elements of a list.
    # In other words, map "eval" over the list.
    env = _defun(env, "evlis", ("m", "a"), (
        COND,
        (
            ("null", "m"),
            (QUOTE, ()),
        ),
        (
            (QUOTE, "t"),
            (CONS, ("eval", (CAR, "m"), "a"), ("evlis", (CDR, "m"), "a"), ),
        ),
    ))
    
    return env


# For the most part evaluation will in fact delegate
# to the _defun(env, "eval", ...) above.
# However, this inaccessible built-in is needed
# in order to get the ball rolling in Python.
# In effect, this is our Lisp virtual machine, or "kernel".
# It implements features of Lisp that are implicit:
#   the environment (particularly as used by "cond"),
#   interpreting "procedure calls" aka "apply",
#   applying builtin functions.
def _eval(e, a):

    result = ()
    if _atom(e):
        result = e
    else:
        car = _car(e)
        
        # Does that atom stand for a builtin?
        # This is incorrect because the eval ends up being circular!
        #
        #if not isinstance(car, FunctionType) and _atom(car) == "t":
        #    car0 = _eval((_global__assoc_in_lisp, car), a)
        #    if isinstance(car0, FunctionType):
        #        car = car0
        
        # TODO
        #if ... 'lambda' or 'label'
        #    ...I could hold off on this
        # I suppose it is not customary to evaluate the name
        # or argument of a label or the parameters of a lambda.
        #el
        if isinstance(car, FunctionType):
            # 1-place functions
            if car in (_atom, _car, _cdr, _quote):
                result = car(_car(_cdr(e)))
            # 2-place functions
            elif car in (_eq, _cons):
                result = car(_car(_cdr(e)), _car(_cdr(_cdr(e))))
            # Function of one list, which also needs to take
            # the current environment as an argument.
            elif car is _cond:
                result = _cond(_car(_cdr(e)), a)
        elif _atom(car) == "t":
            # This is very questionable
            (result, a) = _eval((_assoc, car), a)
        else:
            # This is very questionable
        
            # error: Can't apply an expression unless it
            # is a lambda list (lambda (...)), is a label list (label ,
            # evaluates to one of those, evaluates to a built-in,
            # or evaluates to an atom.
            raise TypeError
    return (result, a)
