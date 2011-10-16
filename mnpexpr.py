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

#x = Expr(('cons', Expr(('cons', Expr(('quote', Expr(('a', 'c')), )), Expr(('cons', 'b', Expr(), )), )), Expr(), ))
#print x
#y = Expr(('quote', Expr(('a', 'c')), ))
#print y
#print Expr() == Expr()
#print Expr() is Expr()
#print Expr().__hash__(), Expr().__hash__()
#print id(Expr()), id(Expr())
#print Expr() == ()
#print Expr() is ()
#print Symbol('') == Symbol('')  # True
#print Symbol('') is Symbol('')  # True
#print Symbol('').__hash__(), Symbol('').__hash__()  # 0 0
#print id(Symbol('')), id(Symbol('')), id(''), id('')  # 0 0
#print Symbol('') == ('')  # True
#print Symbol('') is ('')  # True
