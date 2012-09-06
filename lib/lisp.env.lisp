(and            (lambda (x y) (cond (x y) (t ()))))


; append: Simpler non-tail-recursive version:
; (label append (lambda (x y) (cond
;     ((null x) y)
;     ( t      (cons (car x) (append (cdr x) y))) )))
; append: More complex tail-recursive version:
(append         (lambda (x y) (
    (label append-rev (lambda (xr x y) (cond 
        ((null x) (
            (label append-cons (lambda (xr y) (cond
                ((null xr) y)
                ( t       (append-cons (cdr xr) (cons (car xr) y))) )))
             xr y ))
        ( t       (append-rev (cons (car x) xr) (cdr x) y)) )))
    () x y)))


(assoc          (label assoc    (lambda (x y) (cond
    ((null y) ())
    ((eq x (caar y)) (cadar y))
    ( t              (assoc x (cdr y))) ))))


(caar           (lambda (x) (car (car x))))                 ; x[0,0]
(cadar          (lambda (x) (car (cdr (car x)))))           ; x[0,1]
(caddar         (lambda (x) (car (cdr (cdr (car x))))))     ; x[0,2]
(cadr           (lambda (x) (car (cdr x))))                 ; x[1]
(caddr          (lambda (x) (car (cdr (cdr x)))))           ; x[2]


; A funarg device.
; Not authentic Lisp 1. Possibly Lisp 1.5. Definitely Scheme-ish.
; params: x, expression (symbol) to find
;         a, list of assoc lists, most recent first, minimally: (())
; return:  car: an assoc list in a that has key x, if any; or else ()
;         cadr: the value for x in that assoc list, if any; or else ()
(env-find       (label env-find (lambda (x a) (cond
    ((null x) (list () ()))
    ((atom a) (list () ()))
    ( t       (
        (lambda (alist-value) (cond
            ((cadr alist-value)  alist-value)
            ( t                 (env-find x (cdr a))) ))
        (
            (label env-assoc (lambda (x y) (cond
                ((null y)           (list () ()))
                ((eq x (caar y))    (list y (cadar y)))
                ( t                 (env-assoc x (cdr y))) )))
             x (car a) ) )) ))))


; params: x, expression to evaluate
;         a, list of assoc lists, most recent first, minimally: (())
; return: reduced expression; hang or crash, if x is too deeply recursive
(eval           (label eval (lambda (x a) (cond
    ((null x) ())
    ((atom x) (
        (lambda (alist-value) (cond
           ((null (car alist-value))    x)
           ( t                         (cadr alist-value)) ))
        (env-find x a) ))
    ((atom (car x)) (cond
        ((eq (car x) 'quote) (cadr x))
        ((eq (car x) 'atom) (atom (eval (cadr x) a)))
        ((eq (car x) 'car) (car (eval (cadr x) a)))
        ((eq (car x) 'cdr) (cdr (eval (cadr x) a)))
        ((eq (car x) 'cons) (cons (eval (cadr x) a) (eval (caddr x) a)))
        ((eq (car x) 'eq) (eq (eval (cadr x) a) (eval (caddr x) a)))
        ((eq (car x) 'cond) (
            (lambda (pairs) (cond
                ((null pairs) ())  ; standard?
                ((eval (caar pairs) a)
                    (eval (cadar pairs) a))
                ( t
                    (eval (cons 'cond (cdr pairs)) a))
            ))
            (cdr x) ))
        ( t (eval (cons (cadr (env-find (car x) a)) (cdr x)) a)) ))
    ((eq (caar x) 'lambda)
     (eval (caddar x) (cons (pair (cadar x) (
        (label evlis (lambda (x a) (cond
            ((null x)   ())
            ( t         (cons (eval (car x) a) (evlis (cdr x) a))) )))
        (cdr x) a )) a)) )
    ((eq (caar x) 'label)
     (eval (cons (caddar x) (cdr x))
           (cons (cons (list (cadar x) (car x)) ()) a) ) ) ))))


; really a pair, but we Lispers have used that name for a different function
(list           (lambda (x y) (cons x (cons y ()))))  


(not            (lambda (x) (cond (x ()) (t t))))


(null           (lambda (x) (eq x ())))


; pair: actually, more like Python "zip"
; pair: Simpler non-tail-recursive version:
; (label pair (lambda (x y) (cond
;     ((null x) ())
;     ((null y) ())
;     ( t       (cons (list (car x) (car y)) (pair (cdr x) (cdr y)))) )))
; pair: More complex tail-recursive version:
(pair           (lambda (x y) (
    (label pair-rec (lambda (x y r) (cond
        (   (cond ((null x) t) (t (null y ())))
            (   (label pair-rev (lambda (f r) (cond
                    ((null r) f)
                    ( t      (pair-rev (cons (car r) f) (cdr r))) )))
                () r) )
        (    t
            (pair-rec (cdr x) (cdr y) (cons (list (car x) (car y)) r)) ) )))
    x y () )))

