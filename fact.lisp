(label fact-bal3 (lambda (n) (cond
    ; TODO preclude n < 0
    ((equal n '(0)) '(+))
    (           t    (fact-bal3-n n '(+))) )))

(label fact-bal3-n (lambda (k fact-bal3-n-k) (cond
    ((equal k '(0)) fact-bal3-n-k)
    (           t  (fact-bal3-n (bal3-add k '(-)) (bal3-mult k fact-bal3-n-k))) )))

(label fact-bin (lambda (n) (cond
    ; TODO preclude n < 0
    ((equal n '(())) '( t))
    (            t    (fact-bin-n n '( t))) )))

(label fact-bin-n (lambda (k fact-bin-n-k) (cond
    ((equal k '(())) fact-bin-n-k)
    (            t  (fact-bin-n (bin-pred k) (bin-mult k fact-bin-n-k))) )))

