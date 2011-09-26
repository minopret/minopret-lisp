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
            break
        except Exception:
            traceback.print_exc()

repl()

