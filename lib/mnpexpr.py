# Not-particularly-pretty printing of expressions
# Aaron Mansheim, October 2011

Symbol = str


class Expr(tuple):
    def to_string(self):
        if len(self) == 2 and self[0] == 'quote':
            s = "'"
            if isinstance(self[1], Symbol):
                s += self[1]
            else:
                s += Expr(tuple(self[1])).to_string()
        else:
            s = '('
            is_first = True
            for x in self:
                if is_first:
                    is_first = False
                else:
                    s += ' '

                if isinstance(x, Symbol):
                    s += x
                else:
                    s += Expr(tuple(x)).to_string()
            s += ')'
        return s

    def indent(self):
        s = self.to_string()
        t = ''
        i = 0
        breakpoints = (
            lambda s: s.rfind(')', 0, 70),
            lambda s: s.rfind(' ', 0, 70),
            lambda s: s.find(' '),
            lambda s: s.find(')'),
            lambda s: len(s) - 1,
        )
        while len(s) > 0:
            for b in breakpoints:
                p = b(s) + 1
                if p > 0:
                    break
            i += s[0:p].count('(') - s[0:p].count(')')
            t += s[0:p] + "\n" + (' ' * i)
            s = s[p:]
        return t

    def __str__(self):
        return self.indent()
