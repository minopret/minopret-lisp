from parse3 import *
from sys import stdin, stdout

print 'Press Ctrl-D on a new line to exit> ',
stdout.flush()
prog = stdin.read()

x = string_to_list(prog)
#print x
for s in x:
    y = list_to_lisp3(s)
    #print y
    #print repr(y)
    print y.eval_(List.nil)


