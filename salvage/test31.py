from lisp3 import *

x =  Symbol.s_quote.cons_( Symbol.s_t.cons_(List.nil.cons_(List.nil)).cons_(List.nil) )
x = x.eval_(List.nil)
print x  # expect (t ())

# was ((lambda (x y) (cons x y)) (quote (t ())))
# now ((lambda (x y) (cons x y)) (list (quote t) (quote ())))
x = Symbol.s_lambda.cons_(   Symbol("x").cons_( Symbol("y").cons_(List.nil) ).cons_(Symbol.s_cons.cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil))).cons_(List.nil)))
x = x.cons_( Symbol("list").cons_( Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil)) ).cons_(List.nil) )
print x
x = x.eval_(List.nil)
print x  # sort of hoping for (t)
