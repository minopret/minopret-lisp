(assert-equal (make-state 'a 'b 'c) '(a b c))
(assert-equal (state-valexp '(a b c)) 'a)
(assert-equal (state-env    '(a b c)) 'b)
(assert-equal (state-cont   '(a b c)) 'c)

(assert-equal (make-clo 'a 'b) '(a b))
(assert-equal (clo-lambda   '(a b)) 'a)
(assert-equal (clo-env      '(a b)) 'b)

(assert-equal (make-cont 'a 'b) '(a b))
(assert-equal (cont-typename    '(a b)) 'a)
(assert-equal (cont-data        '(a b)) '(b))

(assert-equal (make-retcont 'a 'b 'c) '(retcont a b c))
(assert-equal (cont-typename    '(retcont a b c)) 'retcont)
(assert-equal (retcont-context  '(retcont a b c)) 'a)
(assert-equal (retcont-env      '(retcont a b c)) 'b)
(assert-equal (retcont-cont     '(retcont a b c)) 'c)

(assert-equal haltcont '(haltcont))

(assert-equal (make-valexp 'a 'b 'c) '(a b c))
(assert-equal (valexp-typename  '(a b c)) 'a)
(assert-equal (valexp-insert    '(a b c)) 'b)
(assert-equal (valexp-nextexp   '(a b c)) 'c)

(assert-equal (make-den 'a) '(den (lambda (d) 'bad-insertion)
                              no-next-expressions a ))
(assert-equal (valexp-insert '(den (lambda (d) 'bad-insertion)
                               no-next-expressions a ))
             '(lambda (d) 'bad-insertion) )
(assert-equal ((valexp-insert '(den (lambda (d) 'bad-insertion)
                                no-next-expressions a )) 'b )
               'bad-insertion )
(assert-equal (valexp-nextexp '(den (lambda (d) 'bad-insertion)
                                no-next-expressions a ))
              'no-next-expressions )
(assert-equal (den-d '(den (lambda (d) 'bad-insertion)
                       no-next-expressions a ))
              'a )

(assert-equal (make-vapp-insert 'a 'b)
    (quote '(lambda (d) (
        (lambda (f-try) (cond
           ((eq f-try 'bad-insertion)
            (make-vapp a ((valexp-insert b) d)) )
           ( t (make-vapp f-try b)) ))
        ((valexp-insert a) d) ))) )
(assert-equal (make-vapp-nextexp 'a 'b)
    (quote '(
        (lambda (f-try) (cond
            ((eq f-try 'no-next-expressions) (valexp-nextexp b))
            (t f-try) ))
        (valexp-nextexp a) )) )
(assert-equal (make-vapp 'a 'b)
   '(vapp
       '(lambda (d) (
            (lambda (f-try) (cond
                ((eq f-try 'bad-insertion)
                 (make-vapp a ((valexp-insert b) d)) )
                ( t (make-vapp f-try b)) ))
            ((valexp-insert a) d) ))
        '(
            (lambda (f-try) (cond
                ((eq f-try 'no-next-expressions) (valexp-nextexp b) )
                ( t f-try) ))
            (valexp-nextexp a) )
          a b ) )
(assert-equal (valexp-typename (make-vapp 'a 'b)) 'vapp)
(assert-equal (valexp-insert (make-vapp 'a 'b))
    (quote '(lambda (d) (
        (lambda (f-try) (cond
           ((eq f-try 'bad-insertion)
            (make-vapp a ((valexp-insert b) d)) )
           ( t (make-vapp f-try b)) ))
        ((valexp-insert a) d) ))) )
(assert-equal (valexp-nextexp (make-vapp 'a 'b))
    (quote '(
        (lambda (f-try) (cond
            ((eq f-try 'no-next-expressions) (valexp-nextexp b))
            (t f-try) ))
        (valexp-nextexp a) )) )
(assert-equal (vapp-f (make-vapp 'a 'b)) 'a)
(assert-equal (vapp-e (make-vapp 'a 'b)) 'b)

(assert-equal (make-vexp 'a) '(vexp (lambda (d) (append
    (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
    (cons d ()) )) a) )
(assert-equal (valexp-typename '(vexp (lambda (d) (append
        (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
        (cons d ()) )) a) )
   'vexp )
(assert-equal (valexp-insert '(vexp (lambda (d) (append
        (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
        (cons d ()) )) a) )
   '(lambda (d) (append
        (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
        (cons d ()) )) )
(assert-equal (valexp-nextexp '(vexp (lambda (d) (append
        (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
        (cons d ()) )) a) )
   'a )
(assert-equal (vexp-exp '(vexp (lambda (d) (append
        (make-valexp 'den '(lambda (d) 'bad-insertion) 'no-next-expressions)
        (cons d ()) )) a) )
   'a )

(assert-equal (make-exp 'a 'b) '(a b))
(assert-equal (exp-typename '(a b)) 'a)
(assert-equal (exp-data '(a b)) '(b))

(assert-equal (make-ref 'a) '(ref a))
(assert-equal (exp-typename '(ref a)) 'ref)
(assert-equal (exp-data '(ref a)) '(a))
(assert-equal (ref-v '(ref a)) 'a)

(assert-equal (make-lambda 'a 'b) '(llama a b))
(assert-equal (exp-typename '(llama a b)) 'llama)
(assert-equal (exp-data '(llama a b)) '(a b))
(assert-equal (lambda-v '(llama a b)) 'a)
(assert-equal (lambda-body '(llama a b)) 'b)

(assert-equal (make-app 'a 'b) '(app a b))
(assert-equal (exp-typename '(app a b)) 'app)
(assert-equal (exp-data '(app a b)) '(a b))
(assert-equal (app-f '(app a b)) 'a)
(assert-equal (app-e '(app a b)) 'b)
