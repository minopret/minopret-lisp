# This is called "parse3" because it takes me
# about three really good tries to get it right.
#
# Aaron Mansheim, 2011-09-22


# Parses a sequence of Lisp s-expressions.
# More-or-less follows Peter Norvig's in his lis.py.
def string_to_tuple(s):
    tokens = tokenize(s)
    
    r = []
    # process one symbol or list at a time
    while 0 < len(tokens):
        (s, q) = wrinkle(tokens)
        r.append(s)
        tokens = tokens[q:]
    return tuple(r)
 
def tokenize(s):
    from re import sub, M
    
    # Strip off end-of-line comments
    s = sub('\s*;.*', '', s, 0, flags=M)
    
    s = s.replace('(', '( ')
    s = s.replace(')', ' )')
    return tuple(s.split())

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
        r = []
        
        while p < len(tokens) and tokens[p] != ')':
            (s, q) = wrinkle(tokens[p:])
            p += q
            r += [s, ]
            
        if p < len(tokens):  # and therefore tokens[p] == ')'
            p += 1
            if t == "'(":
                r = ('quote', tuple(r))
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
    if isinstance(r, list):
        r = tuple(r)
    return (r, p)

def read_exprs(prompt='Press Ctrl-D on a new line to exit> '):
    prog = raw_input(prompt)
    return string_to_tuple(prog)

