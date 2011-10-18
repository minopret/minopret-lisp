from sys import stdin
from mnpread import string_to_list, list_to_lisp3

txt = stdin.read()

for x in string_to_list(txt):
    print repr(list_to_lisp3(x))
