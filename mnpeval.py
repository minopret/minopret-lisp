# mnpeval.py
# A language much like Lisp I
#   <http://www-formal.stanford.edu/jmc/recursive.html>
# as interpreted by Paul Graham,
#   <http://www.paulgraham.com/rootsoflisp.html>
# but implemented in the manner of Peter Norvig's lis.py
#   <http://norvig.com/lispy.html>
# Aaron Mansheim, 2011-09-24

# I have conflicting ideas for this:
#
# - I want it just to be short and clear.
#
# - On the other hand, I have a few design
#   decisions in mind and I want to keep
#   track of them here in these long comments.
#
# - I'd like it to be stripped down small
#   so that I can practically translate it to
#   other languages such as JavaScript.
#   In particular I can implement special
#   forms "quote" and "cond" entirely in "eval".
#
# - I can even implement a number of the Lisp
#   functions (but not "assoc"!) as lambdas
#   in a Lisp "assoc" environment, and then
#   run all programs within Lisp "eval".
#
# - On the other hand it might be nice if the Python
#   code is very parallel to Lisp-in-Lisp as for example
#   Paul Graham's, so that perhaps I could
#   take a Lisp-in-Lisp as the reference implmentation
#   and translate or generate that to Python,
#   JavaScript, etc. - particularly when I want
#   to change the implementation!
#
# - It's nice to abstract out the Python representation
#   of symbols, cons cells, and lists by implementing
#   "eval" in terms of the functions cons_ etc.
#
# - It's also nice to make three classes Expr, Symbol(Expr),
#   and List(Expr) that organize the primitives by
#   what sort of data they act upon. "Show me your
#   tables [meaning, data structures] and I won't
#   need your algorithms - they'll be obvious" --
#   Fred Brooks, if memory serves
#
# - On the other hand I mostly find it more readable just to
#   code to the "obvious" Python representation throughout.

# TODO make this an option set by command-line option to mnplisp.py
trace = False

# sugar
Symbol = str

# If I understand correctly, this is the Funarg device.
# The Funarg device implements lexical scope and closures.
class Env(dict):
    def __init__(self, params = (), args = (), outer = None):
        self.update(zip(params, args))
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
# for sake of better Python traces
def atom_(x): return Symbol('t') if isinstance(x, Symbol) or x == () else ()
def car_(x): return x[0]
def cdr_(x): return x[1:]

# Not in use. Do not want??
def cond_(*pairs):
    while len(pairs) > 0:
        if pairs[0][0] is Symbol('t'):
            return pairs[0][1]
        pairs = pairs[1:]
    return ()

def cons_(x, y): return tuple([x] + list(y))
def eq_(x, y): return Symbol('t') if x is y else ()

# Not in use. Do not want??
def quote_(x): return x

# Not in use. Do not want??
def evcon_(env, *pairs):
    while len(pairs) > 0:
        if eval_(pairs[0][0], env) is Symbol('t'):
            return pairs[0][1]
        pairs = pairs[1:]
    return ()

def lambda_(params, body, env):
    return lambda *args: eval_(body, Env(params, args, env))

def mk_builtins(env):
    env.update({
        'atom': atom_,
        'car': car_,
        'cdr': cdr_,
        # cond      # special case in eval_
        'cons': cons_,
        'eq': eq_,
        # quote     # special case in eval_
    })
    return env

def boolean(x): return True if x is not () else False

env0 = mk_builtins(Env())



def eval_(x, env=env0):
    from sys import exit

    if trace:
        print 'Evaluate ' + str(x) + '.'  # + ' in environment ' + str(env) + '.'

    if isinstance(x, Symbol) or x == ():  # (atom x)
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

    elif x[0] == 'label':
        name  = x[1]
        value = x[2]
        env[name] = eval_(value, env)

    # Actually Paul Graham writes 'label' in Common Lisp as:
    #((eq (caar e) 'label)
    #     (eval. (cons (caddar e) (cdr e))
    #            (cons (list. (cadar e) (car e)) a)))
    #
    # Example of use (??)
    # (  (label f ( (lambda (x) (cond ((null x) ()) (t (cdr x)))) ))  '(a b)  )
    #
    # which in Python might be:
    # elif x[0][0] == 'label':
    #     label_expr = x[0]
    #     args = list(x[1:])  # convert from tuple
    #     label_name = x[0][1]
    #     label_value = x[0][2]
    #     env1 = Env((label_name), (label_expr), env)
    #     return eval_(tuple([(label_value)] + args), env1)
    #
    # but could instead destructively update the existing environment:
    # elif x[0][0] == 'label':
    #     label_name = x[0][1]
    #     label_value = x[0][2]
    #     label_expr = x[0]
    #     args = list(x[1:])  # convert from tuple
    #     env[label_name] = label_expr
    #     return eval_(tuple([(label_value)] + args), env)

    elif x[0] == 'lambda':
        params = x[1]
        body   = x[2]
        return lambda_(params, body, env)

    # Actually Paul Graham writes 'lambda' in Common Lisp as:
    #((eq (caar e) 'lambda)
    #     (eval. (caddar e)
    #            (append. (pair. (cadar e) (evlis. (cdr e) a))
    #                             a)))
    # which in Python might be:
    # elif x[0][0] == 'lambda':
    #     y = [eval_(xi, env) for xi in x[1:]]
    #     env1 = Env(x[0][1], y, env)
    #     return eval_(x[0][2], env1)

    elif x[0] == 'quit':
        exit()

    else:
        y = [eval_(xi, env) for xi in x]
        y0 = y.pop(0)
        y = tuple(y)
        if trace:
            print 'Apply ' + str(y0) + ' to ' + str(y) + '.'
        return y0(*y)

