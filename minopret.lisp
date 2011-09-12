; Definitions of Graham-McCarthy style Lisp dumped
; from the initial environment of minopret lisp,
; with semantically insignificant cleanup done by hand.
; Follows Paul Graham, "The Roots of Lisp".
;
; Aaron Mansheim, 2011-09-11
;
; Primitives: atom car cdr cond cons eq quote
;
; Those must be defined by the language interpreter or compiler.
; If you're not sure what they should do, you could do worse
; than to read "The Roots of Lisp".
;
; Note for experts: I'm pleased if you like this, but that's not the point.
;
; Notes for naive people like me:
; * Actually, minopret lisp does not place a period on the end
;   of all these names. That's only to make it possible to load
;   these definitions in some other Lisp and play with them.
; * Actually, "setq" is not implemented as such in minopret lisp.
;   One could form the list of each pair (x y) that appears here as
;   "(setq x y)", then append that list to the second (environment)
;   parameter to eval.
; * Actually, "defun" is not implemented as such in minopret lisp.
;   As in Paul Graham's "The Roots of Lisp", the form "(defun f (x y) fxy)"
;   appears here as shorthand for "(label. f (lambda. (x y) fxy))".
; * Interesting semantics: "defun" allows self-reference while "setq"
;   marks where no self-reference is intended. Note that evcon and
;   evlis also have mutual reference with eval.
; * Primitive "eq" is intentionally not as smart as one may imagine.
;   It only returns t when its arguments are atoms (that are identical).
; * Primitive "cond" is intentionally not as smart as one may imagine.
;   It acts on a condition only if the condition is literally t
;   (the Lisp atom that is interpreted as Boolean "true").

(defun evlis. (m a) (cond ((null. m) (quote ())) ((quote t) (cons (eval. (car m) a) (evlis. (cdr m) a)))))

(defun evcon. (c a) (cond ((eval. (caar. c) a) (eval. (cadar. c) a)) ((quote t) (evcon. (cdr c) a))))

(defun eval. (e a) (cond
    ((atom e) (assoc. e a))
    ((atom (car e)) (cond
        ((eq (car e) (quote quote)) (cadr. e))
        ((eq (car e) (quote atom)) (atom (eval. (cadr. e) a)))
        ((eq (car e) (quote eq)) (eq (eval. (cadr. e) a) (eval. (caddr. e) a)))
        ((eq (car e) (quote car)) (car (eval. (cadr. e) a)))
        ((eq (car e) (quote cdr)) (cdr (eval. (cadr. e) a)))
        ((eq (car e) (quote cons)) (cons (eval. (cadr. e) a) (eval. (caddr. e) a)))
        ((eq (car e) (quote cond)) (evcon. (cdr e) a))
        ((quote t) (eval. (cons (assoc. (car e) a) (cdr e)) a))
    ))
    ((eq (caar. e) (quote lambda.)) (eval. (caddar. e) (append. (pair. (cadar. e) (evlis. (cdr e) a)) a)))
    ((eq (caar. e) (quote label.)) (eval. (cons (caddar. e) (cdr e)) (cons (list. (cadar. e) (car e)) a)))
))

(defun assoc. (x y) (cond ((eq (caar. y) x) (cadar. y)) ((quote t) (assoc. x (cdr y)))))

(defun pair. (x y) (cond ((and. (null. x) (null. y)) (quote ())) ((and. (not. (atom x)) (not. (atom y))) (cons (list. (car x) (car y)) (pair. (cdr x) (cdr y))))))

(defun append. (x y) (cond ((null. x) y) ((quote t) (cons (car x) (append. (cdr x) y)))))

(setq caddar. (lambda. (x) (car (cdr (cdr (car x))))))

(setq cadar. (lambda. (x) (car (cdr (car x)))))

(setq caar. (lambda. (x) (car (car x))))

(setq caddr. (lambda. (x) (car (cdr (cdr x)))))

(setq cadr. (lambda. (x) (car (cdr x))))

(setq list. (lambda. (x y) (cons x (cons y (quote ())))))

(setq not. (lambda. (x) (cond (x (quote ())) ((quote t) (quote t)))))

(setq and. (lambda. (x y) (cond (x (cond (y (quote t)) ((quote t) (quote ())))) ((quote t) (quote ())))))

(setq null. (lambda. (x) (eq x (quote ()))))
