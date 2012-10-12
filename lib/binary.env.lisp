; assumes lib.env.lisp
;
; Functions on fixed-size input (full circle):
;      bit^4->hex    base64^2->hex^3  quoted-printable->hex^2r
; hex->bit^4  hex^3->base64^2  hex^2->quoted-printable  hex->bit^4
;
; bit^2+4->hex bit^2+8->hex bit^2+C->hex
;
;      quater->bit^2        bit^2->quater
;      quater^2->hex        hex->quater^2
;      quater^2*3->base64^2
;      quater^3->base64     base64->quater^3
;      quater^6*1->hex^3
;
; Functions on variable-size input (full circle):
;      bits->hex  base64->hex  quoted-printable->hex
; hex->bits  hex->base64  hex->quoted-printable  hex->bits
;
; Input size limits without tail recursion: 31 ASCII chars, 62 hex digits
; Current limits with tail recursion: roughly, limited by available RAM.
;
; Aaron Mansheim, 2011-10-15


; Convert one hexadecimal digit to four binary digits,
; most significant bit first.
(hex->bit^4 (lambda (d) (assoc d
    '((0 (() () () ())) (1 (() () ()  t)) (2 (() ()  t ())) (3 (() ()  t  t))
      (4 (()  t () ())) (5 (()  t ()  t)) (6 (()  t  t ())) (7 (()  t  t  t))
      (8 ( t () () ())) (9 ( t () ()  t)) (A ( t ()  t ())) (B ( t ()  t  t))
      (C ( t  t () ())) (D ( t  t ()  t)) (E ( t  t  t ())) (F ( t  t  t  t))
     ) )))


(hex->bits (lambda (h) (
    (label hex->bits-append (lambda (hr h) (cond
        ((null hr) h)
        ( t       (hex->bits-append (cdr hr)
                                    (append (hex->bit^4 (car hr)) h) )) )))
    (reverse h) () )))


; params: d, a hex digit
; return: list of two base-4 (quaternary) digits
(hex->quater^2 (lambda (d) (assoc d
    '((0 (0 0))  (1 (0 1))  (2 (0 2))  (3 (0 3))  (4 (1 0))  (5 (1 1))
      (6 (1 2))  (7 (1 3))  (8 (2 0))  (9 (2 1))  (A (2 2))  (B (2 3))
      (C (3 0))  (D (3 1))  (E (3 2))  (F (3 3)) ) )))


; params: x and y, two base-4 (quaternary) digits
; return: a hex digit
(quater^2->hex (lambda (x y) (assoc y (assoc x
    '((0 ((0 0)  (1 1)  (2 2)  (3 3)))
      (1 ((0 4)  (1 5)  (2 6)  (3 7)))
      (2 ((0 8)  (1 9)  (2 A)  (3 B)))
      (3 ((0 C)  (1 D)  (2 E)  (3 F))) ) ))))


; Convert four binary digits, most significant bit first,
; to one hexadecimal digit.
(bit^4->hex (lambda (x) (
    (cond ((car x) (cond ((cadr x) bit^2+C->hex) (t bit^2+8->hex)))
          ( t      (cond ((cadr x) bit^2+4->hex) (t bit^2->quater))) )
    (cddr x) )))


(bits->hex (lambda (b) (
    (label bits->hex-rec (lambda (br h) (cond 
       ((null        br ) h)
       ((null (cdr   br)) (cons
            (bit^4->hex (append (list () ()) (list () (car br))))
             h ))
       ((null (cddr  br)) (cons
            (bit^4->hex (append (list () ()) (list (cadr br) (car br))))
             h ))
       ((null (cdddr br)) (cons
            (bit^4->hex (append (list () (caddr br)) (list (cadr br) (car br))))
             h ))
       ( t (bits->hex-rec (cddddr br) (cons
            (bit^4->hex (append (list (cadddr br) (caddr br))
                                (list (cadr   br) (car   br)) ))
             h ))) )))
    (reverse b) () )))


(bit^2+C->hex (lambda (x) (cond
    ((car  x) (cond ((cadr x) 'F) (t 'E)))
    ((cadr x) 'D)
    ( t       'C)) ))


(bit^2+8->hex (lambda (x) (cond
    ((car  x) (cond ((cadr x) 'B) (t 'A)))
    ((cadr x) '9)
    ( t       '8) )))


(bit^2+4->hex (lambda (x) (cond
    ((car  x) (cond ((cadr x) '7) (t '6)))
    ((cadr x) '5)
    ( t       '4) )))


(bit^2->quater (lambda (x) (cond
    ((car  x) (cond ((cadr x) '3) (t '2)))
    ((cadr x) '1)
    ( t       '0) )))


(quater->bit^2 (lambda (x) (assoc x
    '((0 (() ())) (1 (()  t)) (2 ( t ())) (3 ( t  t))) )))


; Base64 encoding
; Standard: RFC 1421
; params: x, y, and z, three hex digits
; return: list of two base64 digits
(hex^3->base64^2 (lambda (x y z) (quater^2*3->base64^2
    (hex->quater^2 x) (hex->quater^2 y) (hex->quater^2 z) )))


; params: h, a list of hex digits
; return: list of base64 digits
(hex->base64 (lambda (h) (
    (label hex->base64-rec (lambda (hr b) (cond
        ((null       hr )  b)
        ((null (cdr  hr)) (append
            (hex^3->base64^2 '0 '0 (car hr))
             b))  ; shouldn't happen
        ((null (cddr hr)) (append
            (hex^3->base64^2 '0 (cadr hr) (car hr))
			 b))  ; shouldn't happen
        ( t (hex->base64-rec (cdddr hr) (append
            (hex^3->base64^2 (caddr hr) (cadr hr) (car hr))
             b ))) )))
    (reverse h) () )))


; params: x, y, and z, three pairs of base-4 (quaternary) digits
; return: list of two base64 digits
(quater^2*3->base64^2 (lambda (x y z) (list
    (quater^3->base64 (car  x) (cadr x) (car  y))
    (quater^3->base64 (cadr y) (car  z) (cadr z)) )))


; params: x and y, two base64 digits
; return: list of three hex digits
(base64^2->hex^3 (lambda (x y)
    (quater^6*1->hex^3 (append (base64->quater^3 x) (base64->quater^3 y))) ))


; params: u, a list of six base-4 (quaternary) digits
; return: list of three hex digits
(quater^6*1->hex^3 (lambda (u) (cons
    (quater^2->hex (car u) (cadr u))
    (list (quater^2->hex (caddr u)        (cadddr u))
          (quater^2->hex (car (cddddr u)) (cadr (cddddr u))) ) )))


(base64->hex (lambda (b) (
    (label base64->hex-rec (lambda (br b) (cond
       ((null      br )  b)
       ((null (cdr br))  ; shouldn't happen
            (append (base64^2->hex^3 'A (car br)) b) )
       ( t (base64->hex-rec (cddr br) (append
            (base64^2->hex^3 (cadr br) (car br))
             b ))) )))
    (reverse b) () )))


(base64->quater^3 (lambda (x) (assoc x '(
    (A (0 0 0)) (B (0 0 1)) (C (0 0 2)) (D (0 0 3)) (E (0 1 0)) (F (0 1 1))
    (G (0 1 2)) (H (0 1 3)) (I (0 2 0)) (J (0 2 1)) (K (0 2 2)) (L (0 2 3))
    (M (0 3 0)) (N (0 3 1)) (O (0 3 2)) (P (0 3 3)) (Q (1 0 0)) (R (1 0 1))
    (S (1 0 2)) (T (1 0 3)) (U (1 1 0)) (V (1 1 1)) (W (1 1 2)) (X (1 1 3))
    (Y (1 2 0)) (Z (1 2 1)) (a (1 2 2)) (b (1 2 3)) (c (1 3 0)) (d (1 3 1))
    (e (1 3 2)) (f (1 3 3)) (g (2 0 0)) (h (2 0 1)) (i (2 0 2)) (j (2 0 3))
    (k (2 1 0)) (l (2 1 1)) (m (2 1 2)) (n (2 1 3)) (o (2 2 0)) (p (2 2 1))
    (q (2 2 2)) (r (2 2 3)) (s (2 3 0)) (t (2 3 1)) (u (2 3 2)) (v (2 3 3))
    (w (3 0 0)) (x (3 0 1)) (y (3 0 2)) (z (3 0 3)) (0 (3 1 0)) (1 (3 1 1))
    (2 (3 1 2)) (3 (3 1 3)) (4 (3 2 0)) (5 (3 2 1)) (6 (3 2 2)) (7 (3 2 3))
    (8 (3 3 0)) (9 (3 3 1)) (+ (3 3 2)) (/ (3 3 3)) ))))


; params: x, y, and z, three base-4 (quaternary) digits
; return: a base64 digit
(quater^3->base64 (lambda (x y z) (assoc z (assoc y (assoc x '(
    (0 ((0 ((0 A) (1 B) (2 C) (3 D)))  (1 ((0 E) (1 F) (2 G) (3 H)))
        (2 ((0 I) (1 J) (2 K) (3 L)))  (3 ((0 M) (1 N) (2 O) (3 P))) ))
    (1 ((0 ((0 Q) (1 R) (2 S) (3 T)))  (1 ((0 U) (1 V) (2 W) (3 X)))
        (2 ((0 Y) (1 Z) (2 a) (3 b)))  (3 ((0 c) (1 d) (2 e) (3 f))) ))
    (2 ((0 ((0 g) (1 h) (2 i) (3 j)))  (1 ((0 k) (1 l) (2 m) (3 n)))
        (2 ((0 o) (1 p) (2 q) (3 r)))  (3 ((0 s) (1 t) (2 u) (3 v))) ))
    (3 ((0 ((0 w) (1 x) (2 y) (3 z)))  (1 ((0 0) (1 1) (2 2) (3 3)))
        (2 ((0 4) (1 5) (2 6) (3 7)))  (3 ((0 8) (1 9) (2 +) (3 /))) )) ))))))


(hex^2->quoted-printable (lambda (x y) (assoc y (cond
   ((eq x '2) '((0 (= 2 0))
                        (1 (!)) (2 ("))  ;((")) This comment balances hiliting.
                                        (3 (#)) (4 ($)) (5 (%))
                (6 (&)) (7 (')) (8 (= 2 8))
                                        (9 (= 2 9))
                                                (A (*)) (B (+))
                (C (,)) (D (-)) (E (.)) (F (/)) ))
   ((eq x '3) '((0 (0)) (1 (1)) (2 (2)) (3 (3)) (4 (4)) (5 (5))
                (6 (6)) (7 (7)) (8 (8)) (9 (9)) (A (:)) (B (= 3 B))
                (C (<)) (D (= 3 D))
                                (E (>)) (F (?)) ))
   ((eq x '4) '((0 (@)) (1 (A)) (2 (B)) (3 (C)) (4 (D)) (5 (E))
                (6 (F)) (7 (G)) (8 (H)) (9 (I)) (A (J)) (B (K))
                (C (L)) (D (M)) (E (N)) (F (O)) ))
   ((eq x '5) '((0 (P)) (1 (Q)) (2 (R)) (3 (S)) (4 (T)) (5 (U))
                (6 (V)) (7 (W)) (8 (X)) (9 (Y)) (A (Z)) (B ([))
                (C (\)) (D (])) (E (^)) (F (_)) ))
   ((eq x '6) '((0 (`)) (1 (a)) (2 (b)) (3 (c)) (4 (d)) (5 (e))
                (6 (f)) (7 (g)) (8 (h)) (9 (i)) (A (j)) (B (k))
                (C (l)) (D (m)) (E (n)) (F (o)) ))
   ((eq x '7) '((0 (p)) (1 (q)) (2 (r)) (3 (s)) (4 (t)) (5 (u))
                (6 (v)) (7 (w)) (8 (x)) (9 (y)) (A (z)) (B ({))
                (C (|)) (D (})) (E (~)) (F (= 7 F)) ))
   ( t          (cons '= (list x y))) ))))


(hex->quoted-printable (lambda (h) (
    (label hex->qp-rec (lambda (hr h) (cond
       ((null hr) h)
       ((null (cdr hr)) (append
            (hex^2->quoted-printable '0 (car hr))
             h ))  ; shouldn't happen
       ( t (hex->qp-rec 
            (cddr hr)
            (append (hex^2->quoted-printable (cadr hr) (car hr)) h) )) )))
    (reverse h) () )))


; Intentionally produces two hexadecimal digits in reverse order
; for most ASCII printable characters.
; Characters intentionally omitted: SPACE PARENS SEMICOLON EQUAL and 7F.
(quoted-printable->hex^2r (lambda (x) (assoc x '(
              (! (1 2)) (" (2 2))   ;(") This comment balances hiliting.
                                  (# (3 2)) ($ (4 2)) (% (5 2))
    (& (6 2)) (' (7 2))                     (* (A 2)) (+ (B 2))
    (, (C 2)) (- (D 2)) (. (E 2)) (/ (F 2)) (0 (0 3)) (1 (1 3))
    (2 (2 3)) (3 (3 3)) (4 (4 3)) (5 (5 3)) (6 (6 3)) (7 (7 3))
    (8 (8 3)) (9 (9 3)) (: (A 3))           (< (C 3))          
    (> (E 3)) (? (F 3)) (@ (0 4)) (A (1 4)) (B (2 4)) (C (3 4))
    (D (4 4)) (E (5 4)) (F (6 4)) (G (7 4)) (H (8 4)) (I (9 4))
    (J (A 4)) (K (B 4)) (L (C 4)) (M (D 4)) (N (E 4)) (O (F 4))
    (P (0 5)) (Q (1 5)) (R (2 5)) (S (3 5)) (T (4 5)) (U (5 5))
    (V (6 5)) (W (7 5)) (X (8 5)) (Y (9 5)) (Z (A 5)) ([ (B 5))
    (\ (C 5)) (] (D 5)) (^ (E 5)) (_ (F 5)) (` (0 6)) (a (1 6))
    (b (2 6)) (c (3 6)) (d (4 6)) (e (5 6)) (f (6 6)) (g (7 6))
    (h (8 6)) (i (9 6)) (j (A 6)) (k (B 6)) (l (C 6)) (m (D 6))
    (n (E 6)) (o (F 6)) (p (0 7)) (q (1 7)) (r (2 7)) (s (3 7))
    (t (4 7)) (u (5 7)) (v (6 7)) (w (7 7)) (x (8 7)) (y (9 7))
    (z (A 7)) ({ (B 7)) (| (C 7)) (} (D 7)) (~ (E 7)) ))))


(quoted-printable->hex (lambda (chars) (
    (label loop (lambda (chars accur) (cond
        ((null chars) (reverse accur))
        ((eq (car chars) '=) (cond
            ((null (cdr chars)) (loop () accur))
            ((hex->bit^4 (cadr chars)) (cond
                ((null (cddr chars)) (loop (cons (cadr chars) ()) accur))
                ((hex->bit^4 (caddr chars))
                 (loop (cdddr chars)
                       (append (list (caddr chars) (cadr chars)) accur)) )
                ( t (loop (cdr chars) accur)) ))
            ( t (loop (cdr chars) accur)) ))
        ( t (loop (cdr chars)
                  (append (quoted-printable->hex^2r (car chars))
                           accur ) )) )))
    chars () )))

