# -*- encoding: utf8 -*-
# mnpeval.py # A language much like Lisp I
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


from mnpexpr import Expr, Symbol


trace = False


def set_trace(is_trace=False):
    global trace
    trace = is_trace


# If I understand correctly, this is the Funarg device.
# The Funarg device implements lexical scope and closures.
class Env(dict):
    def __init__(self, params=Expr(), args=Expr(), outer=None):
        self.update(zip(params, args))
        self.outer = outer

    def find(self, x):
        if x == Expr():
            return None
        elif x in self:
            return self
        elif self.outer != None:
            return self.outer.find(x)
        else:
            return None

    def __str__(self):
        s = '('
        for x in self:
            s += '(' + str(x) + ' ' + str(self[x]) + ') '
        s += ')'
        return s


# defined with "def" rather than lambda
# for sake of better Python traces
def atom_(x):
    return Symbol('t') if isinstance(x, Symbol) or x == Expr() else Expr()


def car_(x):
    return x[0]


def cdr_(x):
    return Expr(x[1:])


def cons_(x, y):
    return Expr([x] + list(y))


def eq_(x, y):
    return Symbol('t') if x == y else Expr()


def mk_builtins(env):
    env.update({
        'atom': atom_,
        'car': car_,
        'cdr': cdr_,
        # cond      # special form implemented in eval_
        'cons': cons_,
        'eq': eq_,
        # quote     # special form implemented in eval_
    })
    return env


def boolean(x):
    return True if x != Expr() else False


class Procedure(object):
    def __init__(self, params, body, env):
        self.params = params
        self.body = body
        self.env = env
        self.name = ''
    def __call__(self, *args):
        return eval_(self.body, Env(self.params, args, self.env))
    def __str__(self):
        if len(self.name) > 0:
            return '<procedure ' + self.name + '>'
        else:
            return 'lambda[' + str(self.params) + '; ' + str(self.body) + \
                '; ' + str(self.env) + ']'


env0 = mk_builtins(Env())


def trace_result(depth, exp):
    print ('│' * depth) + '└  Result:  ' + str(exp) + '.'


def trace_evaluate(depth):
    print ('│' * (depth-1)) + ('├' if depth > 0 else '') + '┐ Evaluate ',


def trace_apply(depth, f, x):
    print ('│' * depth) + '├    Apply   ' + f + ' to ' + str(x) + '.'


def trace_restate(depth):
    print ('│' * depth) + '╞  Restate:',


def eval_(x, env=env0, depth=0):
    from sys import exit
    from types import FunctionType

    if trace:
        is_tail_call = False
        trace_evaluate(depth)

    while True:  # Be ready to reprocess any proper tail calls.
        if trace:
            if is_tail_call:
                trace_restate(depth)
            is_tail_call = True
            print str(x) + '.'

        if isinstance(x, Symbol) or x == Expr():  # (atom x)
            e = env.find(x)
            exp = (e[x] if e != None else x)
            if trace:
                trace_result(depth, exp)
            return exp

        elif x[0] == 'quote':
            exp = x[1]
            if trace:
                trace_result(depth, exp)
            return exp  # No tail call needed.

        elif x[0] == 'trace':
            exp = x[1]
            val = eval_(exp, env, depth + 1)  # near-miss tail call
            print 'Trace ' + str(exp) + ': ' + str(val) + '.'
            return val

        elif x[0] == 'cond':
            pairs = x[1:]
            if len(pairs) == 0:     # In other implementations is it an error?
                if trace:
                    trace_result(depth, '()')
                return Expr()
            else:
                (test, action) = pairs[0]
                if not boolean(eval_(test, env, depth + 1)):  # NOT NEARLY a tail call
                    action = Expr([x[0]] + list(x[2:]))
                x = action  # proper tail call

        elif x[0] == 'label':
            name = x[1]
            value = x[2]
            evalue = eval_(value, env, depth + 1)  # near-miss tail call
            env[name] = evalue
            if isinstance(evalue, Procedure):
                evalue.name = name
            return evalue

        # Actually Paul Graham writes 'label' in Common Lisp as:
        #((eq (caar e) 'label)
        #     (eval. (cons (caddar e) (cdr e))
        #            (cons (list. (cadar e) (car e)) a)))
        #
        # Example of use (??)
        # ( (label f ( (lambda (x) (cond ((null x) ()) (t (cdr x)))) ))  '(a b) )
        # # which in Python might be: # elif x[0][0] == 'label':
        #     label_expr = x[0]
        #     args = list(x[1:])  # convert from Expr
        #     label_name = x[0][1]
        #     label_value = x[0][2]
        #     env1 = Env((label_name), (label_expr), env)
        #     return eval_(Expr([(label_value)] + args), env1)
        #
        # but could instead destructively update the existing environment:
        # elif x[0][0] == 'label':
        #     label_name = x[0][1]
        #     label_value = x[0][2]
        #     label_expr = x[0]
        #     args = list(x[1:])  # convert from Expr
        #     env[label_name] = label_expr
        #     return eval_(Expr([(label_value)] + args), env)

        elif x[0] == 'lambda':
            params = x[1]
            body = x[2]
            exp = Procedure(params, body, env)
            if trace:
                trace_result(depth, exp)
            return exp

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
            y = [eval_(xi, env, depth + 1) for xi in x]  # NOT tail calls
            y0 = y.pop(0)
            y = Expr(y)
            if trace:
                if isinstance(y0, FunctionType):
                    n = y0.__name__
                else:
                    n = str(y0)
                trace_apply(depth, n, y)
            if isinstance(y0, Procedure):
                x = y0.body
                env = Env(y0.params, y, y0.env)  # proper tail call
            else:
                exp = y0(*y)  # apply a Python function from env
                if trace:
                    trace_result(depth, exp)
                return exp
