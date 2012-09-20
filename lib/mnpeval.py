# -*- encoding: utf8 -*-
# mnpeval.py
#
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
#   take a Lisp-in-Lisp as the reference implementation
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
    def __init__(self, params=Expr(), args=Expr(), outer=None, alist=None):
        if params == None or args == None:
            if alist != None:
                self.update(alist)
        else:
            self.update(zip(params, args))
        self.outer = outer

    def find(self, x):
        if x in self:
            return self
        elif self.outer == None:
            return None
        else:
            return self.outer.find(x)

    def str_helper(self, rec=False):
        if self.outer == None:
            return 'env_top'
        elif self.outer.outer == None:
            return 'env_lib'

        if rec == False:
            s = '('
        else:
            s = ";\n"
        for x in self:
            s += '(' + str(x) + ' ' + str(self[x]) + ')  '
        ## For times when we want to see buckets of env. values.
        #if self.outer != None:
        #    s += self.outer.str_helper(rec=True)
        if rec == False:
            s += ')'
        return s

    def __str__(self):
        return self.str_helper()


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
        't': Symbol('t'),
    })
    return env


def boolean(x):
    return False if x == Expr() else True



env0 = mk_builtins(Env())


def trace_result(depth, exp):
    pass  # print ('│' * depth) + '└  Result:  ' + str(exp) + '.'


def trace_evaluate_or_restate(header, x, env):
    if not boolean(atom_(x)) and (
            car_(x) not in "quote atom car cdr cons eq list append".split() ):
        print header,
        print str(x) + '   IN ENV ' + str(env)  + '.'


def trace_evaluate(depth, x, env):
    trace_evaluate_or_restate( ('│' * (depth-1))
        + ('├' if depth > 0 else '')
        + '┐ Evaluate ', x, env )


def trace_apply(depth, f, x):
    pass  # print ('│' * depth) + '├    Apply   ' + f + ' to ' + str(x) + '.'


def trace_restate(depth, x, env):
    trace_evaluate_or_restate( ('│' * (depth))
        + '╞  Restate:', x, env )


# Used externally to this package.
def eval_adding_alist(x, env=env0, alist=None, depth=0):
    env1 = Env(params=None, args=None, outer=env, alist=alist)
    return eval_(x, env1, depth)


def eval_(x, env=env0, depth=0):
    from sys import exit
    from types import FunctionType

    if trace:
        is_tail_call = False

    while True:  # Be ready to reprocess any proper tail calls.
        if trace:
            if is_tail_call:
                trace_restate(depth, x, env)
            else:
                trace_evaluate(depth, x, env)
                is_tail_call = True

        if x == Expr():
            return Expr()  # Special case () ==> ()

        elif boolean(atom_(x)):
            e = env.find(x)
            if e == None:
                raise ValueError(x)
            else:
                exp = e[x]
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
            if 2 < len(x):
                label = ' (' + str(x[2]) + ')'
            else:
                label = ''
            val = eval_(exp, env, depth + 1)  # near-miss tail call
            print 'Trace ' + str(exp) + label + ":\n " + str(val) + '.'
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

        elif x[0][0] == 'label':
            label = x[0][1]
            value = x[0][2]  # typically (lambda (...) (...))

            env = Env((label,), (x[0],), env)
            x = Expr([value] + list(x[1:]))

        # eval @
        #   x: ((label theLabelName theDef) someArguments)
        #   a: (someEnvironmentPairs)
        # =>
        # eval @
        #   x: (theDef someArguments)
        #   a: (
        #       (theLabelName (label theLabelName theDef))
        #       someEnvironmentPairs
        #      )

        elif x[0][0] == 'lambda':
            params = x[0][1]
            body = x[0][2]
            args = x[1:]
            args = [eval_(xi, env, depth + 1) for xi in args]  # NOT tail calls
            env = Env(params, args, env)
            x = Expr(body)

        # eval @
        #   x: ((lambda params body) args)
        #   a: (someEnvironmentPairs)
        # ==>
        # eval @
        #   x:  body
        #   a: (append (pair params args) someEnvironmentPairs)
        
        elif x[0] == 'quit':
            exit()

        else:
            y = list(x)
            y0 = y.pop(0)
            y0 = eval_(y0, env, depth + 1)  # NOT a tail call
            if isinstance(y0, FunctionType):
                y = [eval_(xi, env, depth + 1) for xi in y]  # NOT tail calls
                y = Expr(y)
                if trace:
                    n = y0.__name__
                    trace_apply(depth, n, y)
                exp = y0(*y)
                if trace:
                    trace_result(depth, exp)
                return exp
            else:
                x = Expr([y0] + list(y))
