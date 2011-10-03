# Read-evaluate-print functionality for a small Lisp.
#
# Aaron Mansheim, September 2011

# TODO Provide a --script option that gets input from stdin with no prompt.
# TODO Provide a trace option that passes through to mnpread.
# TODO Exit when finished evaluating and stdin has closed. (How?)

from sys import stdin

def rep():
    from mnpeval import eval_
    # from mnpread import read_exprs  # for interactive prompt
    from mnpread import string_to_tuple  # for input from file
    import traceback

    try:
        # x = read_exprs(prompt = prompt)  # for interactive prompt
        x = string_to_tuple(stdin.read())  # for input from file
        for xi in x:
            yi = eval_(xi)
            if yi != None:
                print yi
    except EOFError:
        print EOFError
    except StopIteration:
        print StopIteration
    except Exception:
        traceback.print_exc()

def repl(prompt='mnplisp> '):
    
    while True:
        rep()

#repl()

rep()

