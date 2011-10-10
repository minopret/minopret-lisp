; Library functions for elementary pure Lisp.
; Aaron Mansheim 2011-10-01
;
; Functions in this library so far:
;
; assert-equal
; assoc-equal
; equal
; fold-left
; merge-sort
; reverse
; rotate-right

; Standard: Common Lisp. Probably all Schemes and all Lisps since 1.5.
(label equal (lambda (x y) (cond
    ((atom x) (cond ((and (atom y) (eq x y)) t) (t ())))
    (t (cond ((atom y) ())
             (t (and (equal (car x) (car y)) (equal (cdr x) (cdr y)))) )) )))

; Standard: none. Roughly similar functionality to lisp-unit.
(label assert-equal (lambda (x y) (cond
    ((equal x y) t)
    (t (append (list 'Expecting y) (list 'found x))) )))





; Here's a quick way to generalize binary operations to n-ary operations.
; Standard: Scheme programming language "fold".
; This is not yet tested.
(label fold-left (lambda (f z u) (cond
    ((null u) z)
    ((atom u) (f z u))  ; I'm only supposing that this is a good choice.
    ((null (cdr u)) (f z (car u)))
    (            t  (fold-left (f z (car u)) (cdr u))) )))

; Some day this and assoc could benefit from using a self-balancing tree,
; a sorted sequence offering its length and binary search using unrolled loops,
; a hash function, whatever.
; Standard: Common Lisp.
; This is not yet tested.
(label assoc-equal (lambda (x a) (cond (
    ((equal x (caar a)) (cadar a))
    (                t  (assoc-equal x (cdr a))) ))))

; This reverse and its helper are not yet tested.
(label reverse (lambda (x) (reverse1 x ())))

(label reverse1 (lambda (x xrev) (cond
    ((atom x) xrev)
    (t (reverse1 (cdr x) (cons (car x) xrev))) )))

; This is not yet tested.
(label rotate-right (lambda (x) ( 
    (lambda (xr) (cons (car xr) (reverse (cdr xr))))
    (reverse x) )))

; This merge-sort and its helpers are not yet tested.
(label merge-sort (lambda (x order) (merge-sort-split x () () order) ))

(label merge-sort-split (lambda (x x1 x2 order) (cond
    ((null x) (merge-sort-merge () x1 x2 order))
    ((null (cdr x)) (merge-sort-merge () (cons (car x) x1) x2 order))
    (t  (merge-sort-split (cdr (cdr x)) (cons (car x) x1)
                                        (cons (cadr x) x2) order)) )))

(label merge-sort-merge (lambda (s x y order) (cond
    ((null x) (append (reverse y) s))
    ((null y) (append (reverse x) s))
    (      t  (cond 
        ((order (car x) (car y))
         (merge-sort-merge (cons (car x) s) (cdr x) y order))
        ( t
         (merge-sort-merge (cons (car y) s) x (cdr y) order)) )) )))

