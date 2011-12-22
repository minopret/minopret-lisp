; Small-step interpreter for the lambda calculus,
; that is, the kind of interpreter that uses a "hole"
; in the expression to be reduced.
; 
; Closely follows Matthew Might:
; http://matt.might.net/articles/writing-an-interpreter-substitution-denotational-big-step-small-step/
; http://matt.might.net/articles/writing-an-interpreter-substitution-denotational-big-step-small-step/SmallStepInterpreter.scala
;
; The first 100 lines of this code could be made much more concise
; by defining "struct" in the manner of Scheme.
;
; In any case this is much more verbose than llama.env.lisp,
; but it has the advantage that it is pretty close to language Λ
; (that's U+039b) as Matthias Felleisen describes it in "On the
; Expressive Power of Programming Languages".
;
; Aaron Mansheim 2011-12-11

; Types:
;
; state(valexp, env:a-list, cont)
; clo((v:atom, body:proc), env:a-list)
; cont                                  ; abstract
;   RetCont(context: proc clo->valexp, env:a-list, cont)
;   HaltCont
; valexp(insert:proc, nextexp:proc)     ; abstract
;   den(clo)
;   vapp(f:valexp, e:valexp)
;   vexp
; exp                                   ; abstract
;   ref(atom)
;   lambda(atom, proc)
;   app(clo, clo)


; State, a partially evaluated value expression.
(make-state (lambda (valexp env cont) (cons valexp (list env cont))))
(state-valexp   (lambda (state) (car    state)))
(state-env      (lambda (state) (cadr   state)))
(state-cont     (lambda (state) (caddr  state)))


; An env is an a-list associating variables to denotable values.


; One type of denotable value (the only one here) is a closure.
; This interpreter could be exhanced to allow also strings, numbers, etc.
(make-clo   (lambda (lam env) (list lam env)))
(clo-lambda (lambda (clo) (car  clo)))
(clo-env    (lambda (clo) (cadr clo)))


; continuations of various types
(make-cont (lambda (typename data) (cons typename data)))
(cont-typename  (lambda (cont) (car cont)))
(cont-data      (lambda (cont) (cdr cont)))


; RetCont, a continuation that takes a return value and produces
; a new value expression.
(make-retcont (lambda (context env cont)
    (make-cont 'retcont (cons context (list env cont))) ))
(retcont-context    (lambda (retcont) (car      (cont-data retcont))))
(retcont-env        (lambda (retcont) (cadr     (cont-data retcont))))
(retcont-cont       (lambda (retcont) (caddr    (cont-data retcont))))


; HaltCont, a continuation object that signals the halting of the program
(haltcont           (haltcont))


; ValExp, a partially evaluated expression.
; "insert": A function of a denotable value (closure) that places it
;    in a copy of this ValExp in place of the ValExp's leftmost unevaluated expression.
; "nextexp": The ValExp's leftmost unevaluated expression.
(make-valexp (lambda (typename insert nextexp) (cons typename (list insert nextexp))))
(valexp-typename    (lambda (valexp) (car   valexp)))
(valexp-insert      (lambda (valexp) (cadr  valexp)))
(valexp-nextexp     (lambda (valexp) (caddr valexp)))


; Den, a ValExp that is fully evaluated, and must not be evaluated further.
(make-den (lambda (d) (append
    (make-valexp
        'den
       '(lambda (d) 'bad-insertion)
        'no-next-expressions )
    (cons d ()) )))
(den-d (lambda (den) (cadddr den)))


; VApp, a ValExp that is a partially evaluated application
; of one ValExp to another.
(make-vapp (lambda (f e) (append
    (make-valexp
        'vapp
       '(lambda (d) (
            (lambda (f-try) (cond (
                ((eq f-try 'bad-insertion)
                    (make-vapp f ((valexp-insert e) d)) )
                ( t
                     f-try ) ) ))
            (make-vapp ((valexp-insert f) d) e) ))
       '(
            (lambda (f-try) (cond (
                ((eq f-try 'no-next-expressions)
                    (valexp-nextexp e) )
                ( t
                     f-try ) )))
            (valexp-nextexp f) ) )
    (list f e) )))
(vapp-f (lambda (vapp) (cadddr vapp)))
(vapp-e (lambda (vapp) (car (cddddr vapp))))


; VExp, a ValExp that cannot be partially evaluated, either because
; it is already fully evaluated or because it is unevaluated.
; Example: lambda terms, which evaluate to closures.
; Example: references, which evaluate via environment lookup.
(make-vexp (lambda (exp) (make-valexp
    'vexp
    'make-den
     exp )))
(vexp-exp  (lambda (vexp) (valexp-nextexp vexp)))


; Exp of various types
; Examples:
;   '(lambda x (lambda y (ref x)))
;   '(lambda s (lambda z (app (ref s) (ref z))))
(make-exp       (lambda (typename data) (cons typename data)))
(exp-typename   (lambda (exp) (car exp)))
(exp-data       (lambda (exp) (cdr exp)))

(make-ref   (lambda (v) (make-exp 'ref (cons v ()))))
(ref-v      (lambda (ref) (car (exp-data ref))))

(make-lambda    (lambda (v body) (make-exp 'llama (list v body))))
(lambda-v       (lambda (lam) (car  (exp-data lam))))
(lambda-body    (lambda (lam) (cadr (exp-data lam))))

(make-app   (lambda (f e) (make-exp 'app (list f e))))
(app-f      (lambda (app) (car  (exp-data app))))
(app-e      (lambda (app) (cadr (exp-data app))))

(exp->valexp    (lambda (exp) (cond
    ((eq (exp-typename exp) 'ref)       (make-vexp exp))
    ((eq (exp-typename exp) 'llama)    (make-vexp exp))
    ( t                                 (make-vapp  ; (eq (exp-typename exp) 'app)
        (exp->valexp (app-f exp))
        (exp->valexp (app-e exp)) )) )))


; State transition function.
(next   (lambda (s) (
    (lambda (valexp) (cond
        ((eq (valexp-typename valexp) 'vexp) (vexp-next valexp s))
        ((eq (valexp-typename valexp) 'vapp) (vapp-next valexp s))
        ((eq (valexp-typename valexp) 'den)  (den-next  valexp s)) ))
    (state-valexp s) )))

(vexp-next (lambda (vexp s) (
    (lambda (exp) (cond
        ; look up a variable
        ((eq (exp-typename exp) 'ref)
            (make-state (make-den (assoc (ref-v exp) (state-env s)))
                (state-env s) (state-cont s) ) )

        ; close over a lambda term
        ((eq (exp-typename exp) 'llama)
            (make-state (make-den (make-clo exp (state-env s)))
                (state-env s) (state-cont s) ) )

        ; eq (exp-typename exp) 'app
        (t 'interpreter-error) ))  
    (vexp-exp vexp) )))

(vapp-next (lambda (vapp s) (cond
    ; apply a function
    ((and (eq (valexp-typename (vapp-f vapp)) 'den)
          (eq (valexp-typename (vapp-e vapp)) 'den))
     (  (lambda (v body env2 darg)
            (make-state body (cons (list v darg) env2) (state-cont s)) )
        (lambda-v    (clo-lambda (vapp-f vapp)))
        (exp->valexp (lambda-body (clo-lambda (vapp-f vapp))))
        (clo-env (vapp-f vapp))
        (vapp-e vapp) ) )

    ; evaluate a sub-expression
    ;;case VApp(_,_) => 
    ;;  State(s.valexp.nextExp, s.env, RetCont(s.valexp.insert(_), s.env, s.cont))
    ( t
     (make-state (exp->valexp (valexp-nextexp (state-valexp s)))
                 (state-env s)
                 (make-retcont (lambda (clo) (valexp-insert (state-valexp s) clo))
                               (state-env s)
                               (state-cont s) ) ) ) )))

; return to the current continuation
(den-next (lambda (den s) (
    (lambda (c) (cond
        ((eq (cont-typename c) 'retcont)
         (make-state ((retcont-context c) (den-d den))
                      (retcont-env     c)
                      (retcont-cont    c) ) )
        ( t (list 'halted (den-d den))) ))  ; (cont-typename c 'haltcont)
    (state-cont s) )))


(interpret (lambda (exp) (
    (label try-next (lambda (s) (
        (lambda (s-try) (cond
            ((eq (car s-try) 'halted) (cadr s-try))
            ( t (try-next s-try)) ))
        (next s) )))
    (make-state (exp->valexp exp) () haltcont) )))

