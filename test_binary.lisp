; Test binary.lisp
;
; Useful functions:
;      bit^4->hex    base64^2->hex^3  quoted-printable->hex^2*pushback
; hex->bit^4  hex^3->base64^2  hex^2->quoted-printable  hex->bit^4 (full circle)
;
; Wanted: functions on arbitrary length input:
;      bits->hex  base64->hex  quoted-printable->hex
; hex->bits  hex->base64  hex->quoted-printable  hex->bits (full circle)

(label qp-data1 '(! " #))   ; "))  This comment preserves hiliting.

(label qp-data2 '(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e))  ; Maximum length within recursion limit.

(label qp-data3 '(= 2 8 l a b e l = 2 0 q p - d a t a 5 = 2 0 ' a = 2 9))

; Entry point.
(label quoted-printable->hex (lambda (x) (qp->hex () x)))

; Push back any deferred tokens and check for termination.
(label qp->hex (lambda (pushback w) (cond
    ((null      pushback)  (cond
        ((null w)        ()                                                                                      )
        ((null (cdr  w)) (qp->hex1 (quoted-printable->hex^2*pushback (car w)        ()              ()      ) ()))
        ((null (cddr w)) (qp->hex1 (quoted-printable->hex^2*pushback (car w)        (cadr w)        ()      ) ()))
        (             t  (qp->hex1 (quoted-printable->hex^2*pushback (car w)        (cadr w)       (caddr w)) (cdddr w))) ))
    ((null (cdr pushback)) (cond
        ((null w)        (qp->hex1 (quoted-printable->hex^2*pushback (car pushback) ()              ()      ) ()))
        ((null (cdr  w)) (qp->hex1 (quoted-printable->hex^2*pushback (car pushback) (car w)         ()      ) ()))
        (             t  (qp->hex1 (quoted-printable->hex^2*pushback (car pushback) (car w)         (cadr w)) (cddr w))) ))
    ( t                    (cond
        ((null w)        (qp->hex1 (quoted-printable->hex^2*pushback (car pushback) (cadr pushback) ()      ) ()))
        (             t  (qp->hex1 (quoted-printable->hex^2*pushback (car pushback) (cadr pushback) (car w) ) (cdr w))) )) )))

; Remove any trailing nils from the pushback list p := caddr hhp.
(label qp->hex1 (lambda (hhp w) (cond
    ; Case len(p) = 0
    ((null           (caddr hhp))  (qp->hex2 (car hhp) (cadr hhp) ()                          w))
    ; Case len(p) = 1
    ((null     (cdr  (caddr hhp))) (cond
        ; Subcase p[0] = nil
        ((null (car  (caddr hhp))) (qp->hex2 (car hhp) (cadr hhp) ()                          w))
        ; Subcase p[0] <> nil
        (                       t  (qp->hex2 (car hhp) (cadr hhp) (cons (car (caddr hhp)) ()) w)) ))
    ; Case len(p) = 2
    ((null     (cddr (caddr hhp))) (cond 
        ; Subcase p[0] = nil. Infer that also p[1] = nil.
        ((null (car  (caddr hhp))) (qp->hex2 (car hhp) (cadr hhp) ()                          w))
        ; Subcase p[0] <> nil /\ p[1] = nil.
        ((null (cadr (caddr hhp))) (qp->hex2 (car hhp) (cadr hhp) (cons (car (caddr hhp)) ()) w))
        ; Subcase p[0] <> nil /\ p[1] <> nil.
        (                       t  (qp->hex2 (car hhp) (cadr hhp) (caddr hhp)                 w)) )) )))

; Take a step, assuming that h1 and h2 are two hex digits; p is a list of 0-2
; pushed-back ASCII printables; and w is a non-empty list of ASCII printables.
(label qp->hex2 (lambda (h1 h2 p w) (append (list h1 h2) (qp->hex p w))))

;(quoted-printable->hex qp-data1)
;(quoted-printable->hex qp-data2)
(quoted-printable->hex qp-data3)
