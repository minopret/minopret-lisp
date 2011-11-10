(   (label equal (lambda (x y) (cond
        ((atom x)   (cond ((atom y) (eq x y)) (t ())))
        ((atom y)   ())
        ((equal (car x) (car y))
                    (equal (cdr x) (cdr y)))
        ( t         ()) )))

    (   (label rev (lambda (xr x) (cond
            ((eq x ())  xr)
            ( t        (rev (cons (car x) xr) (cdr x))) )))
        ()
       '(a b c d) )

   '(d c b a) )
