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


def read_eval_print(env_pairs_string, prompt=None):
    from sys import exit
    from types import FunctionType
    from mnpeval import eval_, eval_adding_alist
    from mnpread import string_to_expr
    import traceback

    try:
        a = None
        if len(env_pairs_string) > 0:
            a = string_to_expr(env_pairs_string)[0]
        x = read_exprs(prompt=prompt)

        for xi in x:
            if a != None:
                yi = eval_adding_alist(xi, alist=a)
            else:
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


def read_eval_print_loop(env_pairs_string, prompt='mnplisp> '):
    while True:
        read_eval_print(env_pairs_string, prompt)


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

    arg_parser.add_argument(
        '-M',
        dest='modules',
        #action='append',
        default=[],
        nargs='*',
        help='load space-separated library modules before running',
    )

    args = arg_parser.parse_args()
    if args.trace == 'tron':
        set_trace(True)

    env_pairs_string = ''
    for m in args.modules:
        f = open(str(m) + '.lisp')
        env_pairs_string += f.read()
        f.close()
    if len(env_pairs_string) > 0:
        env_pairs_string = "(\n" + env_pairs_string + "\n)\n"

    if args.input == 'interactive':
        read_eval_print_loop(env_pairs_string)
    else:
        read_eval_print(env_pairs_string)


if __name__ == "__main__":
    main()
