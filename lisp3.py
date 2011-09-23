# This is called "lisp3" because it takes me
# about three really good tries to get it
# right.
#
# It's a transformation of Paul Graham's Lisp
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
        
    def eval_(self, e):
        raise NotImplementedError()


class Symbol(Expr):

    prims = None
    builtins = None
    
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
    
    # Non-primitive built-ins
    def and_(self, e):
        if self == Symbol.s_t and e == Symbol.s_t:
            return Symbol.s_t
        else:
            return List.nil
            
    def assoc_(self, a):
        if a.null_() == Symbol.s_t:  # discovered fix
            return List.nil
        elif a.caar_().eq_(self) == Symbol.s_t:
            return a.cadar_()
        else:
            self.assoc_(a.cdr_())

    def eval_(self, a):
        return self.assoc_(a + Symbol.builtins)

    def __str__(self):
        return self.data

    def __repr__(self):
        return 'Symbol("' + self.data + '")'


# Distinguished instances of Symbol
Symbol.s_atom = Symbol('atom')
Symbol.s_car = Symbol('car')
Symbol.s_cdr = Symbol('cdr')
Symbol.s_cond = Symbol('cond')
Symbol.s_cons = Symbol('cons')
Symbol.s_eq = Symbol('eq')
Symbol.s_label = Symbol('label')
Symbol.s_lambda = Symbol('lambda')
Symbol.s_quote = Symbol('quote')
Symbol.s_t = Symbol('t')

Symbol.prims = {
    'atom': Symbol.s_atom,
    'car': Symbol.s_car,
    'cdr': Symbol.s_cdr,
    'cond': Symbol.s_cond,
    'cons': Symbol.s_cons,
    'eq': Symbol.s_eq,
    'label': Symbol.s_label,
    'lambda': Symbol.s_lambda,
    'quote': Symbol.s_quote,
    't': Symbol.s_t,
}

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
        
    def assoc_(self, a):
        return List.nil  # discovered fix

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
        elif self.car_().atom_() == Symbol.s_t:
            if self.car_().eq_(Symbol.s_quote) == Symbol.s_t:
                return self.cadr_()
            elif self.car_().eq_(Symbol.s_atom) == Symbol.s_t:
                return self.cadr_().eval_(a).atom_()
            elif self.car_().eq_(Symbol.s_eq) == Symbol.s_t:
                return self.cadr_().eval_(a).eq_(self.caddr_().eval_(a))
            elif self.car_().eq_(Symbol.s_car) == Symbol.s_t:
                return self.cadr_().eval_(a).car_()
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
    
    def __repr__(self):
        s = ''
        if self.null_() == Symbol.s_t:
            s = 'List.nil'
        else:
            s += repr(self.car_())
            s += '.cons_(' + repr(self.cdr_()) + ')'
        return s

# Create distinguished instance of List
List()._mk_nil()

# Create Lisp association list of Lisp definitions of builtins.
# The following definitions were translated automatically
# from Lisp s-expression code.
Symbol.builtins = (

# evlis
Symbol("evlis").cons_(
    Symbol.s_lambda.cons_(Symbol("m").cons_(Symbol("a").cons_(List.nil)).cons_(
    Symbol.s_cond.cons_(
    Symbol("null").cons_(Symbol("m").cons_(List.nil)).cons_(Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(
    Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol.s_cons.cons_(Symbol("eval").cons_(Symbol.s_car.cons_(Symbol("m").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("evlis").cons_(Symbol.s_cdr.cons_(Symbol("m").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
    )
    ).cons_(List.nil)
    )).cons_(List.nil)
).cons_(

# evcon
Symbol("evcon").cons_(
    Symbol.s_lambda.cons_(Symbol("c").cons_(Symbol("a").cons_(List.nil)).cons_(
    Symbol.s_cond.cons_(
    Symbol("eval").cons_(Symbol("caar").cons_(Symbol("c").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("cadar").cons_(Symbol("c").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(
    Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol("evcon").cons_(Symbol.s_cdr.cons_(Symbol("c").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
    )
    ).cons_(List.nil))
    ).cons_(List.nil)
).cons_(

# eval
Symbol("eval").cons_(
    Symbol.s_lambda.cons_(Symbol("e").cons_(Symbol("a").cons_(List.nil)).cons_(
    Symbol.s_cond.cons_(
    # bare atom
    Symbol.s_atom.cons_(Symbol("e").cons_(List.nil)).cons_(
        Symbol("assoc").cons_(Symbol("e").cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)
    ).cons_(
    # apply an atom
    Symbol.s_atom.cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(List.nil)).cons_(
    Symbol.s_cond.cons_(
        # quote
        Symbol.s_eq.cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_quote.cons_(List.nil)).cons_(List.nil))).cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(List.nil)).cons_(
        # atom
        Symbol.s_eq.cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_atom.cons_(List.nil)).cons_(List.nil))).cons_(Symbol.s_atom.cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)).cons_(
        # eq
        Symbol.s_eq.cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_eq.cons_(List.nil)).cons_(List.nil))).cons_(Symbol.s_eq.cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("caddr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
        # car
        Symbol.s_eq.cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_car.cons_(List.nil)).cons_(List.nil))).cons_(Symbol.s_car.cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)).cons_(
        # cdr
        Symbol.s_eq.cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_cdr.cons_(List.nil)).cons_(List.nil))).cons_(Symbol.s_cdr.cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)).cons_(
        # cons
        Symbol.s_eq.cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_cons.cons_(List.nil)).cons_(List.nil))).cons_(Symbol.s_cons.cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("caddr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
        # cond
        Symbol.s_eq.cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_cond.cons_(List.nil)).cons_(List.nil))).cons_(Symbol("evcon").cons_(Symbol.s_cdr.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(
        # other atoms
        Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol("eval").cons_(Symbol.s_cons.cons_(Symbol("assoc").cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol.s_cdr.cons_(Symbol("e").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
        ) # /cond
        ) # /cons
        ) # /cdr
        ) # /car
        ) # /eq
        ) # /atom
        ) # /quote
    ).cons_(List.nil)).cons_(
    # lambda
    Symbol.s_eq.cons_(Symbol("caar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_lambda.cons_(List.nil)).cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("caddar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("append").cons_(Symbol("pair").cons_(Symbol("cadar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("evlis").cons_(Symbol.s_cdr.cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
    # label
    Symbol.s_eq.cons_(Symbol("caar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_label.cons_(List.nil)).cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol.s_cons.cons_(Symbol("caddar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_cdr.cons_(Symbol("e").cons_(List.nil)).cons_(List.nil))).cons_(Symbol.s_cons.cons_(Symbol("list").cons_(Symbol("cadar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol.s_car.cons_(Symbol("e").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
    ) # /lambda
    ) # /apply an atom
    ) # /bare atom
).cons_(List.nil))).cons_(List.nil)
).cons_(

# assoc
Symbol("assoc").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(
Symbol.s_cond.cons_(Symbol.s_eq.cons_(Symbol("caar").cons_(Symbol("y").cons_(List.nil)).cons_(Symbol("x").cons_(List.nil))).cons_(Symbol("cadar").cons_(Symbol("y").cons_(List.nil)).cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol("assoc").cons_(Symbol("x").cons_(Symbol.s_cdr.cons_(Symbol("y").cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)
).cons_(

# pair
Symbol("pair").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(
Symbol.s_cond.cons_(
Symbol("and").cons_(Symbol("null").cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("null").cons_(Symbol("y").cons_(List.nil)).cons_(List.nil))).cons_(Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(
Symbol("and").cons_(Symbol("not").cons_(Symbol.s_atom.cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(Symbol("not").cons_(Symbol.s_atom.cons_(Symbol("y").cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(Symbol.s_cons.cons_(Symbol("list").cons_(Symbol.s_car.cons_(Symbol("x").cons_(List.nil)).cons_(Symbol.s_car.cons_(Symbol("y").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("pair").cons_(Symbol.s_cdr.cons_(Symbol("x").cons_(List.nil)).cons_(Symbol.s_cdr.cons_(Symbol("y").cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
)
).cons_(List.nil))).cons_(List.nil)
).cons_(

# append
Symbol("append").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(
Symbol.s_cond.cons_(Symbol("null").cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("y").cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol.s_cons.cons_(Symbol.s_car.cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("append").cons_(Symbol.s_cdr.cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("y").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)
).cons_(

# caddar
Symbol("caddar").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(List.nil).cons_(Symbol.s_car.cons_(Symbol.s_cdr.cons_(Symbol.s_cdr.cons_(Symbol.s_car.cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)
).cons_(

# cadar
Symbol("cadar").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(List.nil).cons_(Symbol.s_car.cons_(Symbol.s_cdr.cons_(Symbol.s_car.cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)
).cons_(

# caar
Symbol("caar").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(List.nil).cons_(Symbol.s_car.cons_(Symbol.s_car.cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)
).cons_(

# caddr
Symbol("caddr").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(List.nil).cons_(Symbol.s_car.cons_(Symbol.s_cdr.cons_(Symbol.s_cdr.cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)
).cons_(

# cadr
Symbol("cadr").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(List.nil).cons_(Symbol.s_car.cons_(Symbol.s_cdr.cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)
).cons_(

# list
Symbol("list").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(Symbol.s_cons.cons_(Symbol("x").cons_(Symbol.s_cons.cons_(Symbol("y").cons_(Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)
).cons_(

# not
Symbol("not").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(List.nil).cons_(
Symbol.s_cond.cons_(Symbol("x").cons_(Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)
).cons_(

# and
Symbol("and").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(
Symbol.s_cond.cons_(Symbol("x").cons_(
Symbol.s_cond.cons_(Symbol("y").cons_(Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)
).cons_(

# null
Symbol("null").cons_(
Symbol.s_lambda.cons_(Symbol("x").cons_(List.nil).cons_(Symbol.s_eq.cons_(Symbol("x").cons_(Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil)

) # /and
) # /not
) # /list
) # /cadr
) # /caddr
) # /caar
) # /caddar
) # /cadar
) # /append
) # /pair
) # /assoc
) # /eval
) # /evcon
) # /evlis
) # /Symbol.builtins


