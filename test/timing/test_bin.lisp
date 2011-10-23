; In binary
(assert-equal (fact-bin '(         ())) '(                      t))  ; 1
(assert-equal (fact-bin '(          t)) '(                      t))  ; 1
(assert-equal (fact-bin '(       t ())) '(                   t ()))  ; 2
(assert-equal (fact-bin '(       t  t)) '(                t  t ()))  ; 6
(assert-equal (fact-bin '(    t () ())) '(          t  t () () ()))  ; 24
(assert-equal (fact-bin '(    t ()  t)) '(    t  t  t  t () () ()))  ; 120
(assert-equal (fact-bin '(    t  t ())) '(                   t ()
                                           t  t ()  t () () () ()))  ; 720
(assert-equal (fact-bin '(    t  t  t)) '(          t () ()  t  t
                                           t ()  t  t () () () ()))  ; 5040
(assert-equal (fact-bin '( t () () ())) '( t () ()  t  t  t ()  t
                                           t () () () () () () ()))  ; 40320
(assert-equal (fact-bin '( t () ()  t)) '(                t ()  t
                                           t () () ()  t () ()  t
                                           t () () () () () () ()))  ; 362880
(assert-equal (fact-bin '( t ()  t ())) '(       t  t ()  t  t  t
                                          ()  t ()  t  t  t  t  t
                                          () () () () () () () ()))  ; 3628800
; In binary
(assert-equal (fib-bin '(         ())) '(                  ()))
(assert-equal (fib-bin '(          t)) '(                   t))
(assert-equal (fib-bin '(       t ())) '(                   t))
(assert-equal (fib-bin '(       t  t)) '(                t ()))
(assert-equal (fib-bin '(    t () ())) '(                t  t))
(assert-equal (fib-bin '(    t ()  t)) '(             t ()  t))
(assert-equal (fib-bin '(    t  t ())) '(          t () () ()))
(assert-equal (fib-bin '(    t  t  t)) '(          t  t ()  t))
(assert-equal (fib-bin '( t () () ())) '(       t ()  t ()  t))
(assert-equal (fib-bin '( t () ()  t)) '(    t () () ()  t ()))
(assert-equal (fib-bin '( t ()  t ())) '(    t  t ()  t  t  t))
(assert-equal (fib-bin '( t ()  t  t)) '( t ()  t  t () ()  t))

