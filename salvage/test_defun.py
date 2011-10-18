from lisp3 import *

#    def list_(self, e):
#        self.cons_(e.cons_(List.nil))
Symbol('and').defun(
    Symbol('x').cons_(Symbol('y').cons_(List.nil)),
    Symbol.s_cond.cons_(
        (
            Symbol('x').cons_(
                Symbol.s_cond.cons_(
                    (
                        Symbol('y').cons_(
                            Symbol.s_quote.cons_(
                                Symbol.s_t.cons_(List.nil)  # quote
                            ).cons_(List.nil)  # y
                        ).cons_(
                            Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil))
                        ).cons_(List.nil)  # quote
                    ).cons_(List.nil)  # cond
                ).cons_(List.nil)  # x
            )  
        ).cons_(
            Symbol.s_quote.cons_(Symbol.s_t.cons_(List.nil)).cons_(
                Symbol.s_quote.cons_(List.nil.cons_(List.nil)).cons_(List.nil)  # () # quote
            )
        ).cons_(List.nil)  # cond
    ),
)

print str(Symbol.builtins)
