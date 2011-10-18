from lisp3 import Symbol, List

# evlis
Symbol("evlis").cons_(
    Symbol("lambda").cons_(Symbol("m").cons_(Symbol("a").cons_(List.nil)).cons_(
        Symbol("cond").cons_(
            Symbol("null").cons_(Symbol("m").cons_(List.nil)).cons_(Symbol("quote").cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(
                Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(Symbol("cons").cons_(Symbol("eval").cons_(Symbol("car").cons_(Symbol("m").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("evlis").cons_(Symbol("cdr").cons_(Symbol("m").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
            )
        ).cons_(List.nil)
    )).cons_(List.nil)
).cons_(
# evcon
Symbol("evcon").cons_(
    Symbol("lambda").cons_(Symbol("c").cons_(Symbol("a").cons_(List.nil)).cons_(
        Symbol("cond").cons_(
            Symbol("eval").cons_(Symbol("caar").cons_(Symbol("c").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("cadar").cons_(Symbol("c").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(
                Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(Symbol("evcon").cons_(Symbol("cdr").cons_(Symbol("c").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
            )
        ).cons_(List.nil))
    ).cons_(List.nil)
).cons_(
# eval
Symbol("eval").cons_(
    Symbol("lambda").cons_(Symbol("e").cons_(Symbol("a").cons_(List.nil)).cons_(
    Symbol("cond").cons_(
    # bare atom
    Symbol("atom").cons_(Symbol("e").cons_(List.nil)).cons_(
        Symbol("assoc").cons_(Symbol("e").cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)
    ).cons_(
    # apply an atom
    Symbol("atom").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(List.nil)).cons_(
    Symbol("cond").cons_(
        # quote
        Symbol("eq").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("quote").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(List.nil)).cons_(
        # atom
        Symbol("eq").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("atom").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("atom").cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)).cons_(
        # eq
        Symbol("eq").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("eq").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("eq").cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("caddr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
        # car
        Symbol("eq").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("car").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("car").cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)).cons_(
        # cdr
        Symbol("eq").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("cdr").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("cdr").cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)).cons_(
        # cons
        Symbol("eq").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("cons").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("cons").cons_(Symbol("eval").cons_(Symbol("cadr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("caddr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
        # cond
        Symbol("eq").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("cond").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("evcon").cons_(Symbol("cdr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(
        # other atoms
        Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(Symbol("eval").cons_(Symbol("cons").cons_(Symbol("assoc").cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(Symbol("cdr").cons_(Symbol("e").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
        ) # /cond
        ) # /cons
        ) # /cdr
        ) # /car
        ) # /eq
        ) # /atom
        ) # /quote
    ).cons_(List.nil)).cons_(
    # lambda
    Symbol("eq").cons_(Symbol("caar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("lambda").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("caddar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("append").cons_(Symbol("pair").cons_(Symbol("cadar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("evlis").cons_(Symbol("cdr").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
    # label
    Symbol("eq").cons_(Symbol("caar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("label").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("eval").cons_(Symbol("cons").cons_(Symbol("caddar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("cdr").cons_(Symbol("e").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("cons").cons_(Symbol("list").cons_(Symbol("cadar").cons_(Symbol("e").cons_(List.nil)).cons_(Symbol("car").cons_(Symbol("e").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("a").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
    ) # /lambda
    ) # /apply an atom
    ) # /bare atom
).cons_(List.nil))).cons_(List.nil)).cons_(
# assoc
Symbol("assoc").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(
Symbol("cond").cons_(Symbol("eq").cons_(Symbol("caar").cons_(Symbol("y").cons_(List.nil)).cons_(Symbol("x").cons_(List.nil))).cons_(Symbol("cadar").cons_(Symbol("y").cons_(List.nil)).cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(Symbol("assoc").cons_(Symbol("x").cons_(Symbol("cdr").cons_(Symbol("y").cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
# pair
Symbol("pair").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(
Symbol("cond").cons_(
Symbol("and").cons_(Symbol("null").cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("null").cons_(Symbol("y").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("quote").cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(
Symbol("and").cons_(Symbol("not").cons_(Symbol("atom").cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(Symbol("not").cons_(Symbol("atom").cons_(Symbol("y").cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(Symbol("cons").cons_(Symbol("list").cons_(Symbol("car").cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("car").cons_(Symbol("y").cons_(List.nil)).cons_(List.nil))).cons_(Symbol("pair").cons_(Symbol("cdr").cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("cdr").cons_(Symbol("y").cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
)
).cons_(List.nil))).cons_(List.nil)).cons_(
# append
Symbol("append").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(
Symbol("cond").cons_(Symbol("null").cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("y").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(Symbol("cons").cons_(Symbol("car").cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("append").cons_(Symbol("cdr").cons_(Symbol("x").cons_(List.nil)).cons_(Symbol("y").cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
# caddar
Symbol("caddar").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(List.nil).cons_(Symbol("car").cons_(Symbol("cdr").cons_(Symbol("cdr").cons_(Symbol("car").cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(
# cadar
Symbol("cadar").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(List.nil).cons_(Symbol("car").cons_(Symbol("cdr").cons_(Symbol("car").cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(
# caar
Symbol("caar").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(List.nil).cons_(Symbol("car").cons_(Symbol("car").cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(
# caddr
Symbol("caddr").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(List.nil).cons_(Symbol("car").cons_(Symbol("cdr").cons_(Symbol("cdr").cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(
# cadr
Symbol("cadr").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(List.nil).cons_(Symbol("car").cons_(Symbol("cdr").cons_(Symbol("x").cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(
# list
Symbol("list").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(Symbol("cons").cons_(Symbol("x").cons_(Symbol("cons").cons_(Symbol("y").cons_(Symbol("quote").cons_(List.nil.cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
# not
Symbol("not").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(List.nil).cons_(
Symbol("cond").cons_(Symbol("x").cons_(Symbol("quote").cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
# and
Symbol("and").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(Symbol("y").cons_(List.nil)).cons_(
Symbol("cond").cons_(Symbol("x").cons_(
Symbol("cond").cons_(Symbol("y").cons_(Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(Symbol("quote").cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil)).cons_(Symbol("quote").cons_(Symbol("t").cons_(List.nil)).cons_(Symbol("quote").cons_(List.nil.cons_(List.nil)).cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(
# null
Symbol("null").cons_(
Symbol("lambda").cons_(Symbol("x").cons_(List.nil).cons_(Symbol("eq").cons_(Symbol("x").cons_(Symbol("quote").cons_(List.nil.cons_(List.nil)).cons_(List.nil))).cons_(List.nil))).cons_(List.nil)).cons_(List.nil)
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
