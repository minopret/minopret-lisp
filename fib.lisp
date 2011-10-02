(label fib (lambda (n) (cond
    ; TODO preclude n < 0
    ((equal n '(0)) '(0))
    (            t   (fib_n n '(0) '(+))) )))

(label fib_n (lambda (k fibn-k fibn-k+1) (cond
    ((equal k '(+)) fibn-k+1)
    (            t  (fib_n (bal3_add k '(-)) fibn-k+1 (bal3_add fibn-k fibn-k+1)))
    )))
