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
(make-state (lambda (valexp env cont) (cons valexp (list env cont))))  ; ok
(state-valexp   (lambda (state) (car    state)))  ; ok
(state-env      (lambda (state) (cadr   state)))  ; ok
(state-cont     (lambda (state) (caddr  state)))  ; ok


; An env is an a-list associating variables to denotable values.


; One type of denotable value (the only one here) is a closure.
; This interpreter could be exhanced to allow also strings, numbers, etc.
(make-clo   (lambda (lam env) (list lam env)))  ; ok
(clo-lambda (lambda (clo) (car  clo)))  ; ok
(clo-env    (lambda (clo) (cadr clo)))  ; ok


; continuations of various types
(make-cont (lambda (typename data) (cons typename data)))  ; ok
(cont-typename  (lambda (cont) (car cont)))  ; ok
(cont-data      (lambda (cont) (cdr cont)))  ; ok


; RetCont, a continuation that takes a return value and produces
; a new value expression.
(make-retcont (lambda (context env cont)
    (make-cont 'retcont (cons context (list env cont))) ))  ; ok
(retcont-context    (lambda (retcont) (car      (cont-data retcont))))  ; ok
(retcont-env        (lambda (retcont) (cadr     (cont-data retcont))))  ; ok
(retcont-cont       (lambda (retcont) (caddr    (cont-data retcont))))  ; ok


; HaltCont, a continuation object that signals the halting of the program
(haltcont           (haltcont))  ; ok


; ValExp, a partially evaluated expression.
; "insert": A function of a denotable value (closure) that places it
;    in a copy of this ValExp in place of the ValExp's leftmost unevaluated expression.
; "nextexp": The ValExp's leftmost unevaluated expression.
(make-valexp (lambda (typename insert nextexp) (cons typename (list insert (list 'quote nextexp)))))  ; ok
(valexp-typename    (lambda (valexp) (car   valexp)))  ; ok
(valexp-insert      (lambda (valexp) (cadr  valexp)))  ; ok
(valexp-nextexp     (lambda (valexp) (cadr (caddr valexp))))  ; ok


; Den, a ValExp that is fully evaluated, and must not be evaluated further.
(make-den (lambda (d) (append
    (make-valexp
        'den
       '(lambda (d) 'bad-insertion)
       'no-next-expressions )
    (cons d ()) )))  ; ok
(den-d (lambda (den) (cadddr den)))  ; ok


; VApp, a ValExp that is a partially evaluated application
; of one ValExp to another.
(make-vapp (lambda (f e) (append
    (make-valexp
        'vapp
        (make-vapp-insert f e)
        (make-vapp-nextexp f e) )
    (list f e) )))  ; ok
; A good example of what quasiquote is for. But I don't have it (yet).
; (make-vapp-insert (lambda (f e)
;   `(lambda (d) (
;       (lambda (f-try) (cond
;           ((eq f-try 'bad-insertion)
;            (make-vapp (quote ,f) ((valexp-insert (quote ,e)) d)) )
;           ( t (make-vapp f-try (quote ,e))) ))
;       ((valexp-insert (quote ,f)) d) )) ))
(make-vapp-insert (lambda (f e) 
    (cons 'lambda (list '(d) (list
        (cons 'lambda (list '(f-try) (cons 'cond (list
            (list '(eq f-try 'bad-insertion)
                (cons 'make-vapp (list (list 'quote f) (list (list 'valexp-insert (list 'quote e)) 'd))) )
            (list t
                (cons 'make-vapp (list 'f-try (list 'quote e))) ) ))))
        (list (list 'valexp-insert (list 'quote f)) 'd) ))) ))  ; ok
; Another good example of what quasiquote is for. But I still don't have it.
; (make-vapp-nextexp (lambda (f e) `(
;     (lambda (f-try) (cond
;        ((eq f-try 'no-next-expressions) (valexp-nextexp (quote ,e)))
;        ( t f-try) ))
;     (valexp-nextexp (quote ,f)) )))
(make-vapp-nextexp (lambda (f e) (list
    (cons 'lambda (list '(f-try) (cons 'cond (list
        (list '(eq f-try 'no-next-expressions)
            (list 'valexp-nextexp (list 'quote e)) )
       '( t
             f-try ) ))))
    (list 'valexp-nextexp (list 'quote f)) )))  ; ok
(vapp-f (lambda (vapp) (cadddr vapp)))  ; ok
(vapp-e (lambda (vapp) (car (cddddr vapp))))  ; ok


; VExp, a ValExp that cannot be partially evaluated, either because
; it is already fully evaluated or because it is unevaluated.
; Example: lambda terms, which evaluate to closures.
; Example: references, which evaluate via environment lookup.
(make-vexp (lambda (exp) (make-valexp
    'vexp
     make-den
    (list 'quote exp) )))  ; ok
(vexp-exp  (lambda (vexp) (valexp-nextexp vexp)))  ; ok


; Exp of various types
; Examples:
;   '(lambda x (lambda y (ref x)))
;   '(lambda s (lambda z (app (ref s) (ref z))))
(make-exp       (lambda (typename data) (cons typename data)))  ; ok
(exp-typename   (lambda (exp) (car exp)))  ; ok
(exp-data       (lambda (exp) (cdr exp)))  ; ok

(make-ref   (lambda (v) (make-exp 'ref (cons v ()))))  ; ok
(ref-v      (lambda (ref) (car (exp-data ref))))  ; ok

(make-lambda    (lambda (v body) (make-exp 'llama (list v body))))  ; ok
(lambda-v       (lambda (lam) (car  (exp-data lam))))  ; ok
(lambda-body    (lambda (lam) (cadr (exp-data lam))))  ; ok

(make-app   (lambda (f e) (make-exp 'app (list f e))))  ; ok
(app-f      (lambda (app) (car  (exp-data app))))  ; ok
(app-e      (lambda (app) (cadr (exp-data app))))  ; ok

(exp->valexp    (lambda (exp) (cond
    ((eq (exp-typename exp) 'ref)       (make-vexp exp))
    ((eq (exp-typename exp) 'llama)     (make-vexp exp))
    ( t                                 (make-vapp  ; (eq (exp-typename exp) 'app)
        (exp->valexp (app-f exp))
        (exp->valexp (app-e exp)) )) )))  ; ok


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
        ( t  'interpreter-error) ))
    (cadr (vexp-exp vexp)) )))

(vapp-next (lambda (vapp s) (cond
    ; apply a function

    ; Next two cases evaluate a sub-expression
    ;;case VApp(_,_) => 
    ;;  State(s.valexp.nextExp, s.env, RetCont(s.valexp.insert(_), s.env, s.cont))
    ; where "s.valexp.insert(_)" means the anonymous function
    ; "x => s.valexp.insert(x)"

    ; If 'a' is not a "denotable":
    ;; State(VApp(a,b),c,d) ==> State(a,c,RetCont( x => VApp(x,b) ,c,d)
    ; If 'a' is a "denotable" but 'b' is not:
    ;; State(VApp(a,b),c,d) ==> State(b,c,RetCont( x => VApp(a,x) ,c,d)
    ((or (not (eq (valexp-typename (vapp-f vapp)) 'den))
         (not (eq (valexp-typename (vapp-e vapp)) 'den)) )
     (make-state (exp->valexp (valexp-nextexp (state-valexp s)))
                 (state-env s)
                 (make-retcont (lambda (clo) (valexp-insert (state-valexp s) clo))
                               (state-env s)
                               (state-cont s) ) ) )
    ( t
     (  (lambda (v body env2 darg)
            (make-state body (cons (list v darg) env2) (state-cont s)) )
        (lambda-v    (clo-lambda (den-d (vapp-f vapp))))
        (exp->valexp (lambda-body (clo-lambda (den-d (vapp-f vapp)))))
        (clo-env (den-d (vapp-f vapp)))
        (den-d (vapp-e vapp)) ) ) )))

; return to the current continuation
(den-next (lambda (den s) (
    (lambda (c) (cond
        ((eq (cont-typename c) 'retcont)
         (make-state (assoc (den-d den) (retcont-context c))
                     (retcont-env   c)
                     (retcont-cont  c) ) )
        ( t (list 'halted (den-d den))) ))  ; (cont-typename c 'haltcont)
    (state-cont s) )))


(interpret (lambda (exp) (
    (label try-next (lambda (s) (
        (lambda (s-try) (cond
            ((eq (car s-try) 'halted) (cadr s-try))
            ( t (try-next s-try)) ))
        (next s) )))
    (make-state (exp->valexp exp) () haltcont) )))
