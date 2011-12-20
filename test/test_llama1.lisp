; Test of "llama" calculus.
; Ideally, will use: test/llama.env.lisp
; Aaron Mansheim 2011-12-09

(assert-equal
    (interpret '(lambda x (ref x)))
   '((lambda x (ref x))) )

'(assert-equal
    (eeval '(llama x (llama y x)) ())
   '((llama x (llama y x))) )

'(assert-equal
    (eeval '(llama x (llama y y)) ())
   '((llama x (llama y y))) )

'(assert-equal
    (eeval '(llama c (llama x (llama y ((c x) y)))) ())
   '((llama c (llama x (llama y ((c x) y))))) )

'(assert-equal
    (eeval '(llama z z) ())
   '((llama z z)) )

'(assert-equal
    (eeval '(llama s (llama z (s z))) ())
   '((llama s (llama z (s z)))) )

'(assert-equal
    (eeval '(llama s (llama z (s (s z)))) ())
   '((llama s (llama z (s (s z))))) )

'(assert-equal
    (eeval '( ( ( (llama c (llama x (llama y ((c x) y))))
                  (llama x (llama y x)) )
                (llama s (llama z (s z))) )
              (llama s (llama z (s (s z)))) ) ())
   '((llama s (llama z (s z)))) )

'(assert-equal
    (eeval '( ( ( ( (llama if (llama true (llama one
                      (llama two (((if true) one) two)) )))
                    (llama c (llama x (llama y ((c x) y)))) )
                  (llama x (llama y x)) )
                (llama s (llama z (s z))) )
              (llama s (llama z (s (s z)))) ) ())
   '((llama s (llama z (s z)))) )

'(assert-equal
    (eeval '(llama x (llama y x)) ())
   '((llama x (llama y x))) )

'(assert-equal
    (eeval '( ( (
                (llama c (llama x (llama y ((c x) y))))
                (llama x (llama y x)) )
            (llama s (llama z (s z))) )
        (llama s (llama z (s (s z)))) )
        () )
   '((llama s (llama z (s z)))) )

; (λq.nnot(q) ttrue)
'(assert-equal
    (eeval '(
        (llama q ((q (llama x (llama y y))) (llama x (llama y x))))
        (llama x (llama y x)) ) () )
   '( (llama x (llama y y)) (q ((llama x (llama y x)))) ) )

; (λq.nnot(q) ffalse)
'(assert-equal
    (eeval '(
        (llama q ((q (llama x (llama y y))) (llama x (llama y x))))
        (llama x (llama y y)) ) () )
   '( (llama x (llama y x)) (q ((llama x (llama y y)))) ) )


; DeMorgan's rule defined as follows:
;   ~(u /\ v) <-> ~u \/ ~v
; And in "llama" calculus with names for common boolean functions:
;   (llama u (llama v ( (iiff (nnot ((aand u) v))) ((oor (nnot u)) (nnot v)) )))

; Just test the car of the "eeval" result, which is the lambda function
; in the resulting closure. Although the function is actually closed,
; the closure has a big environment left over from reduction.

; Test with u = ttrue; v = ttrue
'(assert-equal (car (eeval '( (

    (llama u (llama v ( ( (llama r (llama s ((r s) (
          (llama q ((q (llama x (llama y y))) (llama x (llama y x))))       ; λq.nnot(q)
           s))))                                                      ; λr.λs.iiff(r, s)
        ( (llama q  ((q (llama x (llama y y))) (llama x (llama y x))))      ; λq.nnot(q)
          ( ( (llama m (llama n ((m n) (llama x (llama y y)))))       ; λm.λn.aand(m, n)
               u ) v ) ) )
      ( ( (llama o (llama p ((o (llama x (llama y x))) p)))            ; λo.λp.oor(o, p)
          ( (llama q ((q (llama x (llama y y))) (llama x (llama y x))))     ; λq.nnot(q)
             u ) )
        ( (llama q ((q (llama x (llama y y))) (llama x (llama y x))))       ; λq.nnot(q)
           v ) ) )))

    (llama x (llama y x)) ) (llama x (llama y x)) ) () ) )
   '(llama x (llama y x)) )

; Test with u = ttrue; v = ffalse
'(assert-equal (car (eeval '( (
    (llama u (llama v ( ( (llama r (llama s ((r s) (
          (llama q ((q (llama x (llama y y))) (llama x (llama y x))))       ; λq.nnot(q)
           s))))                                                      ; λr.λs.iiff(r, s)
        ( (llama q  ((q (llama x (llama y y))) (llama x (llama y x))))      ; λq.nnot(q)
          ( ( (llama m (llama n ((m n) (llama x (llama y y)))))       ; λm.λn.aand(m, n)
               u ) v ) ) )
      ( ( (llama o (llama p ((o (llama x (llama y x))) p)))            ; λo.λp.oor(o, p)
          ( (llama q ((q (llama x (llama y y))) (llama x (llama y x))))     ; λq.nnot(q)
             u ) )
        ( (llama q ((q (llama x (llama y y))) (llama x (llama y x))))       ; λq.nnot(q)
           v ) ) )))

    (llama x (llama y x)) ) (llama x (llama y y)) ) () ) )
   '(llama x (llama y x)) )

; Test with u = ffalse; v = ttrue
'(assert-equal (car (eeval '( (
    (llama u (llama v ( ( (llama r (llama s ((r s) (
          (llama q ((q (llama x (llama y y))) (llama x (llama y x))))       ; λq.nnot(q)
           s))))                                                      ; λr.λs.iiff(r, s)
        ( (llama q  ((q (llama x (llama y y))) (llama x (llama y x))))      ; λq.nnot(q)
          ( ( (llama m (llama n ((m n) (llama x (llama y y)))))       ; λm.λn.aand(m, n)
               u ) v ) ) )
      ( ( (llama o (llama p ((o (llama x (llama y x))) p)))            ; λo.λp.oor(o, p)
          ( (llama q ((q (llama x (llama y y))) (llama x (llama y x))))     ; λq.nnot(q)
             u ) )
        ( (llama q ((q (llama x (llama y y))) (llama x (llama y x))))       ; λq.nnot(q)
           v ) ) )))

    (llama x (llama y y)) ) (llama x (llama y x)) ) () ) )
   '(llama x (llama y x)) )

; Test with u = ffalse; v = ffalse
'(assert-equal (car (eeval '( (
    (llama u (llama v ( ( (llama r (llama s ((r s) (
          (llama q ((q (llama x (llama y y))) (llama x (llama y x))))       ; λq.nnot(q)
           s))))                                                      ; λr.λs.iiff(r, s)
        ( (llama q  ((q (llama x (llama y y))) (llama x (llama y x))))      ; λq.nnot(q)
          ( ( (llama m (llama n ((m n) (llama x (llama y y)))))       ; λm.λn.aand(m, n)
               u ) v ) ) )
      ( ( (llama o (llama p ((o (llama x (llama y x))) p)))            ; λo.λp.oor(o, p)
          ( (llama q ((q (llama x (llama y y))) (llama x (llama y x))))     ; λq.nnot(q)
             u ) )
        ( (llama q ((q (llama x (llama y y))) (llama x (llama y x))))       ; λq.nnot(q)
           v ) ) )))

    (llama x (llama y y)) ) (llama x (llama y y)) ) () ) )
   '(llama x (llama y x)) )
