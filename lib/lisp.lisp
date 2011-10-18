(label and ( lambda (x y) (cond (x (cond (y t) (t ()))) (t ())) ))

(label append ( lambda (x y) (cond ((null x) y) (t (cons (car x) (append (cdr x) y))) )))

(label assoc ( lambda (x y) (cond ((eq x (caar y)) (cadar y)) (t (assoc x (cdr y)))) ))

(label caar ( lambda (x) (car (car x)) ))               ; x[0,0]
(label cadar ( lambda (x) (car (cdr (car x))) ))        ; x[0,1]
(label caddar ( lambda (x) (car (cdr (cdr (car x)))) )) ; x[0,2]
(label cadr ( lambda (x) (car (cdr x)) ))               ; x[1]
(label caddr ( lambda (x) (car (cdr (cdr x))) ))        ; x[2]

(label list ( lambda (x y) (cons x (cons y ())) ))

(label not ( lambda (x) (cond (x ()) (t t)) ))

(label null ( lambda (x) (eq x ()) ))

(label pair ( lambda (x y) (cond ((null (cdr x)) (list (car x) (car y)))
                                 (    t    (cons (list (car x) (car y)) (pair (cdr x) (cdr y)))) )))

