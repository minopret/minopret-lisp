# Read-evaluate-print functionality for a small Lisp.
#
# Aaron Mansheim, September 2011

# TODO Provide a --script option that gets input from stdin with no prompt.
# TODO Provide a trace option that passes through to parse3.
# TODO Exit when finished evaluating and stdin has closed. (How?)

from sys import stdin

def repl(prompt='repyl1> '):
    from lispy1 import eval_
    # from parse3 import read_exprs  # for interactive prompt
    from parse3 import string_to_tuple  # for input from file
    import traceback
    
    while True:
        try:
            # x = read_exprs(prompt = prompt)  # for interactive prompt
            x = string_to_tuple(stdin.read())  # for input from file
            for xi in x:
                yi = eval_(xi)
                if yi != None:
                    print yi
        except EOFError:
            print EOFError
            break
        except StopIteration:
            print StopIteration
            break
        except Exception:
            traceback.print_exc()

repl()

