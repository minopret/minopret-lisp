# Not-particularly-pretty printing of expressions
# Aaron Mansheim, October 2011

Symbol = str


class Expr(tuple):
    def str_helper(self):
        if len(self) == 2 and self[0] == 'quote':
            s = "'"
            if isinstance(self[1], Symbol):
                s += self[1]
            else:
                s += Expr(tuple(self[1])).str_helper()
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
                    s += Expr(tuple(x)).str_helper()
            s += ')'
        return s

    def __str__(self):
        return self.str_helper()
