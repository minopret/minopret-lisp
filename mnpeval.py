# mnpeval.py
# A language much like Lisp I
#   <http://www-formal.stanford.edu/jmc/recursive.html>
# as interpreted by Paul Graham,
#   <http://www.paulgraham.com/rootsoflisp.html>
# but implemented in the manner of Peter Norvig's lis.py
#   <http://norvig.com/lispy.html>
# Aaron Mansheim, 2011-09-24

# TODO Consider features to adopt as outlined and compared at hyperpolyglot.org
# TODO Consider the FUNARG problem

# TODO make this an option set by command-line option to mnplisp.py
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
def atom_(x): return Symbol('t') if isa(x, Symbol) or x == () else ()
def car_(x): return x[0]
def cdr_(x): return x[1:]
def cons_(x, y): return tuple([x] + list(y))
def eq_(x, y): return Symbol('t') if x is y else ()
def quote_(x): return x

def mk_builtins(env):
    env.update({
        'atom': atom_, 'car': car_, 'cdr': cdr_,
        # cond  # implemented in eval
        'cons': cons_, 'eq': eq_,
        'quote': quote_,  # fictitious because can't eval its args
    })
    return env

def boolean(x): return True if x is not () else False

env0 = mk_builtins(Env())

def eval_(x, env=env0):
    from sys import exit

    if trace:
        print 'Evaluate ' + str(x) + '.'  # + ' in environment ' + str(env) + '.'

    if isa(x, Symbol) or x == ():  # (atom x)
        e = env.find(x)
        return (e[x] if e != None else x)

    elif x[0] == 'quote':
        exp = x[1]
        return exp

    elif x[0] == 'cond':
        pairs = x[1:]
        if len(pairs) == 0:        # In other implementations is it an error?
            return ()
        else:
            (test, action) = pairs[0]
            if not boolean(eval_(test, env)):
                action = tuple([x[0]]+list(x[2:]))
            return eval_(action, env)

    elif x[0] == 'and':
        return (eval_(x[2], env) if boolean(eval_(x[1], env)) else False)

    elif x[0] == 'label':
        name  = x[1]
        value = x[2]
        env[name] = eval_(value, env)
    # Actually Paul Graham claims 'label' semantics should be:
    #((eq (caar e) 'label)
    #     (eval. (cons (caddar e) (cdr e))
    #                 (cons (list. (cadar e) (car e)) a)))

    elif x[0] == 'lambda':
        params = x[1]
        body   = x[2]
        return lambda *args: eval_(body, Env(params, args, env))
    # Actually Paul Graham claims 'lambda' semantics should be:
    #((eq (caar e) 'lambda)
    #     (eval. (caddar e)
    #                 (append. (pair. (cadar e) (evlis. (cdr e) a))
    #                                      a)))

    elif x[0] == 'exit':
        exit()

    else:
        y = [eval_(xi, env) for xi in x]
        y0 = y.pop(0)
        y = tuple(y)
        if trace:
            print 'Apply ' + str(y0) + ' to ' + str(y) + '.'
        return y0(*y)

