# Read-evaluate-print functionality for a small Lisp.
#
# Aaron Mansheim, September 2011


def read_exprs(prompt=None):
    from sys import stdin
    from mnpread import read_next_exprs, string_to_expr

    if prompt == None:
        x = string_to_expr(stdin.read())  # input from file
    else:
        x = read_next_exprs(prompt=prompt)  # interactive prompt
    return x


def read_eval_print(prompt=None):
    from sys import exit
    from types import FunctionType
    from mnpeval import eval_
    import traceback

    try:
        x = read_exprs(prompt=prompt)

        for xi in x:

            # Macros go here. I'm not enthusiastic about macros.
            # However, they seem the most convenient way by far to
            # implement (load).
            #if isinstance(xi, list) and len(xi) > 1 and xi[0] == 'load':
            #    basename = xi[1]
            #    # Perhaps check whether the file has been loaded previously.
            #    # Handle input from the referenced file here.

            yi = eval_(xi)
            if yi != None and str(yi) != '' \
                    and not isinstance(yi, FunctionType):
                print yi
    except EOFError:
        exit(0)
    except StopIteration:
        print StopIteration
    except Exception:
        traceback.print_exc()


def read_eval_print_loop(prompt='mnplisp> '):
    while True:
        read_eval_print(prompt)


def main():
    from argparse import ArgumentParser
    from mnpeval import set_trace

    arg_parser = ArgumentParser(description='A simple classic Lisp.')
    arg_parser.add_argument(
        '--script',
        dest='input',
        action='store_const',
        const='batch',
        default='interactive',
        help='process a batch of input with no prompt ' \
            + '(default: prompt for interactive input)',
    )

    arg_parser.add_argument(
        '--trace',
        dest='trace',
        action='store_const',
        const='tron',
        default='troff',
        help='list every function as it is evaluated or applied',
    )

    args = arg_parser.parse_args()
    if args.trace == 'tron':
        set_trace(True)

    if args.input == 'interactive':
        read_eval_print_loop()
    else:
        read_eval_print()


if __name__ == "__main__":
    main()
