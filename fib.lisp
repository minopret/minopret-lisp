(label fib-bal3 (lambda (n) (cond
    ; TODO preclude n < 0
    ((equal n '(0)) '(0))
    (           t    (fib-bal3-n n '(0) '(+))) )))

(label fib-bin (lambda (n) (cond
    ; TODO preclude n < 0
    ((equal n '(())) '(()))
    (           t    (fib-bin-n n '(()) '(t))) )))


(label fib-bal3-n (lambda (k fibn-k fibn-k+1) (cond
    ((equal k '(+)) fibn-k+1)
    (           t  (fib-bal3-n (bal3-add k '(-))
                                fibn-k+1
                               (bal3-add fibn-k fibn-k+1) )) )))

(label fib-bin-n (lambda (k fibn-k fibn-k+1) (cond
    ((equal k '(t)) fibn-k+1)
    (           t  (fib-bin-n (bin-pred k) fibn-k+1 (bin-add fibn-k fibn-k+1))) )))
