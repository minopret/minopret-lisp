; White-box testing of small-step interpreter for lambda calculus.
; Aaron Mansheim, December 2011

'0
(assert-equal (make-state 'a 'b 'c) '(a b c))  ; ok
(assert-equal (state-valexp '(a b c)) 'a)  ; ok
(assert-equal (state-env    '(a b c)) 'b)  ; ok
(assert-equal (state-cont   '(a b c)) 'c)  ; ok

(assert-equal (make-clo 'a 'b) '(a b))  ; ok
(assert-equal (clo-lambda   '(a b)) 'a)  ; ok
(assert-equal (clo-env      '(a b)) 'b)  ; ok

(assert-equal (make-cont 'a 'b) '(a b))  ; ok
(assert-equal (cont-typename    '(a b)) 'a)  ; ok
(assert-equal (cont-data        '(a b)) '(b))  ; ok

'10
(assert-equal (make-retcont 'a 'b 'c) '(retcont a b c))  ; ok
(assert-equal (cont-typename    '(retcont a b c)) 'retcont)  ; ok
; Assume cont-data is OK (as previously tested).
(assert-equal (retcont-context  '(retcont a b c)) 'a)  ; ok
(assert-equal (retcont-env      '(retcont a b c)) 'b)  ; ok
(assert-equal (retcont-cont     '(retcont a b c)) 'c)  ; ok

(assert-equal haltcont '(haltcont))  ; ok

(assert-equal (make-valexp 'a 'b 'c) '(a b 'c))  ; ok
(assert-equal (valexp-typename  '(a b 'c)) 'a)  ; ok
(assert-equal (valexp-insert    '(a b 'c)) 'b)  ; ok
(assert-equal (valexp-nextexp   '(a b 'c)) 'c)  ; ok

'20
; Tests of make-den and its result.
(assert-equal (make-den 'a)
    '(den (lambda (d) 'bad-insertion) 'no-next-expressions a) )  ; ok
(assert-equal (valexp-typename (make-den 'a)) 'den)  ; ok
(assert-equal (valexp-insert (make-den 'a))
    '(lambda (d) 'bad-insertion) )  ; ok
(assert-equal ((valexp-insert (make-den 'a)) 'b) 'bad-insertion)  ; ok
(assert-equal (valexp-nextexp (make-den 'a)) 'no-next-expressions)  ; ok

(assert-equal (den-d (make-den 'a)) 'a)  ; ok

; Assume make-vexp is OK (as subsequently tested).
(assert-equal (make-vapp (make-vexp '(ref a)) 'b)
   '(vapp
        (lambda (d) (
            (lambda (f-try) (cond
                ((eq f-try 'bad-insertion)
                 (make-vapp
                    ; a
                    '(vexp (lambda (d) (append
                         (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
                         (cons d ()) )) '(ref a) )
                    ; d into b
                    ((valexp-insert 'b) d) ) )
                 (t (make-vapp f-try 'b)) ))
           ; d into a
            ( (valexp-insert
                 ; a
                 '(vexp (lambda (d) (append
                      (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
                      (cons d ()) )) '(ref a) ) )
               d ) ))
       ; nextexp: a
       '(ref a)
       ; f: a
        (vexp (lambda (d) (append
            (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
            (cons d ()) )) '(ref a) )
       ; e: b
         b ) )
; Assume make-den is OK (as previously tested) and make-vexp is OK (as subsequently tested).
(assert-equal (make-vapp (make-den 'a) (make-vexp '(ref b)))
   '(vapp
        (lambda (d) (
            (lambda (f-try) (cond
                ( (eq f-try 'bad-insertion)
                  (make-vapp
                     ; a
                     '(den (lambda (d) 'bad-insertion) 'no-next-expressions a)
                     ; d into b
                      ( (valexp-insert
                           ; b
                           '(vexp (lambda (d) (append
                                (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
                                (cons d ()) )) '(ref b) ) )
                         d ) ) )
                (  t
                  (make-vapp
                       f-try
                     ; b
                     '(vexp (lambda (d) (append
                          (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
                          (cons d ()) )) '(ref b) ) ) ) ))
           ; d into a  ; clearly == 'bad-insertion
            ( (valexp-insert
                 ; a
                 '(den (lambda (d) 'bad-insertion) 'no-next-expressions a) )
               d ) ))
       ; nextexp: b
       '(ref b)
       ; f: a
        (den (lambda (d) 'bad-insertion) 'no-next-expressions a)
       ; e: b   
        (vexp (lambda (d) (append
            (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
            (cons d ()) )) '(ref b) ) ) )
(assert-equal (valexp-typename (make-vapp (make-den 'a) (make-den 'b))) 'vapp)
(assert-equal (valexp-insert (make-vapp (make-den 'a) (make-den 'b)))
    (make-vapp-insert (make-den 'a) (make-den 'b)) )
'30
(assert-equal ((valexp-insert (make-vapp (exp->valexp '(ref a)) (make-den 'b))) 'c)
    (make-vapp (make-den 'c) (make-den 'b)) )
(assert-equal ((valexp-insert (make-vapp (make-den 'a) (exp->valexp '(ref b)))) 'c)
    (make-vapp (make-den 'a) (make-den 'c)) )
(assert-equal (valexp-nextexp (make-vapp (make-den 'a) (make-den 'b)))
    (make-vapp-nextexp (make-den 'a) (make-den 'b)) )
(assert-equal (vapp-f (make-vapp (make-den 'a) (make-den 'b))) (make-den 'a))
(assert-equal (vapp-e (make-vapp (make-den 'a) (make-den 'b))) (make-den 'b))

; Tests of make-vexp and its result.
(assert-equal (make-vexp 'a) '(vexp (lambda (d) (append
    (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
    (cons d ()) )) 'a) )  ; ok
(assert-equal (valexp-typename (make-vexp 'a)) 'vexp)  ; ok
(assert-equal (valexp-insert (make-vexp 'a))
   '(lambda (d) (append
        (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
        (cons d ()) )) )  ; ok
(assert-equal ((valexp-insert (make-vexp 'a)) 'b) (make-den 'b))  ; ok
(assert-equal (valexp-nextexp (make-vexp 'a)) 'a)  ; ok
'40
(assert-equal (vexp-exp (make-vexp 'a)) 'a)  ; ok

(assert-equal (make-exp 'a 'b) '(a b))  ; ok
(assert-equal (exp-typename '(a b)) 'a)  ; ok
(assert-equal (exp-data '(a b)) '(b))  ; ok

(assert-equal (make-ref 'a) '(ref a))  ; ok
(assert-equal (exp-typename '(ref a)) 'ref)  ; ok
(assert-equal (exp-data '(ref a)) '(a))  ; ok
(assert-equal (ref-v '(ref a)) 'a)  ; ok

(assert-equal (make-lambda 'a 'b) '(llama a b))  ; ok
(assert-equal (exp-typename '(llama a b)) 'llama)  ; ok
'50
(assert-equal (exp-data '(llama a b)) '(a b))  ; ok
(assert-equal (lambda-v '(llama a b)) 'a)  ; ok
(assert-equal (lambda-body '(llama a b)) 'b)  ; ok

(assert-equal (make-app 'a 'b) '(app a b))  ; ok
(assert-equal (exp-typename '(app a b)) 'app)  ; ok
(assert-equal (exp-data '(app a b)) '(a b))  ; ok
(assert-equal (app-f '(app a b)) 'a)  ; ok
(assert-equal (app-e '(app a b)) 'b)  ; ok

(assert-equal (exp->valexp '(ref a)) (make-vexp '(ref a)))
(assert-equal (exp->valexp '(llama a (ref a))) (make-vexp '(llama a (ref a))))
'60
(assert-equal (exp->valexp '(app (ref a) (ref b)))
    (make-vapp (make-vexp '(ref a)) (make-vexp '(ref b))) )

'next
(assert-equal (next '((den (lambda (d) 'bad-insertion) 'no-next-expressions c) ((b c)) d))
    '(halted c) )
(assert-equal (next '((den (lambda (d) 'bad-insertion) 'no-next-expressions ((llama b (ref b)) c)) c d) )
    '(halted ((llama b (ref b)) c)) )
(assert-equal (next '((vexp a '(ref b)) ((b c)) d))
   '((den (lambda (d) 'bad-insertion) 'no-next-expressions c) ((b c)) d) )
(assert-equal (next '((vexp a '(llama b (ref b))) c d))
   '((den (lambda (d) 'bad-insertion) 'no-next-expressions ((llama b (ref b)) c)) c d) )

'vexp-next
(assert-equal
    (vexp-next (make-vexp '(ref a)) (make-state (make-vexp '(ref a)) '((a b)) 'c))
    (make-state (make-den 'b) '((a b)) 'c) )
(assert-equal (vexp-next
        (make-vexp '(llama a (ref a)))
        (make-state (make-vexp '(llama a (ref a))) 'b 'c) )
    (make-state (make-den (make-clo '(llama a (ref a)) 'b)) 'b 'c) )
(assert-equal (vexp-next (make-vexp '(app a b)) 'c) 'interpreter-error)  ; ok

'vapp-next
(assert-equal (vapp-next
        (make-vapp (make-den (make-clo '(llama a (ref a)) 'b)) (make-den 'c) )
        (cons (make-vapp (make-den (make-clo '(llama a (ref a)) 'b)) (make-den 'c))
              (list 'd 'e) ) )
    (make-state (make-vexp '(ref a)) '((a c) b) 'e) )

(assert-equal
    (vapp-next (make-vapp  (make-vexp '(ref v)) (make-vexp '(ref w)))
               (make-state (make-vapp (make-vexp '(ref v)) (make-vexp '(ref w)))
                          '((v (make-den (make-clo '(llama v (ref v)) ()))))
                          '(haltcont) ) )
   ; Once again, this is the sort of work that quasiquote is made for.
    (make-state
            (make-vexp '(ref v))
          '((v (make-den (make-clo '(llama v (ref v)) ()))))
            (make-retcont
                (cons 'lambda
                    (list '(clo)
                        (list
                            (list 'valexp-insert
                                (list 'state-valexp
                                    (list 'quote
                                        (make-state
                                            (make-vapp (make-vexp '(ref v)) (make-vexp '(ref w)))
                                          '((v (make-den (make-clo '(llama v (ref v)) ()))))
                                             haltcont ) ) ) )
                            'clo ) ) )
              '((v (make-den (make-clo '(llama v (ref v)) ()))))
                 haltcont ) ) )
; If 'a' is not a "denotable":
;; State(VApp(a,b),c,d) ==> State(a,c,RetCont( x => VApp(x,b) ,c,d)
'(assert-equal
    (app-next (make-vapp (make-vexp '(ref a)) (make-vexp '(ref b)))
        (make-state (make-vapp (make-vexp '(ref a)) (make-vexp '(ref b))) 'c 'd) )
    (make-state (make-vexp '(ref a)) 'c
        (make-retcont
            (cons 'lambda (list '(clo)
                (make-vapp 'clo (make-vexp '(ref b))) ))
            'c 'd) ) )
; If 'a' is a "denotable" but 'b' is not:
;; State(VApp(a,b),c,d) ==> State(b,c,RetCont( x => VApp(a,x) ,c,d)
'(assert-equal
    (app-next
        (make-vapp (make-den (make-clo '(llama a (ref a)))) (make-vexp '(ref b)))
        (make-state (make-vapp (make-den (make-clo '(llama a (ref a))))
            (make-vexp '(ref b))) 'c 'd) )
    (make-state (make-vexp '(ref b)) 'c
        (make-retcont
            (cons 'lambda (list '(clo)
                (make-vapp (make-den (make-clo '(llama a (ref a)))) 'clo) ))
            'c 'd) ) )


'den-next
(assert-equal
    (den-next (make-den 'a) (cons (make-den 'a) (list 'b (make-retcont '((a c)) 'd 'e))))
    (make-state 'c 'd 'e) )  ; ok
(assert-equal
    (den-next (make-den 'a) (cons (make-den 'a) (list 'b '(haltcont))))
   '(halted a) )  ; ok

'interpret
(assert-equal (interpret '(ref a)) '())
(assert-equal (interpret '(llama a (ref a))) '((llama a (ref a)) ()) )
'(assert-equal (interpret '(app (llama a (ref a)) (ref b))) '(ref b))

'(assert-equal
    (interpret '(app (app (app
                    (llama c (llama x (llama y (app (app (ref c) (ref x)) (ref y)))))
                  (llama x (llama y (ref x))) )
                (llama s (llama z (app (ref s) (ref z)))) )
              (llama s (llama z (app (ref s) (app (ref s) (ref z))))) ))
   '((llama s (llama z (app (ref s) (ref z))))) )
