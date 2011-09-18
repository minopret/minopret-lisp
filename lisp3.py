# Transformation of Paul Graham's Lisp
# by rewriting it in Python, eliminating cond
# and using object orientation mostly to help
# get a valid order of evaluation,
# with classes Symbol(Expr), List(Expr).
# Aaron Mansheim, 2011-09-17


class LispError(Exception):
    pass


# Abstract base class
class Expr():
    # Primitives
    def atom(self):
        raise NotImplementedError()
        
    def car(self):
        raise NotImplementedError()
        
    def cdr(self):
        raise NotImplementedError()
        
    def cond(self):
        raise NotImplementedError()
        
    def cons(self, e):
        return List(car = self, cdr = e)
        
    def eq(self, e):
        raise NotImplementedError()
        
    def quote(self):
        return self

    # Other built-ins
    def and_(self, e):
        return List.nil
        
    def list_(self, e):
        self.cons(e.cons(List.nil))
        
    def not_(self):
        return List.nil
        
    def null(self):
        return List.nil


class Symbol(Expr):
    
    def __init__(self, data):
        self.data = str(data)
        
    # Primitives
    def atom(self):
        return Symbol.s_t
        
    def car(self):
        raise LispError()
        
    def cdr(self):
        raise LispError()
        
    def cond(self):
        raise LispError()
        
    def eq(self, e):
        if e.atom() == Symbol.s_t and self.data == e.data:
            return Symbol.s_t
        else:
            return List.nil
            
    def eval_(self, a):
        return self.assoc(a)
    
    # Other built-ins
    def and_(self, e):
        if self == Symbol.s_t and e == Symbol.s_t:
            return Symbol.s_t
        else:
            return List.nil
            
    def assoc(self, a):
        if a.caar().eq(self) == Symbol.s_t:
            return a.cadar()
        else:
            self.assoc(a.cdr())

    def __str__(self):
        return self.data

# Distinguished instances of Symbol
Symbol.s_t = Symbol("t")
Symbol.s_quote = Symbol("quote")
Symbol.s_atom = Symbol("atom")
Symbol.s_eq = Symbol("eq")
Symbol.s_car = Symbol("car")
Symbol.s_cdr = Symbol("cdr")
Symbol.s_cons = Symbol("cons")
Symbol.s_cond = Symbol("cond")
Symbol.s_label = Symbol("label")
Symbol.s_lambda_ = Symbol("lambda")


class List(Expr):
    nil = None

    def _mk_nil(self):
        nil = self
        nil._car = None
        nil._cdr = self
        List.nil = self
    
    def __init__(self, car = None, cdr = None):
        self._car = car
        self._cdr = cdr
        if cdr == None:
            cdr = List.nil
    
    # Primitives
    def atom(self):
        if self.null() == Symbol.s_t:
            return Symbol.s_t
        else:
            return List.nil
            
    def car(self):
        if self._car == None:
            raise LispError()
        else:
            return self._car
            
    def cdr(self):
        return self._cdr
        
    def cond(self):
        if self.null() == Symbol.s_t:
            return List.nil
        elif instanceof(self.car(), List) and self.caar() == Symbol.s_t:
            return self.cadr()
        else:
            return self.cdr().cond()
            
    def eq(self, e):
        if self == List.nil and e == List.nil:
            return Symbol.s_t
        else:
            return List.nil

    # Other built-ins
    def append(self, e):
        if self == List.nil:
            return e
        else:
            return self.car().cons(self.cdr().append(e))
            
    def caar(self):
        return self.car().car()
        
    def cadar(self):
        return self.car().cdr().car()
        
    def caddar(self):
        return self.car().cdr().cdr().car()
        
    def caddr(self):
        return self.cdr().cdr().car()
        
    def cadr(self):
        return self.cdr().car()
        
    def eval_(self, a):
        trace = True
        if trace == True:
            print "eval " + str(self) + " where " + str(a) + "."
        if self.atom() == Symbol.s_t:
            return self.assoc(a)
        elif self.car().atom():
            if self.car().eq(Symbol.s_quote) == Symbol.s_t:
                return self.cadr()
            elif self.car().eq(Symbol.s_atom) == Symbol.s_t:
                return self.cadr().eval_(a).atom()
            elif self.car().eq(Symbol.s_eq) == Symbol.s_t:
                return self.cadr().eval_(a).eq(self.caddr().eval(a))
            elif self.car().eq(Symbol.s_car) == Symbol.s_t:
                return self.cadr().eval_(a).car()
            elif self.car().eq(Symbol.s_cdr) == Symbol.s_t:
                return self.cadr().eval_(a).cdr()
            elif self.car().eq(Symbol.s_cons) == Symbol.s_t:
                return self.cadr().eval_(a).cons(self.caddr().eval_(a))
            elif self.car().eq(Symbol.s_cond) == Symbol.s_t:
                return self.cdr().evcon(a)
            else:
                return self.car().assoc(a).cons(self.cdr()).eval_(a)
        elif self.caar().eq(Symbol.s_label) == Symbol.s_t:
            return self.caddar().cons(self.cdr().eval_(self.cadar().list(self.car()).cons(a)))
        elif self.caar().eq(Symbol.s_lambda_) == Symbol.s_t:
            return self.caddar().eval_(self.cadar().pair(self.cdr().evlis(a)).append(a))
            
    def evcon(self, a):
        if self.caar().eval(a) == Symbol.s_t:
            return self.cadar().eval(a)
        else:
            return self.cdr().evcon(a)
            
    def evlis(self, a):
        if self.null() == Symbol.s_t:
            return List.nil
        else:
            return self.car().eval(a).cons(self.cdr().evlis(a))
            
    def not_(self):
        if self == List.nil:
            return Symbol.s_t
        else:
            return List.nil
            
    def null(self):
        return self.eq(List.nil)
        
    def pair(self, e):
        if self.null() == Symbol.s_t and e.null() == Symbol.s_t:
            return List.nil
        elif self.atom().not_() == Symbol.s_t and e.atom().not_() == Symbol.s_t:
            return self.car().list(e.car()).cons(self.cdr().pair(e.cdr()))
    
    def __str__(self):
        s = '('
        if self.null() != Symbol.s_t:
            s += str(self.car())
            c = self.cdr()
            while c.null() != Symbol.s_t:
                s += ' ' + str(c.car())
                c = c.cdr()
        s += ')'
        return s

# Create distinguished instance of List
List()._mk_nil()

