; Facts about integers in positional notation that I have
; defined but not yet used.
;
; Aaron Mansheim, 2011-09-24 (in hex.lisp, renamed as integer.lisp)
;                 2011-10-10 (in integer_trivia.lisp)



; hex-mult3: This would assist computing a ternary digit value
; a_i*3^i in hex. Using this table, it's easy:
;   1 3 9 1B 51 F3 2D9 88B 19A1 4CE3 ...
; Just requires the ability to carry lead digits 0, 1, & 2 from this table.
; But to sum up a ternary number (a_i * 3^i) would require the ability to
; add any hex digits together. The most obvious implementation needs
; a 120-entry table.

; So, hmm, maybe for bal3->hex I'll do something cleverer than
; simply adding up a_i * 3^i. I'll file away the fact that each
; nonnegative number up to +++ (bal 3) = D (base 16) fits in one hex digit.

(label hex-mult3 (lambda (x) (assoc x '(
    (0 (0 0))  (1 (0 3))  (2 (0 6))  (3 (0 9))
    (4 (0 C))  (5 (0 F))  (6 (1 2))  (7 (1 5))
    (8 (1 8))  (9 (1 B))  (A (1 E))  (B (2 1))
    (C (2 4))  (D (2 7))  (E (2 A))  (F (2 D)) ))))

; for carrying or incrementing
(label hex-add1 (lambda (x) (assoc x '(
    (0 (0 1))  (1 (0 2))  (2 (0 3))  (3 (0 4))
    (4 (0 5))  (5 (0 6))  (6 (0 7))  (7 (0 8))
    (8 (0 9))  (9 (0 A))  (A (0 B))  (B (0 C))
    (C (0 D))  (D (0 E))  (E (0 F))  (F (1 0)) ))))

; for carrying
(label hex-add2 (lambda (x) (assoc x '(
    (0 (0 2))  (1 (0 3))  (2 (0 4))  (3 (0 5))
    (4 (0 6))  (5 (0 7))  (6 (0 8))  (7 (0 9))
    (8 (0 A))  (9 (0 B))  (A (0 C))  (B (0 D))
    (C (0 E))  (D (0 F))  (E (1 0))  (F (1 1)) ))))

; 16 (base 10) = 27 - 9 - 3 + 1 (base 10) = + - - + (bal 3)
(label trit-mult16 (lambda (x) (assoc x '(
    (+ (+ - - +))  (0 (0 0 0 0))  (- (- + + -)) ))))

; Add two hex numbers by reducing to balanced ternary arithmetic.
(label hex-add (lambda (x y)
    (bal3->hex (bal3-add (hex->bal3 x) (hex->bal3 y))) ))

; TODO hex->bal3, bal3->hex

; Example: 16 (base 10) = + - - + (bal 3),
; so 256 (base 10) = (+ - - + 0 0 0)
;                    + (- + + - 0 0)
;                      + (- + + - 0)
;                        + (+ - - +)
;                   = 0 + 0 0 + + + (bal 3) = 243 + 9 + 3 + 1 = 256 (base 10)
; Example: 1488 (base 10) = 5D0 (base 16)
;  = (0 + - -)*(+ - - +)*(+ - - +) + (0 + + +)*(+ - - +) (bal 3)
;  = (0 + - -)*(+ 0 0 + + +) + (+ 0 - - 0 +)
;  = (+ - - + - + + -) + (+ 0 - - 0 +)
;  =  + - 0 0 + 0 + 0  (bal 3) = 2187 - 729 + 27 + 3 = 1488 (base 10)
(label hex->trit (lambda (x) (assoc x '(
    (0 (0 0 0 0))  (1 (0 0 0 +))  (2 (0 0 + -))
    (3 (0 0 + 0))  (4 (0 0 + +))  (5 (0 + - -))
    (6 (0 + - 0))  (7 (0 + - +))  (8 (0 + 0 -))
    (9 (0 + 0 0))  (A (0 + 0 +))  (B (0 + + -))
    (C (0 + + 0))  (D (0 + + +))  (E (+ - - -))
    (F (+ - - 0)) ))))



; I suppose we'll want decimal too.
; 10 (base 10) = + 0 + (bal 3).
; 3^i = 1 3 9 27 81 243 729 2187 6561 19683 ... (base 10).
; Example: 1488 (base 10) = 2187 - 729 + 27 + 3 = + - 0 0 + 0 + 0 (bal 3).
(label decimal-mult3 (lambda (x) (assoc x '(
    (0 (0 0))  (1 (0 3))  (2 (0 6))  (3 (0 9))  (4 (1 2))  
    (5 (1 5))  (6 (1 8))  (7 (2 1))  (8 (2 4))  (9 (2 7)) ))))

(label trit->decimal (lambda (x) (trit->hex x)))

(label decimal->trit (lambda (x) (cdr (hex->trit x))))

; 10 (base 10) = 9 + 1 (base 10) = + 0 + (bal 3)
; Example: 1488 (base 10)
; = (+ + 0 + 0 0 +) + (+ - - 0 - + +) + (+ 0 0 0 -) + (+ 0 -)
(label trit-mult10 (lambda (x) (assoc x '(
    (+ (+ 0 +))
    (0 (0 0 0))
    (- (- 0 -)) ))))

; Add two decimal numbers by reducing to balanced ternary arithmetic.
(label add (lambda (x y) (bal3->decimal
    (bal3-add (decimal->bal3 x) (decimal->bal3 y)) )))

; TODO decimal->bal3, bal3->decimal



