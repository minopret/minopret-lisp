#!/usr/bin/python

# A Lisp in the manner of John McCarthy (1960) as described by Paul Graham.
# I doubt this one works very well. See lisp3.py for a better bet.
# This one has a couple of merits though:
# 1. It shows a lot of what I want to accomplish in coding a Lisp.
# 2. It's the origin of "minopret.lisp".
# Created: "minopret" (Aaron Mansheim), 2011-09-06 to 2011-09-11


from types import StringTypes, FunctionType


# This first section was largely automatically parsed and reformatted
# from Lisp. The early evaluation of recursive calls might well fail.
# This should be modified all over the place, probably by currying,
# to ensure maximal shortcut evaluation and preferably the ability
# to use an operation stack and a data stack. I have
# eliminated Python "cond" in favor of Python "if" statements.
# Also I'm toying with the idea of object orientation because
# if we do want to do late binding we could pass the operations
# to the data rather than vice versa.


def evlis_ (m, a):
	result = ()
	if null_ (m) != "t":
		result = cons (eval_ (car (m), a), evlis_ (cdr (m), a))
	return result


def evcon_ (c, a):
	result = ()
	if eval_ (caar_ (c), a) == "t":
		result = eval_ (cadar_ (c), a)
	else:
		result = evcon_ (cdr (c), a)
	return result


def eval_ (e, a):
	result = ()
	if atom (e) == "t":
		result = assoc_ (e, a)
	elif atom (car (e)) == "t":
		if car (e) == "quote":
			result = cadr_ (e)
		elif car (e) == "atom":
			result = atom (eval_ (cadr_ (e), a))
		elif car (e) == "eq":
			result = eq (eval_ (cadr_ (e), a), eval_ (caddr_ (e), a))
		elif car (e) == "car":
			result = car (eval_ (cadr_ (e), a))
		elif car (e) == "cdr":
			result = cdr (eval_ (cadr_ (e), a))
		elif car (e) == "cons":
			result = cons (eval_ (cadr_ (e), a), eval_ (caddr_ (e), a))
		elif car (e) == "cond":
			result = evcon_ (cdr (e), a)
		elif car (e) == "assoc":  # not a builtin, but don't try to look up the lookup function
			result = assoc_ (cdr (e), a)
		elif car (e) == "trace":  # an added special form
			result = eval_ (trace(e, a))
		else:
			result = eval_ (cons (assoc_ (car (e), a), cdr (e)), a)
	elif caar_ (e) == "lambda":
		result = eval_ (caddar_ (e), append_ (pair_ (cadar_ (e), evlis_ (cdr (e), a)), a))
	elif caar_ (e) == "label":
		result = eval_ (cons (caddar_ (e), cdr (e)), cons (list_ (cadar_ (e), car (e)), a))
	return result


def trace(e, a):
	print 'trace (' + e + ";"
	print "\t" + a[0:3] + " ... )"
	return e

def assoc_ (x, y):
	result = ()
	if eq (caar_ (y), x) == "t":
		result = cadar_ (y)
	else:
		result = assoc_ (x, cdr (y))
	return result


def pair_ (x, y):
	result = ()
	if and_ (null_ (x), null_ (y)) != "t" and and_ (not_ (atom (x)), not_ (atom (y))) == "t":
		result = cons (list_ (car (x), car (y)), pair_ (cdr (x), cdr (y)))
	return result


def append_ (x, y):
	result = ()
	if null_ (x) == "t":
		result = y
	else:
		result = cons (car (x), append_ (cdr (x), y))
	return result


def caddar_ (x):
	return car (cdr (cdr (car (x))))


def cadar_ (x):
	return car (cdr (car (x)))


def caar_ (x):
	return car (car (x))


def caddr_ (x):
	return car (cdr (cdr (x)))


def cadr_ (x):
	return car (cdr (x))


def list_ (x, y):
	return cons (x, cons (y, ()))


def not_ (x):
	result = ()
	if x != "t":
		result = "t"
	return result


def and_ (x, y):
	result = ()
	if x == "t" and y == "t":
		result = "t"
	return result


def null_ (x):
	result = ()
	if x == ():
		result = "t"
	return result




def atom (x):
	result = ()
	if x == () or isinstance(x, StringTypes):
		result = "t"
	return result


def car (x):
	return x[0]


def cdr (x):
	return x[1:]


def cons (x, y):
	return (x, ) + y


def eq (x, y):
	result = ()
	if atom (x) == "t" and atom (y) == "t" and x == y:
		result = "t"
	return result


def _definition(env, name, arg_atom_list, expr):
    """
    "_definition" is a Python convenience function internal to the
    interpreter only, used for defining predefined but
    non-builtin functions:
        null, and, not, list, 
    in terms of the builtins:
        quote, atom, eq, cons, car, cdr, & cond
    
    Our language will also enable evaluating (that is, "eval" upon)
    its two auxiliary functions:
        evcon & evlis
    Our language will further enable evaluating two
    functions not defined separately, but rather
    interpreted within the definition of "eval":
        lambda & label
    """
    return cons(
        (name, ("lambda", arg_atom_list, expr)),
        env,
    )
    

def _fixpoint(env, name, arg_atom_list, expr):
    """
    Mechanism for self-referential definitions of
    append, pair, assoc, eval, evcon, & evlis.
    This is the function that Paul Graham calls "defun".
    See definition of "lambda" within definition of "eval"
    in "_load_the_language".
    """
    return cons(
        (
            name,
            ("label", name, ("lambda", arg_atom_list, expr)),
        ),
        env
    )


def _load_the_language():

    env = ()
    
    # These capitalized variables are just visual reminders that
    # these few strings represent the primitives of the language.
    # Also I will use alternate names in this context only
    # in hopes of making this slightly more readable for
    # novices like me.
    #
    # It's crucial to notice where the coming predefines are
    # defined in terms of these primitives, and where they are not,
    # so that we know when they use circular (perhaps mutual)
    # references. Self-references will actually be necessary,
    # but not yet.
    DATA = "quote"
    IS_ATOM = "atom"
    IS_EQ = "eq"
    PUSH = "cons"
    FIRST = "car"
    REST = "cdr"
    MATCH = "cond"
    
    # The following predefines are defined only in terms of
    # primitives.
    
    Null = "null"
    And = "and"
    Not = "not"
    List = "list"
    
    # Again, I'm using alternate names in this context only
    # in hopes of making this slightly more readable for
    # novices like me.
    Second = "cadr"
    Third = "caddr"
    FirstOfFirst = "caar"
    SecondOfFirst = "cadar"
    ThirdOfFirst = "caddar"

    # Null: Test whether an expression equals the empty list.
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
        PUSH,
        "x",
        (PUSH, "y", (DATA, ()), ),
    ))
    
    # A few of the ways we'll use FIRST and REST together
    env = _definition(env, Second, ("x", ), (FIRST, (REST, "x")), )
    env = _definition(env, Third, ("x", ), (FIRST, (REST, (REST, "x"))), )
    env = _definition(env, FirstOfFirst, ("x", ), (FIRST, (FIRST, "x")), )
    env = _definition(env, SecondOfFirst, ("x", ), (
        FIRST,
        (REST, (FIRST, "x")),
    ))
    env = _definition(env, ThirdOfFirst, ("x", ), (
        FIRST,
        (REST, (REST, (FIRST, "x"))),
    ))
    
    
    
    # The following predefines are ultimately
    # defined in terms of the primitives and
    # semi-primitives above, with the added
    # technique of self-reference.

    # append: Given two lists,
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
                PUSH,
                (FIRST, "x"),
                ("append", (REST, "x"), "y"),
            ),
        ),
    ))

    # pair: Given two lists, construct the list
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
                PUSH,
                (List, (FIRST, "x"), (FIRST, "y")),
                ("pair", (REST, "x"), (REST, "y")),
            ),
        ),
    ))

    # assoc: Given an element x and a list y of pairs,
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
    
    
    # "eval" is the crowning achievement. It may freely refer
    # to any of the other predefines.
    #
    # None of the predefines that we have seen so far
    # refer back to "eval".
    #
    # However, as we define "eval", we will break out two
    # special cases of "eval" as separate predefines "evcon"
    # and "evlis" that will refer back to "eval".

    # In a sense, "eval e a" distributes "eval"
    # over the outer operator of e, much as in arithmetic
    # multiplication distributes over addition.
    # "a" is the list that pairs atoms with their bindings,
    # an "association list".
    env = _fixpoint(env, "eval", ("e", "a"), (
        MATCH,
        
        # An atom evaluates to its binding in association list "a".
        (
            (IS_ATOM, "e"),
            ("assoc", "e", "a")
        ),
            
        # An application of a primitive function is
        # generally evaluated using the function itself.
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
                    (IS_EQ, (FIRST, "e"), (DATA, PUSH)),
                    (
                        PUSH,
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
                        (PUSH, ("assoc", (FIRST, "e"), "a"), (REST, "e"), ),
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
# Example, define function "map_f_over_l" and use it
# to map function "atom" over a quoted list of expressions.
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
#       (
#           (
#               label
#               map_f_over_l
#               (lambda (f l) (
#                   cond
#                   ((null l) (quote ()))
#                   ((quote t) (cons (f (car l)) (map_f_over_l (cdr l))))
#               ))
#           )
#           (quote atom)
#           (quote () (u v) w)
#       )
#       a
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
                    PUSH,
                    (ThirdOfFirst, "e"),
                    (REST, "e"),
                ),
                (
                    PUSH,
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
                PUSH,
                ("eval", (FIRST, "m"), "a"),
                ("evlis", (REST, "m"), "a"),
            ),
        ),
    ))
    
    return env


def execute_lisp_program(e):
    env = _load_the_language()
    return eval_(e, env)

