;Python def and_(x, y): return (y if x else False)
(label and ( lambda (x y) (cond (x (cond (y t) (t ()))) (t ())) ))

;Python def append_(x, y): return tuple(list(x) + list(y))
(label append ( lambda (x y) (cond ((null x) y) (t (cons (car x) (append (cdr x) y))) )))

;Python def assoc_(x, y): return dict(y)[x]
(label assoc ( lambda (x y) (cond ((eq x (caar y)) (cadar y)) (t (assoc x (cdr y)))) ))

;Python def caar_(x): return x[0][0]
(label caar ( lambda (x) (car (car x)) ))

;Python def cadar_(x): return x[0][1]
(label cadar ( lambda (x) (car (cdr (car x))) ))

;Python def caddar_(x): return x[0][2]
(label caddar ( lambda (x) (car (cdr (cdr (car x)))) ))

;Python def caddr_(x): return x[2]
(label caddr ( lambda (x) (car (cdr (cdr x))) ))

;Python def cadr_(x): return x[1]
(label cadr ( lambda (x) (car (cdr x)) ))

;Python def list_(*x): return tuple(x)
(label list ( lambda (x y) (cons x (cons y ())) ))

;Python def not_(x): return not x
(label not ( lambda (x) (cond (x ()) (t t)) ))

;Python def null_(x): return x == ()
(label null ( lambda (x) (eq x ()) ))

;Python def pair_(x, y): return zip(x, y)
(label pair ( lambda (x y) (cond ((null (cdr x)) (list (car x) (car y)))
                                 (    t    (cons (list (car x) (car y)) (pair (cdr x) (cdr y)))) )))

