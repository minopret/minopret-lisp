(label fact (lambda (n) (cond
    ; TODO preclude n < 0
    ((equal n '(0)) '(+))
    (            t  (fact_n n '(+))) )))

(label fact_n (lambda (k fact_n-k) (cond
    ((equal k '(0)) fact_n-k)
    (            t  (fact_n (bal3_add k '(-)) (bal3_mult k fact_n-k))) )))
