# This is called "parse3" because it takes about three
# really good tries to get it right.
#
# Aaron Mansheim, 2011-09-22

from re import sub, M
from lisp3 import 


# Parses a sequence of Lisp s-expressions.
# More-or-less follows Peter Norvig's in his lis.py.
def string_to_list(s):
    tokens = tokenize(s)
    
    r = []
    # process one symbol or list at a time
    while 0 < len(tokens):
        (s, q) = wrinkle(tokens)
        r.append(s)
        tokens = tokens[q:]
    return tuple(r)
 
def tokenize(s):
    # Strip off end-of-line comments
    s = sub('\s*;.*', '', s, 0, flags=M)
    
    s = s.replace('(', '( ')
    s = s.replace(')', ' )')
    return s.split()

def wrinkle(tokens):
    """Returns first symbol or sublist and the number of tokens read."""

    # First symbol or sublist.    
    r = None
    
    # Number of tokens read.
    p = 0
    
    # First token.
    t = tokens[0]
    
    if t == '(' or t == "'(":
        p += 1
        r = ()
        
        while p < len(tokens) and tokens[p] != ')':
            (s, q) = wrinkle(tokens[p:])
            p += q
            r += (s, )
            
        if tokens[p] == ')':
            p += 1
            if t == "'(":
                r = ('quote', r)
        else:
            raise SyntaxError('Missing right paren')
    elif t == ')':
    
        # We could optimize this out by demonstrating
        # logically that it's OK to check this only
        # before entering "wrinkle".
        # But let's just leave it here.
        raise SyntaxError('Extra right paren')
    else:
        if t[0] == "'" and len(t) > 1:
            r = ('quote', t[1:])
        else:
            r = t
        p += 1
    return (r, p)

