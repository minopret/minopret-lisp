# Not-particularly-pretty printing of expressions
# Aaron Mansheim, October 2011

Symbol = str

class Expr(tuple):

    def __str__(self):
        if len(self) == 2 and self[0] == 'quote':
            s = "'"
            s += str(self[1])
        else:
            s = '('
            is_first = True
            for x in self:
                if is_first:
                    is_first = False
                else:
                    s += ' '
                s += str(x)
            s += ')'
        return s

