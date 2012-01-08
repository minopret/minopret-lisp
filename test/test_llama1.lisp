; White-box testing of small-step interpreter for lambda calculus.
; Aaron Mansheim, December 2011

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

(assert-equal (make-retcont 'a 'b 'c) '(retcont a b c))  ; ok
(assert-equal (cont-typename    '(retcont a b c)) 'retcont)  ; ok
(assert-equal (retcont-context  '(retcont a b c)) 'a)  ; ok
(assert-equal (retcont-env      '(retcont a b c)) 'b)  ; ok
(assert-equal (retcont-cont     '(retcont a b c)) 'c)  ; ok

(assert-equal haltcont '(haltcont))  ; ok

(assert-equal (make-exp 'a 'b) '(a b))  ; ok
(assert-equal (exp-typename '(a b)) 'a)  ; ok
(assert-equal (exp-data '(a b)) '(b))  ; ok

(assert-equal (make-ref 'a) '(ref a))  ; ok
(assert-equal (exp-typename '(ref a)) 'ref)  ; ok
(assert-equal (exp-data '(ref a)) '(a))  ; ok
(assert-equal (ref-v '(ref a)) 'a)  ; ok

(assert-equal (make-lambda 'a 'b) '(llama a b))  ; ok
(assert-equal (exp-typename '(llama a b)) 'llama)  ; ok
(assert-equal (exp-data '(llama a b)) '(a b))  ; ok
(assert-equal (lambda-v '(llama a b)) 'a)  ; ok
(assert-equal (lambda-body '(llama a b)) 'b)  ; ok

(assert-equal (make-app 'a 'b) '(app a b))  ; ok
(assert-equal (exp-typename '(app a b)) 'app)  ; ok
'30
(assert-equal (exp-data '(app a b)) '(a b))  ; ok
(assert-equal (app-f '(app a b)) 'a)  ; ok
(assert-equal (app-e '(app a b)) 'b)  ; ok

(assert-equal (make-valexp 'a 'b 'c) '(a b 'c))  ; ok
(assert-equal (valexp-typename  '(a b 'c)) 'a)  ; ok
(assert-equal (valexp-insert    '(a b 'c)) 'b)  ; ok
(assert-equal (valexp-nextexp   '(a b 'c)) 'c)  ; ok

; Tests of make-den and its result.
(assert-equal (make-den 'a)
    '(den (lambda (d) 'bad-insertion) 'no-next-expressions a) )  ; ok
(assert-equal (valexp-insert (make-den 'a))
    '(lambda (d) 'bad-insertion) )  ; ok
(assert-equal ((valexp-insert (make-den 'a)) 'b) 'bad-insertion)  ; ok
'40
(assert-equal (valexp-nextexp (make-den 'a)) 'no-next-expressions)  ; ok

(assert-equal (den-d (make-den 'a)) 'a)  ; ok

; Tests of make-vexp and its result.
(assert-equal (make-vexp 'a) '(vexp (lambda (d) (append
    (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
    (cons d ()) )) (quote 'a)) )  ; ok
(assert-equal (valexp-typename (make-vexp 'a)) 'vexp)  ; ok
(assert-equal (valexp-insert (make-vexp 'a))
   '(lambda (d) (append
        (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
        (cons d ()) )) )  ; ok
(assert-equal ((valexp-insert (make-vexp 'a)) 'b) (make-den 'b))  ; ok
(assert-equal (valexp-nextexp (make-vexp 'a)) '(quote a))  ; ok
(assert-equal (vexp-exp (make-vexp 'a)) '(quote a))  ; ok

; Tests of make-vapp and its result.
(assert-equal (make-vapp-insert 'a 'b)
   '(lambda (d) (
        (lambda (f-try) (cond
            ((eq f-try 'bad-insertion)
             (make-vapp 'a ((valexp-insert 'b) d)) )
            ( t (make-vapp f-try 'b)) ))
        ((valexp-insert 'a) d) )) )
(assert-equal (make-vapp-nextexp 'a 'b) '(
    (lambda (f-try) (cond
       ((eq f-try 'no-next-expressions) (valexp-nextexp 'b))
       ( t f-try) ))
    (valexp-nextexp 'a) ))
'50
(assert-equal (make-vapp 'a 'b)
   '(vapp
        (lambda (d) (
            (lambda (f-try) (cond
                ((eq f-try 'bad-insertion)
                 (make-vapp 'a ((valexp-insert 'b) d)) )
                ( t (make-vapp f-try 'b)) ))
            ((valexp-insert 'a) d) ))
        '(
            (lambda (f-try) (cond
                ((eq f-try 'no-next-expressions) (valexp-nextexp 'b))
                ( t f-try) ))
            (valexp-nextexp 'a) )
          a b ) )  ; ok
(assert-equal (make-vapp 'a 'b)
    (cons 'vapp (append
        (list (make-vapp-insert 'a 'b) (list 'quote (make-vapp-nextexp 'a 'b)))
        (list 'a 'b) )) )  ; ok
(assert-equal (valexp-typename (make-vapp 'a 'b)) 'vapp)  ; ok
(assert-equal (valexp-insert (make-vapp 'a 'b)) (make-vapp-insert 'a 'b))  ; ok
(assert-equal ((valexp-insert (make-vapp (exp->valexp '(ref a)) 'b)) 'c)
    (make-vapp (make-den 'c) 'b) )  ; ok
(assert-equal ((valexp-insert (make-vapp (make-den 'a) (exp->valexp '(ref b)))) 'c)
    (make-vapp (make-den 'a) (make-den 'c)) )  ; ok
(assert-equal (valexp-nextexp (make-vapp 'a 'b)) (make-vapp-nextexp 'a 'b))  ; ok
(assert-equal (vapp-f (make-vapp 'a 'b)) 'a)  ; ok
(assert-equal (vapp-e (make-vapp 'a 'b)) 'b)  ; ok

(assert-equal (exp->valexp '(ref a)) (make-vexp '(ref a)))  ; ok
'60
(assert-equal (exp->valexp '(llama a (ref a))) (make-vexp '(llama a (ref a))))  ; ok
(assert-equal (exp->valexp '(app (ref a) (ref b)))
    (make-vapp (make-vexp '(ref a)) (make-vexp '(ref b))) )  ; ok

'den-next
(assert-equal
    (den-next (make-den 'a) (cons (make-den 'a) (list 'b (make-retcont '((a c)) 'd 'e))))
    (make-state 'c 'd 'e) )
(assert-equal
    (den-next (make-den 'a) (cons (make-den 'a) (list 'b '(haltcont))))
   '(halted a) )

'vexp-next
(assert-equal
    (vexp-next (make-vexp '(ref a)) (make-state (make-vexp '(ref a)) '((a b)) 'c))
    (make-state (make-den 'b) '((a b)) 'c) )
(assert-equal (vexp-next
        (make-vexp '(llama a (ref a)))
        (make-state (make-vexp '(llama a (ref a))) 'b 'c) )
    (make-state (make-den (make-clo '(llama a (ref a)) 'b)) 'b 'c) )
(assert-equal (vexp-next (make-vexp '(app a b)) 'c) 'interpreter-error)

'vapp-next
(assert-equal (vapp-next
        (make-vapp (make-den (make-clo '(llama a (ref a)) 'b)) (make-den 'c) )
        (cons (make-vapp (make-den (make-clo '(llama a (ref a)) 'b)) (make-den 'c))
              (list 'd 'e) ) )
    (make-state (make-vexp '(ref a)) '((a c) b) 'e) )

'(assert-equal
    (vapp-next (make-vapp  (make-vexp '(ref v)) (make-vexp '(ref w)))
               (make-state (make-vapp (make-vexp '(ref v)) (make-vexp '(ref w)))
                          '((v (make-den (make-clo '(llama v (ref v)) ()))))
                          '(haltcont) ) )
    () )
    '(make-state (make-vexp '(ref v))
               '((v (make-den (make-clo '(llama v (ref v)) ()))))
               '(retcont (lambda (clo) (make-vapp clo (make-vexp '(ref w))))
                         ((v (make-den (make-clo '(llama v (ref v)) ()))))
                         (haltcont) ) ) ; )
(make-vapp  (make-vexp '(ref v)) (make-vexp '(ref w)))
(make-state (make-vapp (make-vexp '(ref v)) (make-vexp '(ref w))) '((v (make-den (make-clo '(llama v (ref v)) ())))) '(haltcont) )

;; I forget what this was.
;(assert-equal (vapp-next 
;        (make-vapp (make-vexp '(ref a)) (make-den '(ref b)))
;        (cons (make-vapp (make-vexp '(ref a)) (make-den '(ref b))) (list 'c 'd)) )

(assert-equal (next '((den (lambda (d) 'bad-insertion) 'no-next-expressions c) ((b c)) d))
    '(halted c) )
(assert-equal (next '((den (lambda (d) 'bad-insertion) 'no-next-expressions ((llama b (ref b)) c)) c d) )
    '(halted ((llama b (ref b)) c)) )
(assert-equal (next '((vexp a '(ref b)) ((b c)) d))
   '((den (lambda (d) 'bad-insertion) 'no-next-expressions c) ((b c)) d) )
(assert-equal (next '((vexp a '(llama b (ref b))) c d))
   '((den (lambda (d) 'bad-insertion) 'no-next-expressions ((llama b (ref b)) c)) c d) )


'(assert-equal (interpret '(ref a)) '())
'(assert-equal (interpret '(llama a (ref a))) '((llama a (ref a)) ()) )
'(assert-equal (interpret '(app (llama a (ref a)) (ref b))) '(ref b))

'(assert-equal
    (interpret '(app (app (app
                    (llama c (llama x (llama y (app (app (ref c) (ref x)) (ref y)))))
                  (llama x (llama y (ref x))) )
                (llama s (llama z (app (ref s) (ref z)))) )
              (llama s (llama z (app (ref s) (app (ref s) (ref z))))) ))
   '((llama s (llama z (app (ref s) (ref z))))) )
