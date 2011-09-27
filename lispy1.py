# lispy1.py
# A language much like Lisp I (McCarthy, Russell, 1960)
# implemented in the manner of Peter Norvig's lis.py
# Aaron Mansheim, 2011-09-24

# TODO make this a command-line option
trace = False

# sugar
Symbol = str
isa = isinstance

class Env(dict):
    def __init__(self, parms = (), args = (), outer = None):
        self.update(zip(parms, args))
        self.outer = outer
    def find(self, x):
        if x == ():
            return None
        elif x in self:
            return self
        elif self.outer != None:
            return self.outer.find(x)
        else:
            return None

# defined with "def" rather than lambda
# for sake of better debug messages
def atom_(x): return isa(x, Symbol) or x == ()
def car_(x): return x[0]
def cdr_(x): return x[1:]
def cons_(x, y): return tuple([x] + list(y))
def eq_(x, y): return x is y
def quote_(x): return x

def and_(x, y): return (y if x else False)
def append_(x, y): return tuple(list(x) + list(y))
def assoc_(x, y): return dict(y)[x]
def caar_(x): return x[0][0]
def cadar_(x): return x[0][1]
def caddar_(x): return x[0][2]
def caddr_(x): return x[2]
def cadr_(x): return x[1]
def list_(*x): return tuple(x)
def not_(x): return not x
def null_(x): return x == ()
def pair_(x, y): return zip(x, y)

def mk_builtins(env):
    import operator as op
    env.update({
        'atom': atom_, 'car': car_, 'cdr': cdr_,
        # cond  # implemented in eval
        'cons': cons_, 'eq': eq_,
        'quote': quote_,  # fictitious because can't eval its args
        
        'and': and_,  # fictitious because can't always eval second arg
        'append': append_,
        'assoc': assoc_,
        'caar': caar_, 'cadar': cadar_, 'caddar': caddar_,
        'caddr': caddr_, 'cadr': cadr_,
        # evcon  # not needed  # evlis  # not needed
        'list': list_, 'not': not_, 'null': null_, 'pair': pair_,
    })
    return env

env0 = mk_builtins(Env())

def eval_(x, env=env0):
    from sys import exit

    if trace:
        print 'Evaluate ' + str(x) + '.' # + ' in environment ' + str(env) + '.'
    if env0['atom'](x):
        e = env.find(x)
        return (e[x] if e != None else x)
    elif x[0] == 'quote':          # (quote exp)
        (_, exp) = x
        return exp
    elif x[0] == 'cond':           # (cond (test action)* )
        pairs = x[1:]
        if len(pairs) == 0:        # In other implementations is it an error?
            return ()
        else:
            (test, action) = pairs[0]
            if not eval_(test, env):
                action = tuple([x[0]]+list(x[2:]))
            return eval_(action, env)
    elif x[0] == 'and':
        return (eval_(x[2], env) if eval_(x[1], env) else False)
    elif x[0] == 'label':          # (label name value)
        (_, name, value) = x
        env[name] = eval_(value, env)
    elif x[0] == 'lambda':         # (lambda (var*) exp)
        (_, parms, body) = x
        return lambda *args: eval_(body, Env(parms, args, env))
    elif x[0] == 'exit':
        exit()
    else:
        y = [eval_(xi, env) for xi in x]
        y0 = y.pop(0)
        y = tuple(y)
        if trace:
            print 'Apply ' + str(y0) + ' to ' + str(y) + '.'
        return y0(*y)

