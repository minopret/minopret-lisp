(fib-bal3 (lambda (n) (cond
    ((eq (car n) '-) '(0))  ; just return zero for negative n
    ((equal n '(0)) '(0))
    ( t              (
        (label fib-bal3-n (lambda (k fibn-k fibn-k+1) (cond
            ((equal k '(+)) fibn-k+1)
            ( t            (fib-bal3-n (bal3-add k '(-))
                                        fibn-k+1
                                       (bal3-add fibn-k fibn-k+1) )) )))
         n '(0) '(+) )) )))


(fib-bin (lambda (n) (cond
    ((equal n '(())) '(()))
    ( t              (
        (label fib-bin-n (lambda (k fibn-k fibn-k+1) (cond
            ((equal k '(t)) fibn-k+1)
            ( t            (fib-bin-n (bin-pred k)
                                       fibn-k+1
                                      (bin-add fibn-k fibn-k+1) )) )))
         n '(()) '(t) )) )))
