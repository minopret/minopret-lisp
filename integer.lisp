; Arithmetic in classic (but lower-case) Lisp without using native numbers.
; Why without using native numbers? Um, for fun??
;
; And I heard that balanced ternary is nice (base 3 with digits -1 0 1
; instead of 0 1 2). So let's try doing math in balanced ternary!
;
; Ideally I'll also want conversion back and forth with decimal and hexadecimal.
;
; Representation: A balanced-ternary number is represented
; as a list whose elements are from the three atoms (+ 0 -).
; The atom + is a positive one digit. The atom - is a negative
; one digit. Digits are listed from most to least significant.
;
; Useful functions so far:
; trit4_to_bal81 bal81_to_trit4
; bal3_neg bal3_minus bal3_add bal3_mult bal3_lt bal3_gt
; hex_to_bit4 bit4_to_hex
;
; Aaron Mansheim, 2011-09-24

; TODO Provide a mechanism to depend on a module or file.
; I suppose a Makefile or scons that causes the required
; file to be concatenated on stdin to mnplisp.py would be
; good enough for a start.



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


; Similarly, for binary we'll want the compactness and familiarity of hexadecimal.
(label hex_to_bit4 (lambda (x) (assoc x '(
(0 (0 0 0 0)) (1 (0 0 0 1)) (2 (0 0 1 0)) (3 (0 0 1 1))
(4 (0 1 0 0)) (5 (0 1 0 1)) (6 (0 1 1 0)) (7 (0 1 1 1))
(8 (1 0 0 0)) (9 (1 0 0 1)) (A (1 0 1 0)) (B (1 0 1 1))
(C (1 1 0 0)) (D (1 1 0 1)) (E (1 1 1 0)) (F (1 1 1 1)) ))))

(label bit4_to_hex (lambda (x) (assoc-equal x '(
((0 0 0 0) 0) ((0 0 0 1) 1) ((0 0 1 0) 2) ((0 0 1 1) 3)
((0 1 0 0) 4) ((0 1 0 1) 5) ((0 1 1 0) 6) ((0 1 1 1) 7)
((1 0 0 0) 8) ((1 0 0 1) 9) ((1 0 1 0) A) ((1 0 1 1) B)
((1 1 0 0) C) ((1 1 0 1) D) ((1 1 1 0) E) ((1 1 1 1) F) ))))


; Balanced-ternary subtraction reduces easily to addition.

(label trit_neg (lambda (x) (assoc x '( (+ -) (0 0) (- +) ) )))

(label bal3_neg (lambda (x) (cond
  ((null x)  ())
        (t   (cons (trit_neg (car x)) (bal3_neg (cdr x)))) )))

(label bal3_minus (lambda (x y) (bal3_add x (bal3_neg y))))



; Unsigned binary subtraction will be zero when the minuend is greater.
; No implementation yet.

; The predecessor function for unsigned arbitrary-precision binary numbers.
; Here we pay a price for storing the most-significant bit first.
(label bin_pred (lambda (x) (cond
    ((eq x '(0)) '(0))
    (         t  (cadr (bin_pred_rec x))) )))

; Params: binary number, as non-empty list of Lisp truth values, most-significant bit first
; Return: pair of borrow bit and lower result
(label bin_pred_rec (lambda (x) (cond
    ((eq x '(0)) '(0 (0)))
    ((eq x '(1)) '(0 (0)))
    (         t  (bin_pred_borrow (car x) (bin_pred_rec (cdr x)))) )))

; Params: x, a Lisp truth value representing a more-significant bit
;         y, a pair of borrow bit and lower result
; Return: pair of borrow bit and lower result
(label bin_pred_borrow (lambda (x y) (cond
    ((eq (car y) '0) (list '0 (cons x (cdr y))))
    ((eq      x  '1) (list '0 (cons '0 (cdr y))))
    (             t  (list '1 (cons '1 (cdr y)))) )))



; Balanced-ternary comparison can correctly reduce to subtraction
; although most times it wouldn't require that exactness.

; Assuming normalized so that the lead digit is zero if, and only if,
; that is the only digit.
(label bal3_lt0 (lambda (x) (eq (car x) '-)))
(label bal3_gt0 (lambda (x) (eq (car x) '+)))

(label bal3_lt (lambda (x y) (bal3_lt0 (bal3_minus x y))))
(label bal3_gt (lambda (x y) (bal3_gt0 (bal3_minus x y))))

; (Unsigned) binary comparison must really go bit by bit.



; So, balanced-ternary addition. Right.

;(label trit_add (lambda (x y c) (assoc-equal (cons x (list y c))
;'(((- - -) (- 0))  ((- - 0) (- +))  ((- - +) (0 -))
;  ((- 0 -) (- +))  ((- 0 0) (0 -))  ((- 0 +) (0 0))
;  ((- + -) (0 -))  ((- + 0) (0 0))  ((- + +) (0 +))
; ;               //               //
;  ((0 - -) (- +))  ((0 - 0) (0 -))  ((0 - +) (0 0))
;  ((0 0 -) (0 -))  ((0 0 0) (0 0))  ((0 0 +) (0 +))
;  ((0 + -) (0 0))  ((0 + 0) (0 +))  ((0 + +) (+ -))
; ;               //               //
;  ((+ - -) (0 -))  ((+ - 0) (0 0))  ((+ - +) (0 +))
;  ((+ 0 -) (0 0))  ((+ 0 0) (0 +))  ((+ 0 +) (+ -))
;  ((+ + -) (0 +))  ((+ + 0) (+ -))  ((+ + +) (+ 0)) ) )))

;                 0 0 +          : negate
;                 0 + 0          : negate
;         0 + +   - + +   0 + -  : negate
;         + 0 +   + - +   + - 0  : negate

;                 + + -   + 0 -  : negate
; + + +   + + 0   + 0 0          : negate 

;                 0 0 -          : place digits in order - 0 +
;                 0 - 0          : place digits in order - 0 +
;         0 - -   + - -   0 - +  : place digits in order - 0 +
;         - 0 -   - + -   - + 0  : place digits in order - 0 +

;                 - - +   - 0 +  : cancel a minus with a plus
; - - -   - - 0   - 0 0   0 0 0  : canonical

;   - 0     - +     0 -     0 0  : sums


; params:   x: left addend, a trit
;           y: right addend, a trit
;           c: carry digit, a trit
; return: car: new carry digit, a trit
;        cadr: result digit, a trit
(label trit_add (lambda (x y c) (cond
    ((eq x '-) (cond ((eq y '-) (cond ((eq c '-) '(- 0)) ((eq c '0) '(- +)) (t '(0 -))))
                     ((eq y '0) (cond ((eq c '-) '(- +)) ((eq c '0) '(0 -)) (t '(0 0))))
                     (       t  (cond ((eq c '-) '(0 -)) ((eq c '0) '(0 0)) (t '(0 +)))) ))
    ((eq x '0) (cond ((eq y '-) (cond ((eq c '-) '(- +)) ((eq c '0) '(0 -)) (t '(0 0))))
                     ((eq y '0) (cond ((eq c '-) '(0 -)) ((eq c '0) '(0 0)) (t '(0 +))))
                     (       t  (cond ((eq c '-) '(0 0)) ((eq c '0) '(0 +)) (t '(+ -)))) ))
    (       t  (cond ((eq y '-) (cond ((eq c '-) '(0 -)) ((eq c '0) '(0 0)) (t '(0 +))))
                     ((eq y '0) (cond ((eq c '-) '(0 0)) ((eq c '0) '(0 +)) (t '(+ -))))
                     (       t  (cond ((eq c '-) '(0 +)) ((eq c '0) '(+ -)) (t '(+ 0)))) )) )))

; (label bit_add (lambda (x y c) (assoc-equal (cons x (list y c))
;     '(((0 0 0) (0 0))  ((0 0 1) (0 1))  ((0 1 0) (0 1))  ((0 1 1) (1 0))
;       ((1 0 0) (0 1))  ((1 0 1) (1 0))  ((1 1 0) (1 0))  ((1 1 1) (1 1))) )))

(label bit_add (lambda (x y c) (cond ((eq x  y) (list y c))
                                     ((eq c '0)     '(0 1))
                                     (       t      '(1 0)) )))

; params:   x: left addend, a trit
;           y: right addend, a trit
;          cs: sum of less significant digits, a bal3 with leading carry digit
; return:      new sum, a bal3 with leading carry digit
(label bal3_trits_add (lambda (x y cs)
    (append (trit_add x y (car cs)) (cdr cs)) ))

(label bin_bits_add (lambda (x y cs)
    (append (bit_add x y (car cs)) (cdr cs)) ))

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

(label bin_add_carrying (lambda (yr xr x y cs) (cond
    ((null (cdr x)) (cond  ; scanned to last digit of x: ready to add?
        ((null (cdr y)) (cond  ; scanned to last digit of y: ready to add.
            ((null yr) (cond  ; y's stack is empty
                ((null xr)  ; and x's stack is empty
                    ; add the respective final digits and that's all!
                    (bin_bits_add (car x) (car y) cs) )
                (t  ; only x's stack has digits: push a zero to y's
                    (bin_add_carrying '(0) xr x y cs) ) ))
            (t (cond  ; y's stack still has digits
                ((null xr)  ; only y's stack has digits: push a zero to x's
                    (bin_add_carrying yr '(0) x y cs) )
                (t  ; both x's and y's stacks have digits
                    (bin_add_carrying (cdr yr)
                                       (cdr xr)
                                       (cons (car xr) ())
                                       (cons (car yr) ())
                                           (bin_bits_add (car x)
                                                           (car y)
                                                            cs) )) )) ))

        ; y has more-significant digits that we need to stack up before adding
        (t (bin_add_carrying (cons (car y) yr) xr x (cdr y) cs)) ))
    ; x has more-significant digits that we need to stack up before adding
    (t (bin_add_carrying yr (cons (car x) xr) (cdr x) y cs)) )))

; Nonce function
(label discard_car_while_eq (lambda (x y) (cond
    ((null (cdr y))  y)  ; in my case I want at least one element
    ((eq x (car y)) (discard_car_while_eq x (cdr y)))
    (            t   y                              ) )))

; Add without removing leading zeroes from sum
(label bal3_add_denorm (lambda (x y)
    (bal3_add_carrying () () x y '(0)) ))

(label bin_add_denorm (lambda (x y)
    (bin_add_carrying () () x y '(0)) ))

(label bal3_add (lambda (x y)
    (discard_car_while_eq '0 (bal3_add_denorm x y)) ))

(label bin_add (lambda (x y)
    (discard_car_while_eq '0 (bin_add_denorm x y)) ))

; Balanced-ternary multiplication.

; Conveniently, multiplying a balanced ternary number by a trit
; gives (+) an identical result, (0) a zero result, or (-) a negated result.

(label trit_mult (lambda (x y) (cond ((eq x '0) '0)
                                     ((eq y '0) '0)
                                     ((eq x  y) '+)
                                     (       t  '-) )))

(label bit_mult (lambda (x y) (cond ((and (eq x '1) (eq y '1)) '1)
                                    (                       t  '0) )))

; params: x: left multiplicand, a bal3
;         y: right multiplicand, a trit
(label bal3_mult_trit (lambda (x y) (cond ((eq y '0) '(0))
                                          ((eq y '+)   x)
                                          (       t   (bal3_neg x)) )))

(label bin_mult_bit (lambda (x y) (cond ((eq y '0) '(0))
                                        (       t    x ) )))

; Balanced-ternary multiplication

(label bal3_mult (lambda (m n) ( bal3_mult_tritwise () m n '((0) ()) )))

(label bin_mult (lambda (m n) ( bin_mult_bitwise () m n '((0) ()) )))

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

(label bin_mult_bitwise (lambda (nr m n cp) (cond
    ((null (cdr n)) (cond
        ((null nr) (append (bin_add (car cp) (bin_mult_bit m (car n)))
                           (cadr cp)))  ; add carry digits to product; record all
        (       t  (bin_mult_bitwise (cdr nr)  ; load next digit of n
                                      m
                                     (cons (car nr) ())
                                     (bin_mult_bit_acc m (car n) cp) )) ))
    (           t  (bin_mult_bitwise (cons (car n) nr)  ; stack up digits of n
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

(label bin_mult_bit_regroup (lambda (pc1 cp0) (list
    (cdr pc1)  ; carry "c1" to add with next bin*bit product
    (cons (car pc1) (cadr cp0)) )))  ; prefix "p" to output digits "p0"

; params:  m: left multiplicand, a bal3
;          n: one digit of right multiplicand, a trit
;         cp: car: digits carried from sum of previous digit products, a bal3
;            cadr: digits completed from sum of previous digit products,
;                  a list of trit (difference from a bal3: can be empty)
; return:     car: digits carried from sum of digit products with carry
;            cadr: digits completed from sum of digit products
(label bal3_mult_trit_acc (lambda (m n cp0) (bal3_mult_trit_regroup
    (rotate-right (bal3_add_denorm (bal3_mult_trit m n) (car cp0)))
    cp0)))

(label bin_mult_bit_acc (lambda (m n cp0) (bin_mult_bit_regroup
    (rotate-right (bin_add_denorm (bin_mult_bit m n) (car cp0)))
    cp0)))
