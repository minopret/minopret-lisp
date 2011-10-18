# Read-evaluate-print functionality for a small Lisp.
#
# Aaron Mansheim, September 2011

# TODO Provide a --script option that gets input from stdin with no prompt.
# TODO Provide a trace option that passes through to mnpread.
# TODO Exit when finished evaluating and stdin has closed. (How?)

from sys import stdin
import argparse

parser = argparse.ArgumentParser(description='A simple classic Lisp.')
parser.add_argument('--script', dest='input', action='store_const',
   const='batch', default='interactive',
   help='process a batch of input with no prompt ' \
   + '(default: prompt for interactive input)'

args = parser.parse_args()

def read_eval_print(prompt = None):
    from mnpeval import eval_
    from mnpread import read_exprs  # for interactive prompt
    from mnpread import string_to_expr  # for input from file
    import traceback

    try:
        
        if prompt == None:
            x = string_to_expr(stdin.read())  # input from file
        else:
            x = read_exprs(prompt = prompt)  # interactive prompt

        for xi in x:

            # Macros go here. I'm not enthusiastic about macros.
            # However, they seem the most convenient way by far to implement (load).
            if isinstance(xi, list) and len(xi) > 1 and xi[0] == 'load':
                basename = xi[1]
                # Perhaps check whether the file has been loaded previously.
                # Handle input from the referenced file here.

            yi = eval_(xi)
            if yi != None:
                print yi
    except EOFError:  # Totally doesn't work
        print EOFError
    except StopIteration:
        print StopIteration
    except Exception:
        traceback.print_exc()

def read_eval_print_loop(prompt='mnplisp> '):
    while True:
        read_eval_print(prompt)

if args.input == 'interactive':
    read_eval_print_loop()
else:
    read_eval_print()

