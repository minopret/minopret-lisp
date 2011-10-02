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
; And I also have conversion back and forth with decimal and balanced base-81.
;
; Representation: A balanced-ternary number is represented
; as a list whose elements are from the three atoms (+ 0 -).
; The atom + is a positive one digit. The atom - is a negative
; one digit. Digits are listed from most to least significant.
;
; Useful functions so far: bal3_neg bal3_minus bal3_add bal3_mult
;
; Aaron Mansheim, 2011-09-24

; TODO Provide a mechanism to depend on a module or file.
; I suppose a Makefile or scons that causes the required
; file to be concatenated on stdin to repyl1.py would be
; good enough for a start.



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

(label hex_mult_3 (lambda (x) (assoc x '(
    (0 (0 0))  (1 (0 3))  (2 (0 6))  (3 (0 9))
    (4 (0 C))  (5 (0 F))  (6 (1 2))  (7 (1 5))
    (8 (1 8))  (9 (1 B))  (A (1 E))  (B (2 1))
    (C (2 4))  (D (2 7))  (E (2 A))  (F (2 D)) ))))

; for carrying or incrementing
(label hex_add_1 (lambda (x) (assoc x '(
    (0 (0 1))  (1 (0 2))  (2 (0 3))  (3 (0 4))
    (4 (0 5))  (5 (0 6))  (6 (0 7))  (7 (0 8))
    (8 (0 9))  (9 (0 A))  (A (0 B))  (B (0 C))
    (C (0 D))  (D (0 E))  (E (0 F))  (F (1 0)) ))))

; for carrying
(label hex_add_2 (lambda (x) (assoc x '(
    (0 (0 2))  (1 (0 3))  (2 (0 4))  (3 (0 5))
    (4 (0 6))  (5 (0 7))  (6 (0 8))  (7 (0 9))
    (8 (0 A))  (9 (0 B))  (A (0 C))  (B (0 D))
    (C (0 E))  (D (0 F))  (E (1 0))  (F (1 1)) ))))

; 16 (base 10) = 27 - 9 - 3 + 1 (base 10) = + - - + (bal 3)
(label trit_mult_16 (lambda (x) (assoc x '(
    (+ (+ - - +))  (0 (0 0 0 0))  (- (- + + -)) ))))

; Add two hex numbers by reducing to balanced ternary arithmetic.
(label hex_add (lambda (x y)
    (bal3_to_hex (bal3_add (hex_to_bal3 x) (hex_to_bal3 y))) ))

; TODO hex_to_bal3, bal3_to_hex

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
(label hex_to_trit (lambda (x) (assoc x '(
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
(label decimal_mult_3 (lambda (x) (assoc x '(
    (0 (0 0))  (1 (0 3))  (2 (0 6))  (3 (0 9))  (4 (1 2))  
    (5 (1 5))  (6 (1 8))  (7 (2 1))  (8 (2 4))  (9 (2 7)) ))))

(label trit_to_decimal (lambda (x) (trit_to_hex x)))

(label decimal_to_trit (lambda (x) (cdr (hex_to_trit x))))

; 10 (base 10) = 9 + 1 (base 10) = + 0 + (bal 3)
; Example: 1488 (base 10)
; = (+ + 0 + 0 0 +) + (+ - - 0 - + +) + (+ 0 0 0 -) + (+ 0 -)
(label trit_mult_10 (lambda (x) (assoc x '(
    (+ (+ 0 +))
    (0 (0 0 0))
    (- (- 0 -)) ))))

; Add two decimal numbers by reducing to balanced ternary arithmetic.
(label add (lambda (x y) (bal3_to_decimal
    (bal3_add (decimal_to_bal3 x) (decimal_to_bal3 y)) )))

; TODO decimal_to_bal3, bal3_to_decimal



; Where I want more compactness I could use this balanced base-81 encoding
; into printable characters of ASCII (equivalently, UTF-8 Basic Latin block):
;
; 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ}]/>+
;  !@#$%^&*?abcdefghijklmnopqrstuvwxyz{[\<-
; .     .....     .....     .....     .....
;
; Just 13 ASCII printables are not assigned: '"(),.:;=_`|~
; The 2^8 ASCII values are a bit more than 3^5. 
; If we wanted, we could easily pack 3 ASCII values
; into 4 bal81 digits. On the other hand if we're trying
; to achieve compression, that is a relatively lame
; way to do it.



; Comparison chart for bal3 notation, bal81, decimal, bit, and byte:
; Non-negative ranges:
; bal3:  0 +   decimal: 0-1  #values incl. neg.:3; trits: 1;  0 bytes;   bits: 1
;       +- ++           2-4                     9   0     2                  2-3
;      +-- +++          5-13                   27   1     3                  3-4
;     +--- ++++        14-40                   81         4; bal81's: 1      5-6
;    +---- +++++       41-121                 243   2     5                  6-7
;   +----- ++++++     122-364                 729         6;  1 byte;        8-9
;  +------ +++++++    365-1093               2187   3     7                 10-11
; +------- ++++++++  1094-3280               6561         8           2     11-12
;bal81:+-- +++       1123-265720           531441   6    12   2       3     18-19
;     +--- ++++    265721-21523360       43046721   7    16   3       4     24-25
;    +---- +++++ 21523361-1743392200   3486784401  10    20           5     30-31
;     etc. etc.1743392201-14214768240 282429536481 11    24   4       6     37-38
; NOTE: 2^31 = 2147483648
;                    etc. etc.               etc.  13    28   5       7     43-44
;                                                  15    32   6       8     49-50
;                                                  17    36   7       9     56-57
;                                                  19    40          10     62-63
;                                  digits base 10: 20    44   8      11     68-69


(label trit4_to_bal81 (lambda (x) (assoc-equal x '(
((- - - -) -) ((- - - 0) <) ((- - - +) \) ((- - 0 -) [) ((- - 0 0) {) ((- - 0 +) z)
((- - + -) y) ((- - + 0) x) ((- - + +) w) ((- 0 - -) v) ((- 0 - 0) u) ((- 0 - +) t)
((- 0 0 -) s) ((- 0 0 0) r) ((- 0 0 +) q) ((- 0 + -) p) ((- 0 + 0) o) ((- 0 + +) n)
((- + - -) m) ((- + - 0) l) ((- + - +) k) ((- + 0 -) j) ((- + 0 0) i) ((- + 0 +) h)
((- + + -) g) ((- + + 0) f) ((- + + +) e) ((0 - - -) d) ((0 - - 0) c) ((0 - - +) b)
((0 - 0 -) a) ((0 - 0 0) ?) ((0 - 0 +) *) ((0 - + -) &) ((0 - + 0) ^) ((0 - + +) %)
((0 0 - -) $) ((0 0 - 0) #) ((0 0 - +) @) ((0 0 0 -) !) ((0 0 0 0) 0) ((0 0 0 +) 1)
((0 0 + -) 2) ((0 0 + 0) 3) ((0 0 + +) 4) ((0 + - -) 5) ((0 + - 0) 6) ((0 + - +) 7)
((0 + 0 -) 8) ((0 + 0 0) 9) ((0 + 0 +) A) ((0 + + -) B) ((0 + + 0) C) ((0 + + +) D)
((+ - - -) E) ((+ - - 0) F) ((+ - - +) G) ((+ - 0 -) H) ((+ - 0 0) I) ((+ - 0 +) J)
((+ - + -) K) ((+ - + 0) L) ((+ - + +) M) ((+ 0 - -) N) ((+ 0 - 0) O) ((+ 0 - +) P)
((+ 0 0 -) Q) ((+ 0 0 0) R) ((+ 0 0 +) S) ((+ 0 + -) T) ((+ 0 + 0) U) ((+ 0 + +) V)
((+ + - -) W) ((+ + - 0) X) ((+ + - +) Y) ((+ + 0 -) Z) ((+ + 0 0) }) ((+ + 0 +) ])
((+ + + -) >) ((+ + + 0) /) ((+ + + +) +) ))))

(label bal81_to_trit4 (lambda (x) (assoc-equal x '(
(- (- - - -)) (< (- - - 0)) (\ (- - - +)) ([ (- - 0 -)) ({ (- - 0 0)) (z (- - 0 +))
(y (- - + -)) (x (- - + 0)) (w (- - + +)) (v (- 0 - -)) (u (- 0 - 0)) (t (- 0 - +))
(s (- 0 0 -)) (r (- 0 0 0)) (q (- 0 0 +)) (p (- 0 + -)) (o (- 0 + 0)) (n (- 0 + +))
(m (- + - -)) (l (- + - 0)) (k (- + - +)) (j (- + 0 -)) (i (- + 0 0)) (h (- + 0 +))
(g (- + + -)) (f (- + + 0)) (e (- + + +)) (d (0 - - -)) (c (0 - - 0)) (b (0 - - +))
(a (0 - 0 -)) (? (0 - 0 0)) (* (0 - 0 +)) (& (0 - + -)) (^ (0 - + 0)) (% (0 - + +))
(s (0 0 - -)) (# (0 0 - 0)) (@ (0 0 - +)) (! (0 0 0 -)) (0 (0 0 0 0)) (1 (0 0 0 +))
(2 (0 0 + -)) (3 (0 0 + 0)) (4 (0 0 + +)) (5 (0 + - -)) (6 (0 + - 0)) (7 (0 + - +))
(8 (0 + 0 -)) (9 (0 + 0 0)) (A (0 + 0 +)) (B (0 + + -)) (C (0 + + 0)) (D (0 + + +))
(E (+ - - -)) (F (+ - - 0)) (G (+ - - +)) (H (+ - 0 -)) (I (+ - 0 0)) (J (+ - 0 +))
(K (+ - + -)) (L (+ - + 0)) (M (+ - + +)) (N (+ 0 - -)) (O (+ 0 - 0)) (P (+ 0 - +))
(Q (+ 0 0 -)) (R (+ 0 0 0)) (S (+ 0 0 +)) (T (+ 0 + -)) (U (+ 0 + 0)) (V (+ 0 + +))
(W (+ + - -)) (X (+ + - 0)) (Y (+ + - +)) (Z (+ + 0 -)) (} (+ + 0 0)) (] (+ + 0 +))
(> (+ + + -)) (/ (+ + + 0)) (+ (+ + + +)) ))))



; Balanced-ternary subtraction reduces easily to addition.

(label trit_neg (lambda (x) (assoc x '( (+ -) (0 0) (- +) ) )))

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

; This little state machine can be factored and optimized.
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
    ((null (cdr y))  y)  ; in my case I want at least one element
    ((eq x (car y)) (discard_car_while_eq x (cdr y)))
    (            t   y                              ) )))

; Add without removing leading zeroes from sum
(label bal3_add_denorm (lambda (x y)
    (bal3_add_carrying () () x y '(0)) ))

(label bal3_add (lambda (x y)
    (discard_car_while_eq '0 (bal3_add_denorm x y)) ))

; Balanced-ternary multiplication.

; Conveniently, multiplying a balanced ternary number by a trit
; gives (+) an identical result, (0) a zero result, or (-) a negated result.

(label trit_mult (lambda (x y) (cond ((eq x '0) '0)
                                     ((eq y '0) '0)
                                     ((eq x  y) '+)
                                     (       t  '-) )))

; params: x: left multiplicand, a bal3
;         y: right multiplicand, a trit
(label bal3_mult_trit (lambda (x y) (cond ((eq y '0) '(0))
                                          ((eq y '+)   x)
                                          (       t   (bal3_neg x)) )))

; Balanced-ternary multiplication

(label bal3_mult (lambda (m n) ( bal3_mult_tritwise () m n '((0) ()) )))


; This little state machine can be factored and optimized.
;
; params: nr: reversed higher digits of right multiplicand
;          m: left multiplicand
;          n: lower digits of right multiplicand
;         cp: car: digits carried from sum of previous digit products
;            cadr: digits completed from sum of previous digit products
(label bal3_mult_tritwise (lambda (nr m n cp) (cond
    ((null (cdr n)) (cond
        ((null nr) (append (bal3_add (car cp) (bal3_mult_trit m (car n)))
                           (cadr cp)))  ; add carry digits to product; record all
        (       t  (bal3_mult_tritwise (cdr nr)  ; load next digit of n
                                        m
                                       (cons (car nr) ())
                                       (bal3_mult_trit_acc m (car n) cp) )) ))
    (           t  (bal3_mult_tritwise (cons (car n) nr)  ; stack up digits of n
                                        m
                                       (cdr n)
                                        cp)) )))

; params:  m: left multiplicand, a bal3
;          n: one digit of right multiplicand, a trit
;         cp: car: digits carried from sum of previous digit products, a bal3
;            cadr: digits completed from sum of previous digit products,
;                  a list of trit (difference from a bal3: can be empty)
; return:     car: digits carried from sum of digit products with carry
;            cadr: digits completed from sum of digit products

(label bal3_mult_trit_regroup (lambda (pc1 cp0) (list
    (cdr pc1)  ; carry "c1" to add with next bal3*trit product
    (cons (car pc1) (cadr cp0)) )))  ; prefix "p" to output digits "p0"

; params:  m: left multiplicand, a bal3
;          n: one digit of right multiplicand, a trit
;         cp: car: digits carried from sum of previous digit products, a bal3
;            cadr: digits completed from sum of previous digit products,
;                  a list of trit (difference from a bal3: can be empty)
; return:     car: digits carried from sum of digit products with carry
;            cadr: digits completed from sum of digit products
(label bal3_mult_trit_acc (lambda (m n cp0) (bal3_mult_trit_regroup
    (rotate-right (bal3_add (bal3_mult_trit m n) (car cp0)))
    cp0)))
