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
    ((null x) (trace '() '21)) ; Naive callers will die but not hang.
    ((atom a) (trace (list () ()) '22))
    ( t       (
        (lambda (alist-value) (cond
            ((cadr alist-value) (trace alist-value '23))
            ( t                 (trace (env-find x (cdr a)) '24)) ))
        (
            (label env-assoc (lambda (x y) (cond
                ((null y)           (trace (list () ()) '25))  ; 25*{23, 24}
                ((eq x (caar y))    (trace (list y (cadar y)) '27))
                  ; 26*{23, 24} (or (atom y) (atom (car y)) (atom (caar y)) (atom (cdar y)))
                  ; 27*{23, 24} (and (not (atom (car y))) (not (atom (cdar y))) (eq x (caar y)))
                ( t                 (trace (env-assoc x (cdr y)) '28)) )))
                  ; Guarded cdr y: Existence of caar y = caaar a implies that of cdr y.
                  ; 28*{23, 24} (not (eq x (caaar a)))
             x (car a) ) )) ))))  ; We guarded against atom a.


; params: x, expression to evaluate
;         a, list of assoc lists, most recent first, minimally: (())
; return: reduced expression; hang or crash, if x is too deeply recursive
(eval           (label eval (lambda (x a) (cond
    ((null x) (trace () '1))
    ((atom x) ( ; symbol? x
        (lambda (alist-value) (cond
           ((null (car alist-value))   (trace x '2))
           ( t                         (trace (cadr alist-value) '3)) ))
        (env-find x a) ))  ; {2, 3}*n
    ((atom (car x)) (cond  ; We guarded against atom x.
        ((eq (car x) 'quote) (trace (cadr x) '4))
        ((eq (car x) 'atom) (trace (atom (eval (cadr x) a)) '5))
        ((eq (car x) 'car) (trace (car (eval (cadr x) a)) '6))
        ((eq (car x) 'cdr) (trace (cdr (eval (cadr x) a)) '7))
        ((eq (car x) 'cons) (trace (cons (eval (cadr x) a) (eval (caddr x) a)) '8))
        ((eq (car x) 'eq) (trace (eq (eval (cadr x) a) (eval (caddr x) a)) '9))
        ((eq (car x) 'cond) (
            (lambda (pairs) (cond
                ((null pairs) (trace () '10))  ; standard? 
                ((eval (caar pairs) a)
                    (trace (eval (cadar pairs) a) '11) )
                ( t
                    (trace (eval (cons 'cond (cdr pairs)) a) '12))
            ))
            (cdr x) ))
        ( t (trace (eval (cons (cadr (env-find (car x) a)) (cdr x)) a) '13)) )) ; {13}*n
    ((eq (caar x) 'lambda)  ; We guarded against atom (car x).
     (eval (caddar x) (cons
        (pair (cadar x) (
            (label evlis-rec (lambda (x a r) (cond
                ((null x) (
                    (label evlis-rev (lambda (f r) (cond
                        ((null r) (trace f '14))
                        ( t (trace
                            (evlis-rev (cons (car r) f) (cdr r))
                            '15 )) )))
                    () r ))
                ( t (trace
                    (evlis-rec (cdr x) a (cons (eval (car x) a) r))
                    '16 )) )))
            (cdr x) a () ))
         a )) )
    ((eq (caar x) 'label)
     (trace (eval (trace (cons (caddar x) (cdr x)) '19)
           (trace (cons (cons (list (cadar x) (car x)) ()) a) '20) ) '17) )
    (t (trace () '18)) ))))


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

