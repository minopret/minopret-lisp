(eval 
    (f (quote (() () ())))
    (quote (
        (f (lambda (x) (cond
            (   (null x)
                (quote (()))    )
            (   (quote t)
                (mult x (cdr x))    )
        )))
        (mult (lambda (x y) (cond
            (   (null x)
                (quote ())  )
            (   (null (cdr x)) y)
                ((quote t) (add (mult (cdr x) y) x) )
        )))
        (add (lambda (x y) (cond
            (   (null y)
                x   )
            (   (quote t)
                (cons (quote ()) (add x (cdr y)))   )
        )))
    ))
)
