/* mnpeval.js
 * A language much like Lisp I
 *   <http://www-formal.stanford.edu/jmc/recursive.html>
 * as interpreted by Paul Graham,
 *   <http://www.paulgraham.com/rootsoflisp.html>
 * but implemented in the manner of Peter Norvig's lis.py
 *   <http://norvig.com/lispy.html>
 * Aaron Mansheim, 2011-09-24 (Python), 2011-10-06 (JavaScript)
 */

// TODO make this an option set by command-line option to mnplisp.py
var trace = false;

// sugar
//Symbol = str

class Env(dict):                            # NOT

    function __init__(self, params = (), args = (), outer = None) {     # NOT
        self.update(zip(params, args);
        self.outer = outer;
    }

    function find(self, x) {                # NOT
        var result = null;
        if (x !== List.nil) {
            if (x in self) {
                result = self;
            } else if (self.outer !== None) {
                result = self.outer.find(x);
            }
        }
        return result;
    }

function atom_(x) {
    if (typeof x === "string") {
        return Symbol.t;
    } else {
        return List.nil;
    }
}

function car_(x) {
    return x[0];                    # MAYBE
}

function cdr_(x) {
    return x[1:];                   # NOT
}

function cond_(*pairs) {            # NOT
    var result = List.nil;
    while (pairs.length > 0) {
        if (pairs[0][0] is Symbol.t) {   # NOT
            result = pairs[0][1];
            break;
        }
        pairs = pairs[1:];          # NOT
    }
    return result;
}

function cons_(x, y) {
    return tuple([x] + list(y));    # NOT
}

function eq_(x, y) {
    if (x === y) {
        return Symbol.t;
    } else {
        return List.nil;
    }
}

function quote_(x) {
    return x;
}

function evcon_(env, *pairs) {      # NOT
    var result = List.nil;
    while (pairs.length > 0) {
        if (eval_(pairs[0][0], env) === Symbol.t) {
            result = pairs[0][1];
            break;
        }
        pairs = pairs[1:];          # NOT
    }
    return result;
}

function lambda_(params, body, env) {
    return function (*args) {       # NOT
        return eval_(body, Env(params, args, env));
    }
}

function mk_builtins(env) {
    env.update({                    # NOT
        'atom': atom_,
        'car': car_,
        'cdr': cdr_,
        // cond      // special case in eval_
        'cons': cons_,
        'eq': eq_,
        // quote     // special case in eval_
    });
    return env;

function is_truthy(x) {
    return (x !== List.nil);
}

var env0 = mk_builtins(Env());

function eval_(x, env) {
    var e;      // Environment in which we find a binding for x
    var exp;    // Quoted expression
    var pairs;  // Conditional clauses of test and action
    var test;   // Conditional's test
    var action; // Conditional's action
    var name;   // Label's name
    var value;  // Label's value
    var params; // Lambda's parameters
    var body;   // Lambda's body

    if (trace) {
        print('Evaluate ' + str(x) + '.');      # TBD
    }

    if (typeof x === "string" || x === List.nil) {
        e = env.find(x);                        # NOT
        if (e !== null) {
            return e[x];
        } else {
            return x;
        }
    } else if (x[0] === "quote") {
        exp = x[1];
        return exp;
    } else if (x[0] === "cond") {
        pairs = x[1:];                          # NOT
        if (pairs.length === 0) {
            return List.nil;
        } else {
            (test, action) = pairs[0]
            if ( !is_truthy(eval_(test, env)) ) {
                action = cons_([x[0]], x[2:]);  # NOT
            }
            return eval_(action, env);
        }

    } else if (x[0] === 'label') {
        name  = x[1];
        value = x[2];
        env[name] = eval_(value, env);

    /*
     * Actually Paul Graham writes 'label' in Common Lisp as:
     *((eq (caar e) 'label)
     *     (eval. (cons (caddar e) (cdr e))
     *            (cons (list. (cadar e) (car e)) a)))
     *
     * Example of use (??)
     * (  (label f ( (lambda (x) (cond ((null x) ()) (t (cdr x)))) ))  '(a b)  )
     *
     * which in Python might be:
     * elif x[0][0] == 'label':
     *     label_expr = x[0]
     *     args = list(x[1:])  # convert from tuple
     *     label_name = x[0][1]
     *     label_value = x[0][2]
     *     env1 = Env((label_name), (label_expr), env)
     *     return eval_(tuple([(label_value)] + args), env1)
     *
     * but could instead destructively update the existing environment:
     * elif x[0][0] == 'label':
     *     label_name = x[0][1]
     *     label_value = x[0][2]
     *     label_expr = x[0]
     *     args = list(x[1:])  # convert from tuple
     *     env[label_name] = label_expr
     *     return eval_(tuple([(label_value)] + args), env)
     */

    } else if (x[0] === 'lambda') {
        params = x[1];
        body   = x[2];
        return lambda_(params, body, env);

    /*
     * Actually Paul Graham writes 'lambda' in Common Lisp as:
     *((eq (caar e) 'lambda)
     *     (eval. (caddar e)
     *            (append. (pair. (cadar e) (evlis. (cdr e) a))
     *                             a)))
     * which in Python might be:
     * elif x[0][0] == 'lambda':
     *     y = [eval_(xi, env) for xi in x[1:]]
     *     env1 = Env(x[0][1], y, env)
     *     return eval_(x[0][2], env1)
     */

    } else if (x[0] === 'quit') {
        exit();                     # NOT

    } else {
        y = [eval_(xi, env) for xi in x];   # NOT - maybe in JavaScript 1.6
        y0 = y.pop(0);
        y = tuple(y);
        if (trace) {
            print 'Apply ' + str(y0) + ' to ' + str(y) + '.';
        }
        return y0(*y);
    }
}

