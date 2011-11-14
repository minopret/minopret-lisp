; Not-particularly-pretty printing of expressions
; Intended to replace Python module "mnpexpr.py" of mnplisp interpreter,
; eventually.
; Aaron Mansheim, October 2011


; "map-reduce":
; Depth-first traversal of list x, applying f to each atom including ()
; and applying g to the results of processing each cons cell.
; This is WAY too complicated considering that I already implemented
; fold-left and fold-right.
;(dft (lambda (x f g) (
    ;(label dft-rec (lambda (x cmd result p) (cond
        ;((atom x) (cond
            ;((eq cmd 'down) (f x))
            ;((eq cmd 'left) (dft-rec (f x) 'up () p)
            ;((eq cmd 'right)
            ;((eq cmd 'up)
        ;((eq cmd 'down) (dft-rec (car x) 'left () (cons (cdr x) p)))
        ;((eq cmd 'left) (dft-rec x 'down () p))
        ;( t (g left x)) )))
    ;x 'down () ()
    ;)) ))) )))


; This will have to do a left-to-right depth-first traversal of the tree.
; params: x, a list
; return: 
'(expr->str (label expr->str (lambda (x) (
    (label expr->str-rec (lambda (xr x parent) (cond ))))))
        ;((null xr) (expr->str-rec 


'(
        ; Case: null
        ((null xr) (append '(= 2 8 = 2 9) x))
        ; Case: non-null atom
        ((atom xr) (append (atom->str xr) x))
        ; Case: non-null list; either length is not 2, or car is not quote
        ((or (null (cdr xr)) (or
             (and (null (cddr xr)) (not (eq (car xr) 'quote)))
             (not (null (cddr xr))) ) )



         (append '(= 2 8)  ; left parenthesis
                  (append (append (expr->str (car x))
                                  (exprs->spcstr (cdr x)) )  ; near-miss tail call
                         '(= 2 9) ) ) )  ; right parenthesis
        (   t  ; Case: non-null list; length is 2 and car is quote
            (expr->str-rec (cdr xr) (append
                '(= 2 7)  ; apostrophe
                 (append (expr->str (cadar x))
                    )  ; not a proper tail call
        ) ) )))
'((((
    (reverse x) () () ))) )

(exprs->spcstr (lambda (x) (
    (label exprs->spcstr-rec (lambda (xr x) (cond
        ((null xr) x)
        ( t (exprs->spcstr-rec (cdr xr) (append
            '(= 2 0)
             (append (expr->str (car xr))
                      x) ))) )))
    (reverse x) () )))

; I'm not sure what the idiomatic plan to print atoms in Lisp
; will be until instantiating an atom will automatically create a
; property that spells the atom's name.
(atom->str (lambda (x) (or (assoc x '(
    (and    (a n d))        (append (a p p e n d))  (assoc  (a s s o c))
    (list   (l i s t))      (not    (n o t))        (null   (n u l l))
    (pair   (p a i r))      (trace  (t r a c e))    (cond   (c o n d))
    (label  (l a b e l))    (lambda (l a m b d a))  (atom   (a t o m))
    (car    (c a r))        (cdr    (c d r))        (cond   (c o n d))
    (cons   (c o n s))      (eq     (e q))          (quote  (q u o t e))
    (cadr   (c a d r))      (cddr   (c d d r))      (caar   (c a a r))
    (cdar   (c d a r))      (caaar  (c a a a r))    (caadr  (c a a d r))
    (cadar  (c a d a r))    (caddr  (c a d d r))    (cdaar  (c d a a r))
    (cdadr  (c d a d r))    (cddar  (c d d a r))    (cdddr  (c d d d r))
    (equal  (e q u a l))    (or     (o r))          

    (assert-equal   (a s s e r t - e q u a l))
    (assoc-equal    (a s s o c - e q u a l))
    (fold-left      (f o l d - l e f t))
    (fold-right     (f o l d - r i g h t))
    (merge-sort     (m e r g e - s o r t))
    (reverse        (r e v e r s e))
    (rotate-right   (r o t a t e - r i g h t))
    (transpose      (t r a n s p o s e))
    )) '(< a t o m >))))
