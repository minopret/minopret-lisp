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
    def atom_(self):
        raise NotImplementedError()
        
    def car_(self):
        raise NotImplementedError()
        
    def cdr_(self):
        raise NotImplementedError()
        
    def cond_(self):
        raise NotImplementedError()
        
    def cons_(self, e):
        return List(car = self, cdr = e)
        
    def eq_(self, e):
        raise NotImplementedError()
        
    def quote_(self):
        return self

    # Other built-ins
    def and_(self, e):
        return List.nil
        
    def list_(self, e):
        self.cons_(e.cons_(List.nil))
        
    def not_(self):
        return List.nil
        
    def null_(self):
        return List.nil


class Symbol(Expr):
    
    def __init__(self, data):
        self.data = str(data)
        
    # Primitives
    def atom_(self):
        return Symbol.s_t
        
    def car_(self):
        raise LispError()
        
    def cdr_(self):
        raise LispError()
        
    def cond_(self):
        raise LispError()
        
    def eq_(self, e):
        if e.atom_() == Symbol.s_t and self.data == e.data:
            return Symbol.s_t
        else:
            return List.nil
            
    def eval_(self, a):
        return self.assoc_(a)
    
    # Other built-ins
    def and_(self, e):
        if self == Symbol.s_t and e == Symbol.s_t:
            return Symbol.s_t
        else:
            return List.nil
            
    def assoc_(self, a):
        if a.caar_().eq_(self) == Symbol.s_t:
            return a.cadar_()
        else:
            self.assoc_(a.cdr_())

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
Symbol.s_lambda = Symbol("lambda")


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
    def atom_(self):
        if self.null_() == Symbol.s_t:
            return Symbol.s_t
        else:
            return List.nil
            
    def car_(self):
        if self._car == None:
            raise LispError()
        else:
            return self._car
            
    def cdr_(self):
        return self._cdr
        
    def cond_(self):
        if self.null_() == Symbol.s_t:
            return List.nil
        elif instanceof(self.car_(), List) and self.caar_() == Symbol.s_t:
            return self.cadr_()
        else:
            return self.cdr_().cond_()
            
    def eq_(self, e):
        if self == List.nil and e == List.nil:
            return Symbol.s_t
        else:
            return List.nil

    # Other built-ins
    def append_(self, e):
        if self == List.nil:
            return e
        else:
            return self.car_().cons_(self.cdr_().append_(e))
            
    def caar_(self):
        return self.car_().car_()
        
    def cadar_(self):
        return self.car_().cdr_().car_()
        
    def caddar_(self):
        return self.car_().cdr_().cdr_().car_()
        
    def caddr_(self):
        return self.cdr_().cdr_().car_()
        
    def cadr_(self):
        return self.cdr_().car_()
        
    def eval_(self, a):
        trace = True
        if trace == True:
            print "eval " + str(self) + " where " + str(a) + "."
        if self.atom_() == Symbol.s_t:
            return self.assoc_(a)
        elif self.car_().atom_():
            if self.car_().eq_(Symbol.s_quote) == Symbol.s_t:
                return self.cadr_()
            elif self.car_().eq_(Symbol.s_atom) == Symbol.s_t:
                return self.cadr_().eval_(a).atom_()
            elif self.car_().eq_(Symbol.s_eq) == Symbol.s_t:
                return self.cadr_().eval_(a).eq_(self.caddr_().eval_(a))
            elif self.car_().eq_(Symbol.s_car) == Symbol.s_t:
                return self.cadr_().eval_(a).car()
            elif self.car_().eq_(Symbol.s_cdr) == Symbol.s_t:
                return self.cadr_().eval_(a).cdr_()
            elif self.car_().eq_(Symbol.s_cons) == Symbol.s_t:
                return self.cadr_().eval_(a).cons_(self.caddr_().eval_(a))
            elif self.car_().eq_(Symbol.s_cond) == Symbol.s_t:
                return self.cdr_().evcon_(a)
            else:
                return self.car_().assoc_(a).cons_(self.cdr_()).eval_(a)
        elif self.caar_().eq_(Symbol.s_label) == Symbol.s_t:
            return self.caddar_().cons_(self.cdr_().eval_(self.cadar_().list_(self.car_()).cons_(a)))
        elif self.caar_().eq_(Symbol.s_lambda) == Symbol.s_t:
            return self.caddar_().eval_(self.cadar_().pair_(self.cdr_().evlis_(a)).append_(a))
            
    def evcon_(self, a):
        if self.caar_().eval_(a) == Symbol.s_t:
            return self.cadar_().eval_(a)
        else:
            return self.cdr_().evcon_(a)
            
    def evlis_(self, a):
        if self.null_() == Symbol.s_t:
            return List.nil
        else:
            return self.car_().eval_(a).cons_(self.cdr_().evlis_(a))
            
    def not_(self):
        if self == List.nil:
            return Symbol.s_t
        else:
            return List.nil
            
    def null_(self):
        return self.eq_(List.nil)
        
    def pair_(self, e):
        if self.null_() == Symbol.s_t and e.null_() == Symbol.s_t:
            return List.nil
        elif self.atom_().not_() == Symbol.s_t and e.atom_().not_() == Symbol.s_t:
            return self.car_().list_(e.car_()).cons_(self.cdr_().pair_(e.cdr_()))
    
    def __str__(self):
        s = '('
        if self.null_() != Symbol.s_t:
            s += str(self.car_())
            c = self.cdr_()
            while c.null_() != Symbol.s_t:
                s += ' ' + str(c.car_())
                c = c.cdr_()
        s += ')'
        return s

# Create distinguished instance of List
List()._mk_nil()

