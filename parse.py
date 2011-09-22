from re import sub, M
from sys import stdin, stdout


class LispParser():
    def __init__(self):
        self.s = '()'
        self.stack = None
            
    def _add_quoted_token(self, tok):
        self._begin_list(quoted = False)
        self._add_token("quote")
        self._add_token(tok[1:])
        self._end_list()

    def _add_token(self, tok):
        self.stack[-1].append(tok)

    def _begin_list(self, quoted = False):
        new_list = []
        if quoted == True:
            self.stack[-1].append(new_list)
            self.stack.append(new_list)
            self._add_token("quote")
            new_list = []
        self.stack[-1].append(new_list)
        self.stack.append(new_list)
        
    def _end_list(self):
        stack = self.stack
        if len(stack) > 1 and len(stack[-2]) > 0 and stack[-2][0] == "quote":
            stack.pop()
        stack.pop()

    def set_sexpr(self, s):
        self.s = s
        self.stack = None

    def get_lists(self):
        if self.stack == None:
            mnplisp = self.s
            mnplisp = sub('^\s*;.*', '', mnplisp, 0, flags=M)  # drop comment lines
            mnplisp = sub('\(', '( ', mnplisp)  # insert space after open
            mnplisp = sub('\)', ' )', mnplisp)  # insert space before close
            
            # tokenize on whitespace (acknowledgment: Peter Norvig in 'lis.py')
            tokens = mnplisp.split()

            expr = []
            self.stack = [expr,]
            
            for t in tokens:
                if t == '(':
                    self._begin_list()
                elif t == ')':
                    self._end_list()
                elif t == "'(":
                    self._begin_list(quoted = True)
                elif t[0:1] == "'":
                    self._add_quoted_token(t)
                else:
                    self._add_token(t)
            
        return self.stack[0]


    
    syms = set("evcon evlis atom eq cond car cdr cons assoc quote append null list pair and not cadr caddr caar cadar caddar eval lambda label".split())



    def for_python(self):

        def pprint(sexpr):

            def patom(s):
                s = s.replace('.', '')
                if s in self.syms:
                    return s
                else:
                    return "'" + s + "'"
                    
            if isinstance(sexpr, list):
                if len(sexpr) > 0:
                    if len(sexpr[0]) > 1:
                        s = pprint(sexpr[0])
                        s += '('
                        s += pprint(sexpr[1])
                        for e in sexpr[2:]:
                            s += ","
                            s += pprint(e)
                        s += ')'
                    else:
                        s = '['
                        s += sexpr[0]
                        for e in sexpr[1:]:
                            s += ","
                            s += pprint(e)
                        s += ']'
                else:
                    s = '()'
            else:
                s = patom(sexpr)
            return s

        for sexpr in self.get_lists():
            print pprint(sexpr)
            print



    #def id_str(d):
    #    s = ''
    #    while d > 0:
    #        (q, r) = divmod(d, 256)
    #        s = chr(r) + s
    #        d = q
    #    return s


    def for_gallina(self):  # that is, Coq

        def gprint(sexpr):

            def atom_num(s):
                d = 0
                for c in s:
                    d *= 256
                    d += ord(c)
                return d

            def atom_id(s):
                s = s.replace('.', '')
                if s in self.syms:
                    return "sym_" + s
                else:
                    #return '[' + s + ']'
                    d = atom_num(s)
                    h = list(hex(d).upper())[2:]
                    if h[-1] == 'L':
                        h = h[0:-1]
                    h.reverse()
                    hn = h[-1]
                    h = h[0:-1]
                    nh = len(h)
                    h = ' (d'.join(h)
                    h += ' h' + hn.upper() + (')' * nh)
                    #print h
                    s = "symbol (d"
                    s += h
                    return '(' + s + ')'
                    #return s
                    
            if isinstance(sexpr, list):
                if len(sexpr) == 0:
                    s = 'nil '
                else:
                    s = ''
                    ns = len(sexpr)
                    while len(sexpr) > 1:
                        s += '(cons '
                        s += gprint(sexpr[0])
                        s += " "
                        sexpr = sexpr[1:]
                    s += gprint(sexpr[0])
                    s += ")" * (ns - 1)
            else:
                s = atom_id(sexpr),

        for sexpr in self.get_lists():
            print self.gprint(sexpr)
            print



    def for_lisp3(self):

        prims = set("t atom eq cond car cdr cons quote lambda label".split())

        def lprint(e):

            if isinstance(e, list):
                if len(e) > 0:
                    is_car_not_atom = isinstance(e[0], list) and len(e[0]) > 0
                    s = ''
                    if is_car_not_atom:
                        s += '('
                    s += lprint(e[0])
                    if is_car_not_atom:
                        s += ')'
                    s += '.cons_(' + lprint(e[1:]) + ')'
                else:
                    s = 'List.nil'
            else:
                s = 'Symbol'
                if e in prims:
                    s += '.s_' + e
                else:
                    s += "('" + e + "')"
            return s

        for sexpr in self.get_lists():
            print lprint(sexpr)
            print



    def for_debug(self):
        for sexpr in self.get_lists():
            print sexpr
            print
            



#f = open("lisp3.lisp", "r")
print "Press Ctrl-D when finished> ",
stdout.flush()
mnplisp = stdin.read()
#f.close()

p = LispParser()
p.set_sexpr(mnplisp)
p.for_lisp3()

