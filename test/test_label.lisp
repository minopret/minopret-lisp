(   (label rev
        (lambda (xr x) (cond
            ((eq x ())  xr)
            ( t        (rev (cons (car x) xr) (cdr x))) )) )
    ()
   '(a b c d) )
