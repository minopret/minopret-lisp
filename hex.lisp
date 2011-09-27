; Hexadecimal in classic (but lower-case) Lisp without
; using native numbers.
; Hexadecimal, partly because that's a pretty common way to handle
; ASCII and UTF-8.
; Without using native numbers, um, for fun??
;
; And I heard that balanced ternary is nice (base 3 with digits -1 0 1
; instead of 0 1 2). So let's try doing hex math by converting back and
; forth with balanced ternary!
;
; Representation: A balanced-ternary number is represented
; as a list whose elements are from the three atoms (+ 0 -).
; The atom + is a positive one digit. The atom - is a negative
; one digit. Digits are listed from most to least significant.
;
; Useful functions so far: bal3_neg bal3_minus bal3_add
; Utilities with a temporary home here: equal assert_equal
; Utilities with a temporary home here: fold-left
;
; Aaron Mansheim, 2011-09-24



; Put this stuff in a standard library

; Standard: Scheme.
(label fold-left (lambda (f z u) (cond
    ((null u) z)
    ((atom u) u)  ; why not
    ((null (cdr u)) (f (car u) z))
    (            t  (fold-left (f z (car u)) (cdr u))) )))



; hex_mult_3: This would assist computing a ternary digit value
; a_i*3^i in hex. Using this table, it's easy:
;   1 3 9 1B 51 F3 2D9 88B 19A1 4CE3 ...
; Just requires the ability to carry lead digits 0, 1, & 2 from this table.
; But to sum up a ternary number (a_i * 3^i) would require the ability to
; add any hex digits together. The most obvious implementation needs
; a 120-entry table.

; So, hmm, maybe for bal3_to_hex I'll do something cleverer than
; simply adding up a_i * 3^i. I'll file away the fact that each
; nonnegative number up to +++ (bal 3) = D (base 16) fits in one hex digit.

(label hex_mult_3 (lambda (x) (cond
  ((eq x '0) '(0 0))  ((eq x '1) '(0 3))  ((eq x '2) '(0 6))  ((eq x '3) '(0 9))
  ((eq x '4) '(0 C))  ((eq x '5) '(0 F))  ((eq x '6) '(1 2))  ((eq x '7) '(1 5))
  ((eq x '8) '(1 8))  ((eq x '9) '(1 B))  ((eq x 'A) '(1 E))  ((eq x 'B) '(2 1))
  ((eq x 'C) '(2 4))  ((eq x 'D) '(2 7))  ((eq x 'E) '(2 A))  ((eq x 'F) '(2 D))
)))

; for carrying or incrementing
(label hex_add_1 (lambda (x) (cond
  ((eq x '0) '(0 1))  ((eq x '1) '(0 2))  ((eq x '2) '(0 3))  ((eq x '3) '(0 4))
  ((eq x '4) '(0 5))  ((eq x '5) '(0 6))  ((eq x '6) '(0 7))  ((eq x '7) '(0 8))
  ((eq x '8) '(0 9))  ((eq x '9) '(0 A))  ((eq x 'A) '(0 B))  ((eq x 'B) '(0 C))
  ((eq x 'C) '(0 D))  ((eq x 'D) '(0 E))  ((eq x 'E) '(0 F))  ((eq x 'F) '(1 0))
)))

; for carrying
(label hex_add_2 (lambda (x) (cond
  ((eq x '0) '(0 2))  ((eq x '1) '(0 3))  ((eq x '2) '(0 4))  ((eq x '3) '(0 5))
  ((eq x '4) '(0 6))  ((eq x '5) '(0 7))  ((eq x '6) '(0 8))  ((eq x '7) '(0 9))
  ((eq x '8) '(0 A))  ((eq x '9) '(0 B))  ((eq x 'A) '(0 C))  ((eq x 'B) '(0 D))
  ((eq x 'C) '(0 E))  ((eq x 'D) '(0 F))  ((eq x 'E) '(1 0))  ((eq x 'F) '(1 1))
)))

; 16 (base 10) = 27 - 9 - 3 + 1 (base 10) = + - - + (bal 3)
(label trit_mult_16 (lambda (x) (cond
  ((eq x '+) '(+ - - +))
  ((eq x '0) '(0 0 0 0))
  ((eq x '-) '(- + + -)) )))

; Add two hex numbers by reducing to balanced ternary arithmetic.
(label hex_add (lambda (x y)
    (bal3_to_hex (bal3_add (hex_to_bal3 x) (hex_to_bal3 y))) ))

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
(label hex_to_trit (lambda (x) (cond
  ((eq x '0) '(0 0 0 0))  ((eq x '1) '(0 0 0 +))  ((eq x '2) '(0 0 + -))
  ((eq x '3) '(0 0 + 0))  ((eq x '4) '(0 0 + +))  ((eq x '5) '(0 + - -))
  ((eq x '6) '(0 + - 0))  ((eq x '7) '(0 + - +))  ((eq x '8) '(0 + 0 -))
  ((eq x '9) '(0 + 0 0))  ((eq x 'A) '(0 + 0 +))  ((eq x 'B) '(0 + + -))
  ((eq x 'C) '(0 + + 0))  ((eq x 'D) '(0 + + +))  ((eq x 'E) '(+ - - -))
  ((eq x 'F) '(+ - - 0))
)))



; I suppose we'll want decimal too.
; 10 (base 10) = + 0 + (bal 3).
; 3^i = 1 3 9 27 81 243 729 2187 6561 19683 ... (base 10).
; Example: 1488 (base 10) = 2187 - 729 + 27 + 3 = + - 0 0 + 0 + 0 (bal 3).
(label decimal_mult_3 (lambda (x) (cond
  ((eq x '0) '(0 0))  ((eq x '1) '(0 3))  ((eq x '2) '(0 6))
  ((eq x '3) '(0 9))  ((eq x '4) '(1 2))  ((eq x '5) '(1 5))
  ((eq x '6) '(1 8))  ((eq x '7) '(2 1))  ((eq x '8) '(2 4))
  ((eq x '9) '(2 7)) )))

(label trit_to_decimal (lambda (x) (trit_to_hex x)))

(label decimal_to_trit (lambda (x) (cdr (hex_to_trit x))))

; 10 (base 10) = 9 + 1 (base 10) = + 0 + (bal 3)
; Example: 1488 (base 10)
; = (+ + 0 + 0 0 +) + (+ - - 0 - + +) + (+ 0 0 0 -) + (+ 0 -)
(label trit_mult_10 (lambda (x) (cond
  ((eq x '+) '(+ 0 +))
  ((eq x '0) '(0 0 0))
  ((eq x '-) '(- 0 -)) )))

; Add two decimal numbers by reducing to balanced ternary arithmetic.
(label add (lambda (x y) (bal3_to_decimal
    (bal3_add (decimal_to_bal3 x) (decimal_to_bal3 y)) )))



; For hex_to_bal3, bal3_to_hex, decimal_to_bal3, bal3_to_decimal,
; there's a bunch of work yet to be done.



; Balanced-ternary subtraction reduces easily to addition.

(label trit_neg (lambda (x) (cond ((eq x '+) '-)
                                  ((eq x '-) '+)
                                  (       t  '0) )))

(label bal3_neg (lambda (x) (cond
  ((null x)  ())
        (t   (cons (trit_neg (car x)) (bal3_neg (cdr x)))) )))

(label bal3_minus (lambda (x y) (bal3_add x (bal3_neg y))))



; So, balanced-ternary addition. Right.

; Add balanced-ternary digits, respecting a negative carry digit.

(label trit_add- (lambda (x y) (cond (     (eq x '+)  (list '0 y))
                                     (     (eq y '+)  (list '0 x))
                                     ((not (eq x y)) '(- +))
                                     (     (eq x '0) '(0 -))
                                     (            t  '(- 0)) )))

(label trit_add (lambda (x y) (cond (     (eq x '0)  (list '0 y))
                                    (     (eq y '0)  (list '0 x))
                                    ((not (eq x y)) '(0 0))
                                    (     (eq x '-) '(- +))
                                    (            t  '(+ -)) )))

; Add balanced-ternary digits, respecting a positive carry digit.

(label trit_add+ (lambda (x y) (cond (     (eq x '-)  (list '0 y))
                                     (     (eq y '-)  (list '0 x))
                                     ((not (eq x y)) '(+ -))
                                     (     (eq x '0) '(0 +))
                                     (            t  '(+ 0)) )))

; params:   x: left addend, a trit
;           y: right addend, a trit
;           c: carry digit, a trit
; return: car: new carry digit, a trit
;        cadr: result digit, a trit
(label trit_add_carrying (lambda (x y c) (cond
    ((eq c '0) (trit_add  x y))
    ((eq c '+) (trit_add+ x y))
    (       t  (trit_add- x y))
)))

; params:   x: left addend, a trit
;           y: right addend, a trit
;          cs: sum of less significant digits, a bal3 with leading carry digit
; return:      new sum, a bal3 with leading carry digit
(label bal3_trits_add (lambda (x y cs)
    (append (trit_add_carrying x y (car cs)) (cdr cs)) ))

; This dopey little state machine can be optimized considerably
; once it's in working condition.
;
; params:  yr: reversed more significant digits for y, initially ()
;          xr: reversed more significant digits for x, initially ()
;           x: left addend, a bal3
;           y: right addend, a bal3
;          cs: sum of less significant digits, a bal3 with leading carry digit
; return:      new sum, a bal3 with leading carry digit
(label bal3_add_carrying (lambda (yr xr x y cs) (cond
    ((null (cdr x)) (cond  ; scanned to last digit of x: ready to add?
        ((null (cdr y)) (cond  ; scanned to last digit of y: ready to add.
            ((null yr) (cond  ; y's stack is empty
                ((null xr)  ; and x's stack is empty
                    ; add the respective final digits and that's all!
                    (bal3_trits_add (car x) (car y) cs) )
                (t  ; only x's stack has digits: push a zero to y's
                    (bal3_add_carrying '(0) xr x y cs) ) ))
            (t (cond  ; y's stack still has digits
                ((null xr)  ; only y's stack has digits: push a zero to x's
                    (bal3_add_carrying yr '(0) x y cs) )
                (t  ; both x's and y's stacks have digits
                    (bal3_add_carrying (cdr yr)
                                       (cdr xr)
                                       (cons (car xr) ())
                                       (cons (car yr) ())
                                           (bal3_trits_add (car x)
                                                           (car y)
                                                            cs) )) )) ))

        ; y has more-significant digits that we need to stack up before adding
        (t (bal3_add_carrying (cons (car y) yr) xr x (cdr y) cs)) ))
    ; x has more-significant digits that we need to stack up before adding
    (t (bal3_add_carrying yr (cons (car x) xr) (cdr x) y cs)) )))

; Nonce function
(label discard_car_while_eq (lambda (x y) (cond
    ((null (cdr y))  y)  ; in my case I need at least one element
    ((eq x (car y)) (discard_car_while_eq x (cdr y)))
    (            t   y                              ) )))

(label bal3_add (lambda (x y)
    (discard_car_while_eq '0 (bal3_add_carrying () () x y '(0))) ))



; Balanced-ternary multiplication.

; Conveniently, multiplying a balanced ternary number by a trit
; gives (+) an identical result, (0) a zero result, or (-) a negated result.

(label trit_mult (lambda (x y) (cond ((eq x '0) '0)
                                     ((eq y '0) '0)
                                     ((eq x  y) '+)
                                            (t  '-) )))

(label bal3_mult_trit (lambda (x y) (cond ((eq y '0) '(0))
                                          ((eq y '+)   x)
                                                 (t   (bal3_neg x)) )))

; Balanced-ternary multiplication goes here...
