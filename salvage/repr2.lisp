(

(evlis (lambda (m a) 
(cond
((null m) (quote ())) 
((quote t) (cons (eval (car m) a) (evlis (cdr m) a)))
)
))

(evcon (lambda (c a) 
(cond
((eval (caar c) a) (eval (cadar c) a)) 
((quote t) (evcon (cdr c) a))
)
))

(eval (lambda (e a)
(cond
((atom e) (assoc e a))
((atom (car e))
(cond 
((eq (car e) (quote quote)) (cadr e)) 
((eq (car e) (quote atom)) (atom (eval (cadr e) a))) 
((eq (car e) (quote eq)) (eq (eval (cadr e) a) (eval (caddr e) a))) 
((eq (car e) (quote car)) (car (eval (cadr e) a))) 
((eq (car e) (quote cdr)) (cdr (eval (cadr e) a))) 
((eq (car e) (quote cons)) (cons (eval (cadr e) a) (eval (caddr e) a))) 
((eq (car e) (quote cond)) (evcon (cdr e) a))
((quote t) (eval (cons (assoc (car e) a) (cdr e)) a))
)
) 
((eq (caar e) (quote lambda)) (eval (caddar e) (append (pair (cadar e) (evlis (cdr e) a)) a))) 
((eq (caar e) (quote label)) (eval (cons (caddar e) (cdr e)) (cons (list (cadar e) (car e)) a)))
)
))

(assoc (lambda (x y) 
(cond 
((eq (caar y) x) (cadar y))
((quote t) (assoc x (cdr y)))
)
))

(pair (lambda (x y) 
(cond
((and (null x) (null y)) (quote ()))
((and (not (atom x)) (not (atom y))) (cons (list (car x) (car y)) (pair (cdr x) (cdr y))))
)
))

(append (lambda (x y) 
(cond 
((null x) y) 
((quote t) (cons (car x) (append (cdr x) y)))
)
))

(caddar (lambda (x) (car (cdr (cdr (car x))))))

(cadar (lambda (x) (car (cdr (car x)))))

(caar (lambda (x) (car (car x))))

(caddr (lambda (x) (car (cdr (cdr x)))))

(cadr (lambda (x) (car (cdr x))))

(list (lambda (x y) (cons x (cons y (quote ())))))

(not (lambda (x) 
(cond
(x (quote ())) 
((quote t) (quote t))
)
))

(and (lambda (x y) 
(cond
(x 
(cond
(y (quote t)) 
((quote t) (quote ()))
)
) 
((quote t) (quote ()))
)
))

(null (lambda (x) (eq x (quote ()))))

)
