; Small-step interpreter for the lambda calculus,
; that is, the kind of interpreter that uses a "hole"
; in the expression to be reduced.
; 
; Following Matthew Might:
; http://matt.might.net/articles/writing-an-interpreter-substitution-denotational-big-step-small-step/
; http://matt.might.net/articles/writing-an-interpreter-substitution-denotational-big-step-small-step/SmallStepInterpreter.scala
;
; Aaron Mansheim 2011-12-11


; An env is an a-list of variables and denotable values.
; One type of denotable value (the only one here) is a closure.


; State, a partially evaluated value expression.
(make-state (lambda (valexp env cont) (cons valexp (list env cont))))
(state-valexp   (lambda (state) (car    state)))
(state-env      (lambda (state) (cadr   state)))
(state-cont     (lambda (state) (caddr  state)))


; continuations of various types
(cont-typename (lambda (cont) (car cont)))


; RetCont, a continuation that takes a return value and produces
; a new value expression.
(make-retcont (lambda (context env cont)
    (append (list 'retcont context) (list env cont))) )
(retcont-context    (lambda (retcont) (cadr     retcont)))
(retcont-env        (lambda (retcont) (caddr    retcont)))
(retcont-cont       (lambda (retcont) (cadddr   retcont)))


; HaltCont, a continuation that signals the halting of the program
(make-haltcont     '(haltcont))


; ValExp, a partially evaluated expression.
; "insert": A function of a denotable value that places it
;    in a copy of this ValExp instead of the leftmost unevaluated expression.
; "nextexp": The leftmost unevaluated expression.
(make-valexp (lambda (insert nextexp) (list insert nextexp)))
(valexp-insert      (lambda (valexp)    (car    valexp)))
(valexp-nextexp     (lambda (valexp)    (cadr   valexp)))


; Den, a ValExp that is fully evaluated, and must not be evaluated further.
(make-den (lambda (d) '((lambda (d) (lambda (valexp) 'bad-insertion))
                        (lambda (valexp) 'no-next-expressions)))


; ValApp, a ValExp that is a partially evaluated application
; of one ValExp to another.
(make-valapp (lambda (f e) '(
    (lambda (d) (
        (lambda (f1) (cond (
            ((and (atom f1) (eq f1 'bad-insertion))
                (make-valapp f ((valexp-insert e) d)) )
            ( t
                 f1 ) ) )))
        (make-valapp ((valexp-insert f) d) e) )
    (
        (lambda (f1) (cond (
            ((and (atom f1) (eq f1 'no-next-expressions))
                (valexp-nextexp e) )
            ( t
                 f1 )
        (valexp-nextexp f) ))) ) )))


; VExp, a ValExp that cannot be partially evaluated, either because
; it is already fully evaluated or because it is unevaluated.
; Example: lambda terms, which evaluate to closures.
; Example: references, which evaluate via environment lookup.
(make-vexp (lambda (exp) (list 'make-den (list 'quote exp))))


