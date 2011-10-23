; Functions on fixed-size input:
;      bit^4->hex    base64^2->hex^3  quoted-printable->hex^2*pushback
; hex->bit^4  hex^3->base64^2  hex^2->quoted-printable  hex->bit^4 (full circle)
;
; Functions on variable-size input:
;      bits->hex  base64->hex  quoted-printable->hex
; hex->bits  hex->base64  hex->quoted-printable  hex->bits
;
; Current limits: 31 ASCII chars, 62 hex digits
; Planned limits: Very relaxed, if I implement proper tail recursion.
;
; Aaron Mansheim, 2011-10-15


; Convert one hexadecimal digit to four binary digits,
; most significant bit first.
(label hex->bit^4 (lambda (d) (assoc d
    '((0 (() () () ()))  (1 (() () ()  t))  (2 (() ()  t ()))  (3 (() ()  t  t))
      (4 (()  t () ()))  (5 (()  t ()  t))  (6 (()  t  t ()))  (7 (()  t  t  t))
      (8 ( t () () ()))  (9 ( t () ()  t))  (A ( t ()  t ()))  (B ( t ()  t  t))
      (C ( t  t () ()))  (D ( t  t ()  t))  (E ( t  t  t ()))  (F ( t  t  t  t)) ) )))

(label hex->bits (lambda (u) (cond
    ((null u) ())
    (      t  (append (hex->bit^4 (car u)) (hex->bits (cdr u)))) )))

; params: d, a hex digit
; return: list of two base-4 (quaternary) digits
(label hex->quater^2 (lambda (d) (assoc d
    '((0 (0 0))  (1 (0 1))  (2 (0 2))  (3 (0 3))
      (4 (1 0))  (5 (1 1))  (6 (1 2))  (7 (1 3))
      (8 (2 0))  (9 (2 1))  (A (2 2))  (B (2 3))
      (C (3 0))  (D (3 1))  (E (3 2))  (F (3 3)) ) )))

; params: x and y, two base-4 (quaternary) digits
; return: a hex digit
(label quater^2->hex (lambda (x y) (assoc-equal (list x y)
    '(((0 0) 0)  ((0 1) 1)  ((0 2) 2)  ((0 3) 3)
      ((1 0) 4)  ((1 1) 5)  ((1 2) 6)  ((1 3) 7)
      ((2 0) 8)  ((2 1) 9)  ((2 2) A)  ((2 3) B)
      ((3 0) C)  ((3 1) D)  ((3 2) E)  ((3 3) F) ) )))

; Clever variant
;(label quater^2->hex (lambda (x y) (
;    (assoc x '((0 bit^2->quater) (1 bit^2+4->hex)
;               (2 bit^2+8->hex ) (3 bit^2+C->hex) ))
;    (quater->bit^2 y) )))

; Convert four binary digits, most significant bit first,
; to one hexadecimal digit.
(label bit^4->hex (lambda (x) (
    (cond ((car x) (cond ((cadr x) bit^2+C->hex) (t bit^2+8->hex)))
          (     t  (cond ((cadr x) bit^2+4->hex) (t bit^2->quater))) )
    (cddr x) )))

(label bits->hex (lambda (u) (cond
    ((null u) ())

    ; These three cases shouldn't happen
    ((null (cdr u)) (bit^4->hex (append (list () ()) (list () (car u)))))
    ((null (cddr u)) (bit^4->hex (append (list () ())
                                         (list (car u) (cadr u)) )))
    ((null (cdddr u)) (bit^4->hex (append (list () (car u))
                                          (list (cadr u) (caddr u)) )))

    (             t   (append (bit^4->hex (append (list (car u) (cadr u))
                                                  (list (caddr u)
                                                        (cadddr u) ) ))
                              (bits->hex (cddddr u)) )) )))

(label bit^2+C->hex (
    lambda (x) (cond ((car x) (cond ((cadr x) 'F) (t 'E))) ((cadr x) 'D) (t 'C)) ))

(label bit^2+8->hex (
    lambda (x) (cond ((car x) (cond ((cadr x) 'B) (t 'A))) ((cadr x) '9) (t '8)) ))

(label bit^2+4->hex (
    lambda (x) (cond ((car x) (cond ((cadr x) '7) (t '6))) ((cadr x) '5) (t '4)) ))

(label bit^2->quater (
    lambda (x) (cond ((car x) (cond ((cadr x) '3) (t '2))) ((cadr x) '1) (t '0)) ))

(label quater->bit^2 (lambda (x) (assoc x '((0 (() ())) (1 (()  t)) (2 ( t ())) (3 ( t  t))))))

; Base64 encoding RFC 1421
; params: x, y, and z, three hex digits
; return: list of two base64 digits
(label hex^3->base64^2 (lambda (x y z) (
    quater^2*3->base64^2 (hex->quater^2 x) (hex->quater^2 y) (hex->quater^2 z) )))

; params: u, a list of hex digits
; return: list of base64 digits
(label hex->base64 (lambda (u) (cond
    ((null u) ())
    ((null (cdr u)) (hex^3->base64^2 '0 '0 (car u)))  ; shouldn't happen
    ((null (cddr u)) (hex^3->base64^2 '0 (car u) (cadr u)))  ; shouldn't happen
    (             t  (append (hex^3->base64^2 (car u) (cadr u) (caddr u))
                             (hex->base64 (cdddr u)) )) )))

; params: x, y, and z, three pairs of base-4 (quaternary) digits
; return: list of two base64 digits
(label quater^2*3->base64^2 (lambda (x y z) (list
    (quater^3->base64 (car  x) (cadr x) (car  y))
    (quater^3->base64 (cadr y) (car  z) (cadr z)) )))

; params: x and y, two base64 digits
; return: list of three hex digits
(label base64^2->hex^3 (
    lambda (x y) (quater^6*1->hex^3 (append (base64->quater^3 x)
                                            (base64->quater^3 y) )) ))

; params: u, a list of six base-4 (quaternary) digits
; return: list of three hex digits
(label quater^6*1->hex^3 (lambda (u) (cons
    (quater^2->hex (car u) (cadr u))
    (list (quater^2->hex (caddr u) (cadddr u))
          (quater^2->hex (car (cddddr u)) (cadr (cddddr u))) ) )))

(label base64->hex (lambda (u) (cond
    ((null u) ())
    ((null (cdr u)) (base64^2->hex^3 'A (car u)))  ; shouldn't happen
    (            t  (append (base64^2->hex^3 (car u) (cadr u))
                            (base64->hex (cddr u)) )) )))

(label base64->quater^3 (lambda (x) (assoc x '(
(A (0 0 0)) (B (0 0 1)) (C (0 0 2)) (D (0 0 3))
(E (0 1 0)) (F (0 1 1)) (G (0 1 2)) (H (0 1 3))
(I (0 2 0)) (J (0 2 1)) (K (0 2 2)) (L (0 2 3))
(M (0 3 0)) (N (0 3 1)) (O (0 3 2)) (P (0 3 3))
(Q (1 0 0)) (R (1 0 1)) (S (1 0 2)) (T (1 0 3))
(U (1 1 0)) (V (1 1 1)) (W (1 1 2)) (X (1 1 3))
(Y (1 2 0)) (Z (1 2 1)) (a (1 2 2)) (b (1 2 3))
(c (1 3 0)) (d (1 3 1)) (e (1 3 2)) (f (1 3 3))
(g (2 0 0)) (h (2 0 1)) (i (2 0 2)) (j (2 0 3))
(k (2 1 0)) (l (2 1 1)) (m (2 1 2)) (n (2 1 3))
(o (2 2 0)) (p (2 2 1)) (q (2 2 2)) (r (2 2 3))
(s (2 3 0)) (t (2 3 1)) (u (2 3 2)) (v (2 3 3))
(w (3 0 0)) (x (3 0 1)) (y (3 0 2)) (z (3 0 3))
(0 (3 1 0)) (1 (3 1 1)) (2 (3 1 2)) (3 (3 1 3))
(4 (3 2 0)) (5 (3 2 1)) (6 (3 2 2)) (7 (3 2 3))
(8 (3 3 0)) (9 (3 3 1)) (+ (3 3 2)) (/ (3 3 3))
))))

; params: x, y, and z, three base-4 (quaternary) digits
; return: a base64 digit
(label quater^3->base64 (lambda (x y z) (assoc z (assoc y (assoc x '(
    (0 ((0 ((0 A) (1 B) (2 C) (3 D))) (1 ((0 E) (1 F) (2 G) (3 H)))
        (2 ((0 I) (1 J) (2 K) (3 L))) (3 ((0 M) (1 N) (2 O) (3 P))) ))
    (1 ((0 ((0 Q) (1 R) (2 S) (3 T))) (1 ((0 U) (1 V) (2 W) (3 X)))
        (2 ((0 Y) (1 Z) (2 a) (3 b))) (3 ((0 c) (1 d) (2 e) (3 f))) ))
    (2 ((0 ((0 g) (1 h) (2 i) (3 j))) (1 ((0 k) (1 l) (2 m) (3 n)))
        (2 ((0 o) (1 p) (2 q) (3 r))) (3 ((0 s) (1 t) (2 u) (3 v))) ))
    (3 ((0 ((0 w) (1 x) (2 y) (3 z))) (1 ((0 0) (1 1) (2 2) (3 3)))
        (2 ((0 4) (1 5) (2 6) (3 7))) (3 ((0 8) (1 9) (2 +) (3 /))) )) ))))))

(label hex^2->quoted-printable (lambda (x y) (assoc y (cond
    ((eq x '2) '((0 (= 2 0))
                         (1 (!)) (2 ("))    ;")) This comment balances hiliting.
                                         (3 (#)) (4 ($)) (5 (%)) (6 (&)) (7 ('))
                 (8 (= 2 8)) (9 (= 2 9))
                                 (A (*)) (B (+)) (C (,)) (D (-)) (E (.)) (F (/)) ))
    ((eq x '3) '((0 (0)) (1 (1)) (2 (2)) (3 (3)) (4 (4)) (5 (5)) (6 (6)) (7 (7))
                 (8 (8)) (9 (9)) (A (:)) (B (= 3 B))
                                                 (C (<)) (D (= 3 D))
                                                                 (E (>)) (F (?)) ))
    ((eq x '4) '((0 (@)) (1 (A)) (2 (B)) (3 (C)) (4 (D)) (5 (E)) (6 (F)) (7 (G))
                 (8 (H)) (9 (I)) (A (J)) (B (K)) (C (L)) (D (M)) (E (N)) (F (O)) ))
    ((eq x '5) '((0 (P)) (1 (Q)) (2 (R)) (3 (S)) (4 (T)) (5 (U)) (6 (V)) (7 (W))
                 (8 (X)) (9 (Y)) (A (Z)) (B ([)) (C (\)) (D (])) (E (^)) (F (_)) ))
    ((eq x '6) '((0 (`)) (1 (a)) (2 (b)) (3 (c)) (4 (d)) (5 (e)) (6 (f)) (7 (g))
                 (8 (h)) (9 (i)) (A (j)) (B (k)) (C (l)) (D (m)) (E (n)) (F (o)) ))
    ((eq x '7) '((0 (p)) (1 (q)) (2 (r)) (3 (s)) (4 (t)) (5 (u)) (6 (v)) (7 (w))
                 (8 (x)) (9 (y)) (A (z)) (B ({)) (C (|)) (D (})) (E (~)) (F (= 7 F)) ))
    (       t  (cons '= (list x y))) ))))

(label hex->quoted-printable (lambda (u) (cond
    ((null u) ())
    ((null (cdr u)) (hex^2->quoted-printable '0 (car u)))  ; shouldn't happen
    (            t  (append (hex^2->quoted-printable (car u) (cadr u))
                            (hex->quoted-printable (cddr u)) )) )))

; Just put nils in y and z if there aren't enough tokens left.
(label quoted-printable->hex^2*pushback (lambda (x y z) (cond
    ((eq x '=) (cons y (list z ())))
    (t (append
        (assoc x '(     ; characters intentionally omitted: SPACE PARENS SEMICOLON EQUAL (and 7F)
                      (! (2 1)) (" (2 2))   ;") This comment balances hiliting.
                                          (# (2 3)) ($ (2 4)) (% (2 5)) (& (2 6)) (' (2 7))
                                (* (2 A)) (+ (2 B)) (, (2 C)) (- (2 D)) (. (2 E)) (/ (2 F))
            (0 (3 0)) (1 (3 1)) (2 (3 2)) (3 (3 3)) (4 (3 4)) (5 (3 5)) (6 (3 6)) (7 (3 7))
            (8 (3 8)) (9 (3 9)) (: (3 A))           (< (3 C))           (> (3 E)) (? (3 F))
            (@ (4 0)) (A (4 1)) (B (4 2)) (C (4 3)) (D (4 4)) (E (4 5)) (F (4 6)) (G (4 7))
            (H (4 8)) (I (4 9)) (J (4 A)) (K (4 B)) (L (4 C)) (M (4 D)) (N (4 E)) (O (4 F))
            (P (5 0)) (Q (5 1)) (R (5 2)) (S (5 3)) (T (5 4)) (U (5 5)) (V (5 6)) (W (5 7))
            (X (5 8)) (Y (5 9)) (Z (5 A)) ([ (5 B)) (\ (5 C)) (] (5 D)) (^ (5 E)) (_ (5 F))
            (` (6 0)) (a (6 1)) (b (6 2)) (c (6 3)) (d (6 4)) (e (6 5)) (f (6 6)) (g (6 7))
            (h (6 8)) (i (6 9)) (j (6 A)) (k (6 B)) (l (6 C)) (m (6 D)) (n (6 E)) (o (6 F))
            (p (7 0)) (q (7 1)) (r (7 2)) (s (7 3)) (t (7 4)) (u (7 5)) (v (7 6)) (w (7 7))
            (x (7 8)) (y (7 9)) (z (7 A)) ({ (7 B)) (| (7 C)) (} (7 D)) (~ (7 E))           ))
        (cons (list y z) ()) )) )))

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
