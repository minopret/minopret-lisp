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
; params: x, expression (atom) to find
;         a, list of assoc lists, most recent first
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


; Not yet tested.
; a: list of assoc lists, most recent first
;(label eval     (lambda (x a) (cond
    ;((atom x) (
        ;(lambda (alist-value) (cond
        ;   ((null (car alist-value))    x)
        ;   ( t                         (cadr alist-value)) ))
        ;(env-assoc x a) ))
    ;((atom (car x)) (
        ;((eq (car x) 'quote) (cadr x))
        ;((eq (car x) 'cond) (
            ;(lambda (pairs) (cond
                ;((null pairs) ())  ; standard?
                ;((eval (car pairs) a)
                    ;(eval (cadar pairs) a))
                ;( t
                    ;(eval (cons 'cond (cdr pairs)) a))
            ;))
            ;(cdr x) ))
        ;((quote t) (eval (cons (assoc (car x) a) (cdr x)) a)) ))
    ;((eq (caar x) 'lambda)
    ; (eval (caddar x) (append (pair (cadar x) (evlis (cdr x) a)) a)) )
    ;((eq (caar x) 'label)
    ; (eval (cons (caddar x) (cdr x)) (cons (list (cadar x) (car x)) a)) ) )))


(list           (lambda (x y) (cons x (cons y ()))))


(not            (lambda (x) (cond (x ()) (t t))))


(null           (lambda (x) (eq x ())))


; pair: Simpler non-tail-recursive version:
; (label pair (lambda (x y) (cond
;     ((null x) ())
;     ((null y) ())
;     ( t       (cons (list (car x) (car y)) (pair (cdr x) (cdr y)))) )))
; pair: More complex tail-recursive version:
(pair           (lambda (x y) (cond
    ((null (cdr x)) (list (car x) (car y)) )
    ( t             (
        (label pair-rev (lambda (xr yr x y) (cond
            ((not (and x y)) (
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
