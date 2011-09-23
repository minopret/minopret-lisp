from parse3 import *

x = string_to_list("(cdr '(atom lambda))")
print x
y = list_to_lisp3(x)
print y
print repr(y)

