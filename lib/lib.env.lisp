; Library functions for elementary pure Lisp.
; Aaron Mansheim 2011-10-01
;
; Functions in this library so far:
;
; assert-equal
; assoc-equal
; cxxr
; cxxxr
; cxxxxr
; equal
; fold-left
; fold-right
; merge-sort
; or
; reverse
; rotate-right
; transpose


; Standard: none. Roughly similar functionality to lisp-unit.
(assert-equal   (lambda (x y) (cond
    ((equal x y) t)
    (         t (cons 'Expecting (cons y (list 'found x)))) )))


; Some day this and assoc could benefit from using a self-balancing tree,
; a sorted sequence offering its length and binary search using unrolled loops,
; a hash function, whatever.
; Standard: Common Lisp.
(assoc-equal    (label assoc-equal (lambda (x a) (cond
    ((equal x (caar a)) (cadar a))
    (               t   (assoc-equal x (cdr a))) ))))


; The rest of cxxr, cxxxr, cxxxxr, with notes on what they do
; (in Pascal-ish syntax).
;car                                                    ; x[0]
;caar                                                   ; x[0,0]
(caaar          (lambda (x) (car (car (car x)))))       ; x[0,0,0]
(caaaar         (lambda (x) (car (car (car (car x)))))) ; x[0,0,0,0]
(cdaaar         (lambda (x) (cdr (car (car (car x)))))) ; x[0,0,0,1..]
(cadaar         (lambda (x) (car (cdr (car (car x)))))) ; x[0,0,1]
(cdaar          (lambda (x) (cdr (car (car x)))))       ; x[0,0,1..]
(cddaar         (lambda (x) (cdr (cdr (car (car x)))))) ; x[0,0,2..]
;cadar                                                  ; x[0,1]
(cdar           (lambda (x) (cdr (car x))))             ; x[0,1..]
(caadar         (lambda (x) (car (car (cdr (car x)))))) ; x[0,1,0]
(cdadar         (lambda (x) (cdr (car (cdr (car x)))))) ; x[0,1,1..]
;caddar                                                 ; x[0,2]
(cddar          (lambda (x) (cdr (cdr (car x)))))       ; x[0,2..]
(cdddar         (lambda (x) (cdr (cdr (cdr (car x)))))) ; x[0,3..]
;cadr                                                   ; x[1]
;cdr                                                    ; x[1..]
(caadr          (lambda (x) (car (car (cdr x)))))       ; x[1,0]
(caaadr         (lambda (x) (car (car (car (cdr x)))))) ; x[1,0,0]
(cdaadr         (lambda (x) (cdr (car (car (cdr x)))))) ; x[1,0,1..]
(cdadr          (lambda (x) (cdr (car (cdr x)))))       ; x[1,1..]
(cadadr         (lambda (x) (car (cdr (car (cdr x)))))) ; x[1,1]
(cddadr         (lambda (x) (cdr (cdr (car (cdr x)))))) ; x[1,2..]
;caddr                                                  ; x[2]
(cddr           (lambda (x) (cdr (cdr x))))             ; x[2..]
(caaddr         (lambda (x) (car (car (cdr (cdr x)))))) ; x[2,0]
(cdaddr         (lambda (x) (cdr (car (cdr (cdr x)))))) ; x[2,1..]
(cadddr         (lambda (x) (car (cdr (cdr (cdr x)))))) ; x[3]
(cdddr          (lambda (x) (cdr (cdr (cdr x)))))       ; x[3..]
(cddddr         (lambda (x) (cdr (cdr (cdr (cdr x)))))) ; x[4..]


; Standard: Common Lisp. Probably all Schemes and all Lisps since 1.5.
; equal: Simpler non-tail-recursive version:
;(label equal (lambda (x y) (cond
;    ((atom x) (cond ((and (atom y) (eq x y)) t) (t ())))
;    (      t  (cond
;        ((atom y) ())
;        (t        (and (equal (car x) (car y)) (equal (cdr x) (cdr y)))) )) )))
; equal: More complex tail-recursive version:
(equal          (label equal (lambda (x y) (cond
    ((atom x) (cond ((and (atom y) (eq x y)) t) (t ())))
    ( t       (cond
        ((atom y) ())
        ( t       (
            (label equal-as-cons (lambda (xa xd ya yd) (cond
                ((null xd)     (and (null yd) (equal xa ya)))
                ((null yd)     ())
                ((equal xa ya) (equal-as-cons (car xd) (cdr xd)
                                              (car yd) (cdr yd) ))
                ( t            ()) )))
            (car x) (cdr x) (car y) (cdr y) )) )) ))))


; Here's a quick way to generalize many binary operations to n-ary operations.
; Standard: Scheme programming language "fold-left" and "fold-right".
(fold-left      (label fold-left (lambda (f z u) (cond
    ((null u)           z)
    ((atom u)          (f z u))  ; I'm guessing that this is a good choice.
    ((null    (cdr u)) (f z (car u)))
    ( t                (fold-left f (f z (car u)) (cdr u))) ))))


(fold-right     (label fold-right (lambda (f z u) (fold-left
    (cons 'lambda (list '(y x) (cons f '(x y))))
     z
    (reverse u) ))))


; map...


; This merge-sort and its helper merge-sort-merge are not yet tested.
(merge-sort     (lambda (x order) (
    (label merge-sort-split (lambda (x x1 x2 order) (cond
        ((null x)       (merge-sort-merge ()               x1  x2 order))
        ((null (cdr x)) (merge-sort-merge () (cons (car x) x1) x2 order))
        ( t             (merge-sort-split (cdr (cdr x))
                                          (cons (car x) x1)
                                          (cons (cadr x) x2)
                                           order )) )))
     x () () order )))


(merge-sort-merge   (label merge-sort-merge (lambda (s x y order) (cond
    ((null x) (append (reverse y) s))
    ((null y) (append (reverse x) s))
    (      t  (cond 
        ((order (car x) (car y))
         (merge-sort-merge (cons (car x) s) (cdr x) y order))
        ( t
         (merge-sort-merge (cons (car y) s) x (cdr y) order)) )) ))))


(or             (lambda (x y) (cond (x x) (t y))))


(reverse        (lambda (x) (
    (label reverse-rec (lambda (xr x) (cond
        ((null x) xr)
        ((atom x) x)
        (t (reverse-rec (cons (car x) xr) (cdr x))) )))
    () x )))


(rotate-right   (lambda (x) ( 
    (lambda (xr) (cond ((atom xr) xr) (t (cons (car xr) (reverse (cdr xr))))))
    (reverse x) )))


; Should be able to write more simply using fold-left.
; Anyway, this implementation is debugged.
(transpose      (lambda (m) (
    (label transpose_rec (lambda (mr mt) (cond
        ((null mr)  mt)
        ((null mt) (
            (label transpose_first (lambda (rr mrs rt) (cond
                ((null rr) (transpose_rec mrs rt))
                ( t        (transpose_first (cdr rr) mrs (cons (cons (car rr) ()) rt))) )))
            (reverse (car mr)) (cdr mr) () ))
        ( t        (
            (label transpose_next (lambda (rr mrs mtr mtl) (cond
                ((null rr) (transpose_rec mrs mtl))
                ( t        (transpose_next (cdr rr) mrs (cdr mtr) (cons (cons (car rr) (car mtr)) mtl) )) )))
            (reverse (car mr)) (cdr mr) (reverse mt) () )) )))
    (reverse m) () )))
