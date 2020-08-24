# Transform an mnplisp file into an equivalent Python file.
# Hmm, escaping stuff is going to take some work.
# Aaron Mansheim, October 2011


def atomname_to_pyname(s):
    from re import match

    # Thanks http://www.evanjones.ca/python-utf8.html
    u = unicode( s, "utf-8" )

    p = ''
    for c in u:
        if c.match(r'[a-zA-Z0-9]'):
            p += c
        else:
            
    

identifier ::=  (letter|"_") (letter | digit | "_")*
letter     ::=  lowercase | uppercase
lowercase  ::=  "a"..."z"
uppercase  ::=  "A"..."Z"
digit      ::=  "0"..."9"
but not:    and       del       from      not       while
            as        elif      global    or        with
            assert    else      if        pass      yield
            break     except    import    print
            class     exec      in        raise
            continue  finally   is        return
            def       for       lambda    try
_* : not importable via from <module> import *
__*__ : "subject to breakage without warning"
__* : in a class definition, generally gets renamed by the Python compiler



def main():
    from sys import stdin
    from mnpread import string_to_expr

    x = string_to_expr(stdin.read())

    for xi in x:
        compile_expr(xi)


def compile_expr(x):
    if isinstance(x, Symbol) or x == Expr():  # (atom x)
        e = env.find(x)
        return (e[x] if e != None else x)

    elif x[0] == 'quote':
        exp = x[1]
        return exp

    elif x[0] == 'trace':
        exp = x[1]
        val = eval_(exp, env)  # near-miss tail call
        print('Trace ' + str(exp) + ': ' + str(val) + '.')
        return val

    elif x[0] == 'cond':
        pairs = x[1:]
        if len(pairs) == 0:        # In other implementations is it an error?
            return Expr()
        else:
            (test, action) = pairs[0]
            if not boolean(eval_(test, env)):  # NOT NEARLY a tail call
                action = Expr([x[0]] + list(x[2:]))
            return eval_(action, env)  # tail call

    elif x[0] == 'label':
        name = x[1]
        value = x[2]
        env[name] = eval_(value, env)  # tail call

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
        y = [eval_(xi, env) for xi in x]  # NOT tail calls
        y0 = y.pop(0)  # EXCEPT y0 is a near-miss tail call
        y = Expr(y)
        if trace:
            print('Apply ' + str(y0) + ' to ' + str(y) + '.')
        return y0(*y)
           
 

if __name__ == "__main__":
    main()
