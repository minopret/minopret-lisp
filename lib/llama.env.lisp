; llama1
;
; A lambda calculus.
; Based on Scheme code that differs primarily by using
; a dotted list to represent a lambda function,
; at http://matt.might.net/articles/implementing-a-programming-language/
;
; Aaron Mansheim 2011-12-06

(eeval (label eeval (lambda (e env) (cond
    ((atom e) (assoc e env))
    ((eq (car e) 'llama) (cons e env))
    (t (aapply (eeval (car e) env) (eeval (cadr e) env))) ))))

(aapply (lambda (f x)
    (eeval (caddr (car f)) (cons (list (cadr (car f)) x) (cdr f))) ))
