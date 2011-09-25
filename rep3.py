from types import StringTypes
from parse3 import read_exprs
from lisp3 import Symbol, List

def list_to_lisp3(x):
    
    if isinstance(x, StringTypes):
        if x in Symbol.prims:
            return Symbol.prims[x]
        else:
            return Symbol(x)
    elif isinstance(x, tuple) or isinstance(x, list):
        if len(x) <= 0:
            return List.nil
        else:
            return list_to_lisp3(x[0]).cons_(list_to_lisp3(x[1:]))

x = read_exprs(prompt = 'rep3> ')

#print x
for s in x:
    y = list_to_lisp3(s)
    #print y
    #print repr(y)
    print y.eval_(List.nil)


