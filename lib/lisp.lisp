(label and      (lambda (x y) (cond (x y) (t ()))))


; append: Simpler non-tail-recursive version:
; (label append (lambda (x y) (cond
;     ((null x) y)
;     ( t      (cons (car x) (append (cdr x) y))) )))
; append: More complex tail-recursive version:
(label append   (lambda (x y) (
    (label append-rev (lambda (xr x y) (cond 
        ((null x) (
            (label append-cons (lambda (xr y) (cond
                ((null xr) y)
                ( t       (append-cons (cdr xr) (cons (car xr) y))) )))
             xr y ))
        ( t       (append-rev (cons (car x) xr) (cdr x) y)) )))
    () x y)))


(label assoc    (lambda (x y) (cond
    ((null y) ())
    ((eq x (caar y)) (cadar y))
    ( t              (assoc x (cdr y))) )))


(label caar     (lambda (x) (car (car x))))                 ; x[0,0]
(label cadar    (lambda (x) (car (cdr (car x)))))           ; x[0,1]
(label caddar   (lambda (x) (car (cdr (cdr (car x))))))     ; x[0,2]
(label cadr     (lambda (x) (car (cdr x))))                 ; x[1]
(label caddr    (lambda (x) (car (cdr (cdr x)))))           ; x[2]


; eval: meta-circular evaluator goes here


(label list     (lambda (x y) (cons x (cons y ()))))


(label not      (lambda (x) (cond (x ()) (t t))))


(label null     (lambda (x) (eq x ())))


; pair: Simpler non-tail-recursive version:
; (label pair (lambda (x y) (cond
;     ((null x) ())
;     ((null y) ())
;     ( t       (cons (list (car x) (car y)) (pair (cdr x) (cdr y)))) )))
; pair: More complex tail-recursive version:
(label pair     (lambda (x y) (cond
    ((null (cdr x)) (list (car x) (car y)) )
    ( t             (
        (label pair-rev (lambda (xr yr x y) (cond
            ((cond ((null x) t) (t (null y))) (
                (label pair-cons (lambda (xr yr z) (cond
                    ((null xr) z)
                    ( t        (pair-cons (cdr xr)
                                          (cdr yr)
                                          (cons (list (car xr) (car yr)) z) ))
                    )))
                xr yr () ))
            ( t (pair-rev (cons (car x) xr) (cons (car y) yr) (cdr x) (cdr y)))
            ))
        () () x y )) ) )))
