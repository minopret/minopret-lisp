from lisp3 import *

# (cdr (quote (atom lambda)))
print List( Symbol("cdr"), List(
    List( Symbol("quote"), List(
        List( Symbol("atom"), List( Symbol("lambda"), List.nil,
        ),), List.nil,
    ),), List.nil,
),).eval_([])

# Same thing constructed slightly differently.
# car: "cdr"
# cdr: car: list> car: "quote"
#      cdr: (nil) cdr: list> car: list> car: "atom"
#                            cdr: (nil) cdr: car: "lambda"
#                                            cdr: (nil)
print Symbol("cdr").cons_( List(
    Symbol("quote").cons_( List(
        Symbol("atom").cons_( Symbol("lambda").cons_( List.nil,
        ),), List.nil,
    ),), List.nil,
),).eval_([])

# Same thing constructed one more way.
print Symbol("cdr").cons_(
    Symbol("quote").cons_(
        Symbol("atom").cons_(Symbol("lambda").cons_(List.nil)
    ).cons_(List.nil)
).cons_(List.nil).eval_([])

