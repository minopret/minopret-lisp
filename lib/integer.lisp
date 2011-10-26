; Arithmetic in classic (but lower-case) Lisp without using native numbers.
; Why without using native numbers? Um, for fun??
;
; And I heard that balanced ternary is nice (base 3 with digits -1 0 1
; instead of 0 1 2). So let's try doing math in balanced ternary!
;
; Ideally I'll also want conversion back and forth with
; decimal and hexadecimal.
;
; Representation: A balanced-ternary number is represented
; as a list whose elements are from the three atoms (+ 0 -).
; The atom + is a positive one digit. The atom - is a negative
; one digit. Digits are listed from most to least significant.
;
; Useful functions so far:
; trit^4->bal81 bal81->trit^4
; bal3-neg bal3-minus bal3-add bal3-mult bal3-lt bal3-gt
; bin-pred             bin-add  bin-mult
; dec-pred             dec-add
;
; Aaron Mansheim, 2011-09-24


; Nonce function
(label discard-car-while-eq (lambda (x y) (cond
    ((null (cdr y))  y)  ; in my uses I want at least one element
    ((eq x (car y)) (discard-car-while-eq x (cdr y)))
    ( t              y) )))


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
; bal3:  0 +   decimal: 0-1  #values incl. neg.:3; trits: 1;  0 bytes;  bits: 1
;       +- ++           2-4                     9   0     2                 2-3
;      +-- +++          5-13                   27   1     3                 3-4
;     +--- ++++        14-40                   81         4; bal81's: 1     5-6
;    +---- +++++       41-121                 243   2     5                 6-7
;   +----- ++++++     122-364                 729         6;  1 byte;       8-9
;  +------ +++++++    365-1093               2187   3     7                10-11
; +------- ++++++++  1094-3280               6561         8           2    11-12
;bal81:+-- +++       1123-265720           531441   6    12   2       3    18-19
;     +--- ++++    265721-21523360       43046721   7    16   3       4    24-25
;    +---- +++++ 21523361-1743392200   3486784401  10    20           5    30-31
;     etc. etc.1743392201-14214768240 282429536481 11    24   4       6    37-38
; NOTE: 2^31 = 2147483648
;                    etc. etc.               etc.  13    28   5       7    43-44
;                                                  15    32   6       8    49-50
;                                                  17    36   7       9    56-57
;                                                  19    40          10    62-63
;                                  digits base 10: 20    44   8      11    68-69


(label trit^4->bal81 (lambda (x) (assoc-equal x '(
    ((- - - -) -) ((- - - 0) <) ((- - - +) \)
    ((- - 0 -) [) ((- - 0 0) {) ((- - 0 +) z)
    ((- - + -) y) ((- - + 0) x) ((- - + +) w)
    ((- 0 - -) v) ((- 0 - 0) u) ((- 0 - +) t)
    ((- 0 0 -) s) ((- 0 0 0) r) ((- 0 0 +) q)
    ((- 0 + -) p) ((- 0 + 0) o) ((- 0 + +) n)
    ((- + - -) m) ((- + - 0) l) ((- + - +) k)
    ((- + 0 -) j) ((- + 0 0) i) ((- + 0 +) h)
    ((- + + -) g) ((- + + 0) f) ((- + + +) e)
    ((0 - - -) d) ((0 - - 0) c) ((0 - - +) b)
    ((0 - 0 -) a) ((0 - 0 0) ?) ((0 - 0 +) *)
    ((0 - + -) &) ((0 - + 0) ^) ((0 - + +) %)
    ((0 0 - -) $) ((0 0 - 0) #) ((0 0 - +) @)
    ((0 0 0 -) !) ((0 0 0 0) 0) ((0 0 0 +) 1)
    ((0 0 + -) 2) ((0 0 + 0) 3) ((0 0 + +) 4)
    ((0 + - -) 5) ((0 + - 0) 6) ((0 + - +) 7)
    ((0 + 0 -) 8) ((0 + 0 0) 9) ((0 + 0 +) A)
    ((0 + + -) B) ((0 + + 0) C) ((0 + + +) D)
    ((+ - - -) E) ((+ - - 0) F) ((+ - - +) G)
    ((+ - 0 -) H) ((+ - 0 0) I) ((+ - 0 +) J)
    ((+ - + -) K) ((+ - + 0) L) ((+ - + +) M)
    ((+ 0 - -) N) ((+ 0 - 0) O) ((+ 0 - +) P)
    ((+ 0 0 -) Q) ((+ 0 0 0) R) ((+ 0 0 +) S)
    ((+ 0 + -) T) ((+ 0 + 0) U) ((+ 0 + +) V)
    ((+ + - -) W) ((+ + - 0) X) ((+ + - +) Y)
    ((+ + 0 -) Z) ((+ + 0 0) }) ((+ + 0 +) ])
    ((+ + + -) >) ((+ + + 0) /) ((+ + + +) +) ))))


(label bal81->trit^4 (lambda (x) (assoc-equal x '(
    (- (- - - -)) (< (- - - 0)) (\ (- - - +))
    ([ (- - 0 -)) ({ (- - 0 0)) (z (- - 0 +))
    (y (- - + -)) (x (- - + 0)) (w (- - + +))
    (v (- 0 - -)) (u (- 0 - 0)) (t (- 0 - +))
    (s (- 0 0 -)) (r (- 0 0 0)) (q (- 0 0 +))
    (p (- 0 + -)) (o (- 0 + 0)) (n (- 0 + +))
    (m (- + - -)) (l (- + - 0)) (k (- + - +))
    (j (- + 0 -)) (i (- + 0 0)) (h (- + 0 +))
    (g (- + + -)) (f (- + + 0)) (e (- + + +))
    (d (0 - - -)) (c (0 - - 0)) (b (0 - - +))
    (a (0 - 0 -)) (? (0 - 0 0)) (* (0 - 0 +))
    (& (0 - + -)) (^ (0 - + 0)) (% (0 - + +))
    (s (0 0 - -)) (# (0 0 - 0)) (@ (0 0 - +))
    (! (0 0 0 -)) (0 (0 0 0 0)) (1 (0 0 0 +))
    (2 (0 0 + -)) (3 (0 0 + 0)) (4 (0 0 + +))
    (5 (0 + - -)) (6 (0 + - 0)) (7 (0 + - +))
    (8 (0 + 0 -)) (9 (0 + 0 0)) (A (0 + 0 +))
    (B (0 + + -)) (C (0 + + 0)) (D (0 + + +))
    (E (+ - - -)) (F (+ - - 0)) (G (+ - - +))
    (H (+ - 0 -)) (I (+ - 0 0)) (J (+ - 0 +))
    (K (+ - + -)) (L (+ - + 0)) (M (+ - + +))
    (N (+ 0 - -)) (O (+ 0 - 0)) (P (+ 0 - +))
    (Q (+ 0 0 -)) (R (+ 0 0 0)) (S (+ 0 0 +))
    (T (+ 0 + -)) (U (+ 0 + 0)) (V (+ 0 + +))
    (W (+ + - -)) (X (+ + - 0)) (Y (+ + - +))
    (Z (+ + 0 -)) (} (+ + 0 0)) (] (+ + 0 +))
    (> (+ + + -)) (/ (+ + + 0)) (+ (+ + + +)) ))))


; Balanced-ternary subtraction reduces easily to addition.

(label trit-neg (lambda (x) (assoc x '( (+ -) (0 0) (- +) ) )))


; near-miss tail call
(label bal3-neg (lambda (x) (cond
    ((null x)  ())
    ( t        (cons (trit-neg (car x)) (bal3-neg (cdr x)))) )))


(label bal3-minus (lambda (x y) (bal3-add x (bal3-neg y))))


(label dec-digit-pred (lambda (x) (assoc x
    '((1 0) (2 1) (3 2) (4 3) (5 4) (6 5) (7 6) (8 7) (9 8) (0 9)) )))


(label dec-pred (lambda (x) (cond
    ((eq x '(0)) '(0))  ; +0. - +1. := +0. because we can't go lower
    ( t            (discard-car-while-eq '() (cadr (dec-pred-rec x)))) )))


(label dec-pred-rec (lambda (x) (cond
    ((null (cdr x)) (cond
        ((eq (car x) '0) '(1 (9)))
        ( t               (list '0 (cons (dec-digit-pred (car x)) ()))) ))
    ( t            (dec-pred-borrow (car x) (dec-pred-rec (cdr x)))) )))


(label dec-pred-borrow (lambda (x y) (cond
    ((eq (car y) '0) (list '0 (cons  x (cadr y))))     ; ( x + -0):y = -0: x:y
    ((eq      x  '0) (list '1 (cons '9 (cadr y))))     ; (+0 + -1):y = -1:+1:y
    ( t              (list '0 (cons (dec-digit-pred x)
                              (cadr y) ))) )))     ; ( x + -1):y = -0:(x-1):y


; Balanced-ternary comparison can correctly reduce to subtraction
; although most times it wouldn't require that exactness.

; Assuming normalized so that the lead digit is zero if, and only if,
; that is the only digit.
(label bal3-lt0 (lambda (x) (eq (car x) '-)))


(label bal3-gt0 (lambda (x) (eq (car x) '+)))


(label bal3-lt (lambda (x y) (bal3-lt0 (bal3-minus x y))))


(label bal3-gt (lambda (x y) (bal3-gt0 (bal3-minus x y))))


; Balanced-ternary addition. No problem...?

; What operations would we need in order to reduce the
; many cases of adding three balanced-ternary digits
; to just a few base cases?
;
;                 0 0 +          : To reduce these, negate each digit.
;                 0 + 0          : To reduce these, negate each digit.
;         0 + +   - + +   0 + -  : To reduce these, negate each digit.
;         + 0 +   + - +   + - 0  : To reduce these, negate each digit.
;                 + + -   + 0 -  : To reduce these, negate each digit.
; + + +   + + 0   + 0 0          : To reduce these, negate each digit.
;
;                 0 0 -          : To reduce these, sort digits: - 0 +
;                 0 - 0          : To reduce these, sort digits: - 0 +
;         0 - -   + - -   0 - +  : To reduce these, sort digits: - 0 +
;         - 0 -   - + -   - + 0  : To reduce these, sort digits: - 0 +
;                 - - +   - 0 +  : To reduce these, cancel a minus with a plus.
; - - -   - - 0   - 0 0   0 0 0  : These are base cases.
;
;   - 0     - +     0 -     0 0  : Here are the results for each base case.


; Hmm, the above method of reducing cases is interesting,
; but I'm not convinced to code it.


; Let's write balanced-ternary digit addition as a lookup table.
;
; params:   x: left addend, a trit
;           y: right addend, a trit
;           c: carry digit, a trit
; return: car: new carry digit, a trit
;        cadr: result digit, a trit
(label trit-add (lambda (x y c) (assoc c (assoc y (assoc x
    '((- ((- ((- (- 0)) (0 (- +)) (+ (0 -))))
          (0 ((- (- +)) (0 (0 -)) (+ (0 0))))
          (+ ((- (0 -)) (0 (0 0)) (+ (0 +)))) ))

      (0 ((- ((- (- +)) (0 (0 -)) (+ (0 0))))
          (0 ((- (0 -)) (0 (0 0)) (+ (0 +))))
          (+ ((- (0 0)) (0 (0 +)) (+ (+ -)))) ))

      (+ ((- ((- (0 -)) (0 (0 0)) (+ (0 +))))
          (0 ((- (0 0)) (0 (0 +)) (+ (+ -))))
          (+ ((- (0 +)) (0 (+ -)) (+ (+ 0)))) )) ) )))))


; We can easily write a lookup table to add two decimal digits.
(label dec-digit-add-pair (lambda (x y) (assoc y (assoc x
    '((0 ((0 (0 0)) (1 (0 1)) (2 (0 2)) (3 (0 3)) (4 (0 4))
          (5 (0 5)) (6 (0 6)) (7 (0 7)) (8 (0 8)) (9 (0 9)) ))
      (1 ((0 (0 1)) (1 (0 2)) (2 (0 3)) (3 (0 4)) (4 (0 5))
          (5 (0 6)) (6 (0 7)) (7 (0 8)) (8 (0 9)) (9 (1 0)) ))
      (2 ((0 (0 2)) (1 (0 3)) (2 (0 4)) (3 (0 5)) (4 (0 6))
          (5 (0 7)) (6 (0 8)) (7 (0 9)) (8 (1 0)) (9 (1 1)) ))
      (3 ((0 (0 3)) (1 (0 4)) (2 (0 5)) (3 (0 6)) (4 (0 7))
          (5 (0 8)) (6 (0 9)) (7 (1 0)) (8 (1 1)) (9 (1 2)) ))
      (4 ((0 (0 4)) (1 (0 5)) (2 (0 6)) (3 (0 7)) (4 (0 8))
          (5 (0 9)) (6 (1 0)) (7 (1 1)) (8 (1 2)) (9 (1 3)) ))
      (5 ((0 (0 5)) (1 (0 6)) (2 (0 7)) (3 (0 8)) (4 (0 9))
          (5 (1 0)) (6 (1 1)) (7 (1 2)) (8 (1 3)) (9 (1 4)) ))
      (6 ((0 (0 6)) (1 (0 7)) (2 (0 8)) (3 (0 9)) (4 (1 0))
          (5 (1 1)) (6 (1 2)) (7 (1 3)) (8 (1 4)) (9 (1 5)) ))
      (7 ((0 (0 7)) (1 (0 8)) (2 (0 9)) (3 (1 0)) (4 (1 1))
          (5 (1 2)) (6 (1 3)) (7 (1 4)) (8 (1 5)) (9 (1 6)) ))
      (8 ((0 (0 8)) (1 (0 9)) (2 (1 0)) (3 (1 1)) (4 (1 2))
          (5 (1 3)) (6 (1 4)) (7 (1 5)) (8 (1 6)) (9 (1 7)) ))
      (9 ((0 (0 9)) (1 (1 0)) (2 (1 1)) (3 (1 2)) (4 (1 3))
          (5 (1 4)) (6 (1 5)) (7 (1 6)) (8 (1 7)) (9 (1 8)) )) ) ))))
 

; The following function dec-digit-add adds x+y+c.
; It's a bit complicated, so it deserves a diagram:
;
; x-u----u1-w-w1: discarded: always 0
; +/ \   + / \
; y  u0  v1   w0  )
;    + \ /        > output digits (w0 v0). Note, w0 can be zero.
; c--c--v-----v0  )

(label dec-digit-add (lambda (x y c)
    (   (lambda (u1-v1-v0) (list
            (cadr (dec-digit-add-pair (car u1-v1-v0) (cadr u1-v1-v0)))
            (caddr u1-v1-v0) ))
        (   (lambda (u1-u0 c) (cons (car u1-u0)
                                    (dec-digit-add-pair (cadr u1-u0) c) ))
            (dec-digit-add-pair x y)
             c ) ) ))


; params:   x: left addend, a trit
;           y: right addend, a trit
;          cs: sum of less significant digits, a bal3 with leading carry digit
; return:      new sum, a bal3 with leading carry digit
(label bal3-trits-add (lambda (x y cs)
    (append (trit-add x y (car cs)) (cdr cs)) ))


; near-miss self-tail call
(label dec-digits-add (lambda (x y cs)
    (append (dec-digit-add x y (car cs)) (cdr cs)) ))



; The following state machine could be factored and optimized.
;
; params:  yr: reversed more significant digits for y, initially ()
;          xr: reversed more significant digits for x, initially ()
;           x: left addend, a bal3
;           y: right addend, a bal3
;          cs: sum of less significant digits, a bal3 with leading carry digit
; return:      new sum, a bal3 with leading carry digit
(label bal3-add-carrying (lambda (yr xr x y cs) (cond
    ((null (cdr x)) (cond       ; scanned to last digit of x: ready to add?
        ((null (cdr y)) (cond   ; scanned to last digit of y: ready to add.
            ((null yr) (cond    ; y's stack is empty
                ((null xr)      ; and x's stack is empty
                        ; add the respective final digits and that's all!
                    (bal3-trits-add (car x) (car y) cs) )
                ( t     ; only x's stack has digits: push a zero to y's
                    (bal3-add-carrying '(0) xr x y cs) ) ))
            ( t (cond   ; y's stack still has digits
                ((null xr)  ; only y's stack has digits: push a zero to x's
                    (bal3-add-carrying yr '(0) x y cs) )
                ( t     ; both x's and y's stacks have digits
                    (bal3-add-carrying (cdr yr)
                                       (cdr xr)
                                       (cons (car xr) ())
                                       (cons (car yr) ())
                                       (bal3-trits-add (car x)
                                                       (car y)
                                                        cs) )) )) ))

        ; y has more-significant digits that we need to stack up before adding
        ( t (bal3-add-carrying (cons (car y) yr) xr x (cdr y) cs)) ))
    ; x has more-significant digits that we need to stack up before adding
    ( t (bal3-add-carrying yr (cons (car x) xr) (cdr x) y cs)) )))


(label dec-add-carrying (lambda (yr xr x y cs) (cond
    ((null (cdr x)) (cond       ; scanned to last digit of x: ready to add?
        ((null (cdr y)) (cond   ; scanned to last digit of y: ready to add.
            ((null yr) (cond    ; y's stack is empty
                ((null xr)      ; and x's stack is empty
                    ; add the respective final digits and that's all!
                    (dec-digits-add (car x) (car y) cs) )
                ( t             ; only x's stack has digits: push a zero to y's
                    (dec-add-carrying '(()) xr x y cs) ) ))
            ( t (cond           ; y's stack still has digits
                ((null xr)      ; only y's stack has digits: push a zero to x's
                    (dec-add-carrying yr '(()) x y cs) )
                ( t             ; both x's and y's stacks have digits
                    (dec-add-carrying (cdr yr)
                                      (cdr xr)
                                      (cons (car xr) ())
                                      (cons (car yr) ())
                                      (dec-digits-add (car x)
                                                    (car y)
                                                     cs    ) ) ) )) ))

        ; y has more-significant digits that we need to stack up before adding
        ( t (dec-add-carrying (cons (car y) yr) xr x (cdr y) cs)) ))
    ; x has more-significant digits that we need to stack up before adding
    ( t (dec-add-carrying yr (cons (car x) xr) (cdr x) y cs)) )))


; Add without removing leading zeroes from sum
(label bal3-add-denorm (lambda (x y)
    (bal3-add-carrying () () x y '(0)) ))


(label dec-add-denorm (lambda (x y) (dec-add-carrying () () x y '(0)) ))


(label bal3-add (lambda (x y)
    (discard-car-while-eq '0 (bal3-add-denorm x y)) ))


(label dec-add (lambda (x y)
    (discard-car-while-eq '0 (dec-add-denorm x y)) ))


; Balanced-ternary multiplication.

; Conveniently, multiplying a balanced ternary number by a trit
; gives (+) an identical result, (0) a zero result, or (-) a negated result.

(label trit-mult (lambda (x y) (cond ((eq x '0) '0)
                                     ((eq y '0) '0)
                                     ((eq x  y) '+)
                                     ( t        '-) )))


(label dec-digit-mult (lambda (x y) (assoc y (assoc x '(
    (0 ((0 (0 0)) (1 (0 0)) (2 (0 0)) (3 (0 0)) (4 (0 0))
        (5 (0 0)) (6 (0 0)) (7 (0 0)) (8 (0 0)) (9 (0 0)) ))
    (1 ((0 (0 0)) (1 (0 1)) (2 (0 2)) (3 (0 3)) (4 (0 4))
        (5 (0 5)) (6 (0 6)) (7 (0 7)) (8 (0 8)) (9 (0 9)) ))
    (2 ((0 (0 0)) (1 (0 2)) (2 (0 4)) (3 (0 6)) (4 (0 8))
        (5 (1 0)) (6 (1 2)) (7 (1 4)) (8 (1 6)) (9 (1 8)) ))
    (3 ((0 (0 0)) (1 (0 3)) (2 (0 6)) (3 (0 9)) (4 (1 2))
        (5 (1 5)) (6 (1 8)) (7 (2 1)) (8 (2 4)) (9 (2 7)) ))
    (4 ((0 (0 0)) (1 (0 4)) (2 (0 8)) (3 (1 2)) (4 (1 6))
        (5 (2 0)) (6 (2 4)) (7 (2 8)) (8 (3 2)) (9 (3 6)) ))
    (5 ((0 (0 0)) (1 (0 5)) (2 (1 0)) (3 (1 5)) (4 (2 0))
        (5 (2 5)) (6 (3 0)) (7 (3 5)) (8 (4 0)) (9 (4 5)) ))
    (6 ((0 (0 0)) (1 (0 6)) (2 (1 2)) (3 (1 8)) (4 (2 4))
        (5 (3 0)) (6 (3 6)) (7 (4 2)) (8 (4 8)) (9 (5 4)) ))
    (7 ((0 (0 0)) (1 (0 7)) (2 (1 4)) (3 (2 1)) (4 (2 8))
        (5 (3 5)) (6 (4 2)) (7 (4 9)) (8 (5 6)) (9 (6 3)) ))
    (8 ((0 (0 0)) (1 (0 8)) (2 (1 6)) (3 (2 4)) (4 (3 2))
        (5 (4 0)) (6 (4 8)) (7 (5 6)) (8 (6 4)) (9 (7 2)) ))
    (9 ((0 (0 0)) (1 (0 9)) (2 (1 8)) (3 (2 7)) (4 (3 6))
        (5 (4 5)) (6 (5 4)) (7 (6 3)) (8 (7 2)) (9 (8 1)) )) )))))


; params: x: left multiplicand, a bal3
;         y: right multiplicand, a trit
(label bal3-mult-trit (lambda (x y) (cond ((eq y '0) '(0))
                                          ((eq y '+)   x)
                                          ( t         (bal3-neg x)) )))


; Balanced-ternary multiplication

(label bal3-mult (lambda (m n) ( bal3-mult-tritwise () m n '((0) ()) )))


; The following state machine could be factored and optimized.
;
; params: nr: reversed higher digits of right multiplicand
;          m: left multiplicand
;          n: lower digits of right multiplicand
;         cp: car: digits carried from sum of previous digit products
;            cadr: digits completed from sum of previous digit products
(label bal3-mult-tritwise (lambda (nr m n cp) (cond
    ((null (cdr n)) (cond
        ((null nr) (append
            (bal3-add (car cp) (bal3-mult-trit m (car n)))
            (cadr cp) ))  ; add carry digits to product; record all
        ( t        (bal3-mult-tritwise (cdr nr)  ; load next digit of n
                                        m
                                       (cons (car nr) ())
                                       (bal3-mult-trit-acc m (car n) cp) )) ))
    ( t            (bal3-mult-tritwise (cons (car n) nr)  ; stack digits of n
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

(label bal3-mult-trit-regroup (lambda (pc1 cp0) (list
    (cdr pc1)  ; carry "c1" to add with next bal3*trit product
    (cons (car pc1) (cadr cp0)) )))  ; prefix "p" to output digits "p0"


; params:  m: left multiplicand, a bal3
;          n: one digit of right multiplicand, a trit
;         cp: car: digits carried from sum of previous digit products, a bal3
;            cadr: digits completed from sum of previous digit products,
;                  a list of trit (difference from a bal3: can be empty)
; return:     car: digits carried from sum of digit products with carry
;            cadr: digits completed from sum of digit products
(label bal3-mult-trit-acc (lambda (m n cp0) (bal3-mult-trit-regroup
    (rotate-right (bal3-add-denorm (bal3-mult-trit m n) (car cp0)))
     cp0)))


; Unsigned binary subtraction will be zero when the minuend is greater.
; No implementation yet.

; The predecessor function for unsigned arbitrary-precision binary numbers.
; Here we pay a price for storing the most-significant bit first.
; tail call: discard-car-while-eq
(label bin-pred (lambda (x) (cond
    (   (eq x '(()))
       '(()))  ; +0; - +1; := +0; because we can't go lower
    (    t            
        (discard-car-while-eq '() (cadr (
            (label bin-pred-rec (lambda (x) (cond
                (   (eq x '(())) '( t ( t)))      ; borrow: +0 - +1 == -1:+1
                (   (eq x '( t)) '(() (())))      ; cancel: +1 - +1 == -0:+0
                (    t (
                    (lambda (x y) (cond
                        ((eq (car y) ()) (list () (cons  x (cadr y))))
                        ((eq      x   t) (list () (cons () (cadr y))))
                        ( t              (list  t (cons  t (cadr y)))) ))
                    (car x)
                    (bin-pred-rec (cdr x)) ) ) )))  ; FIXME not tail recursive
             x ))) ) )))


; Now binary digits. First let's write addition as an operation table.
; (label bit-add (lambda (x y c) (assoc-equal (cons x (list y c))
;     '(((0 0 0) (0 0))  ((0 0 1) (0 1))  ((0 1 0) (0 1))  ((0 1 1) (1 0))
;       ((1 0 0) (0 1))  ((1 0 1) (1 0))  ((1 1 0) (1 0))  ((1 1 1) (1 1))) )))


; params: x and y, two more significant bits
;         car cs, a carry bit from less significant addition;
;                 or a zero bit, if no less significant addition occurred.
;         cdr cs, a binary number, the sum of less significant addition,
;                 possibly including one or more leading zero bits;
;                 or an empty list, if no less significant addition occurred.
; return: a binary number that has the bits of the sum of x, y, and car cs;
;         followed by the bits of cdr cs.
(label bin-bits-add (lambda (x y cs)
    (append
        (
            ; This function adds two bits and a carry bit with only one "cond".
            (lambda (x y c) (cond
                ((eq x  y) (list  y  c))
                ((eq c ())     '(()  t))
                ( t            '( t ())) ))
             x y (car cs) )
        (cdr cs) ) ))


; params: xr and yr, two reversed binary numbers
;         car cs, a carry bit from less significant addition
;         cdr cs, a binary number, the sum of less significant addition
; return: a binary number that has the bits of the sum of
;         the reverse of xr, the reverse of yr, and car cs;
;         followed by the bits of cadr cs.
(label bin-add-carrying (lambda (yr xr cs) (cond
    ((null  yr) (cond   ; y has no more bits
        ((null xr) cs)  ; ...and x has no more bits. Done.
        ( t             ; Only x has more bits: extend y with a zero.
            (bin-add-carrying '(()) xr cs) ) ))
    ( t (cond           ; y has more bits
        ((null xr)      ; ...and x has no more bits. Extend x with a zero.
            (bin-add-carrying yr '(()) cs) )
        ( t             ; Both x and y have more bits.
            (bin-add-carrying
                (cdr yr)
                (cdr xr)
                (bin-bits-add
                    (car xr)
                    (car yr)
                     cs ) ) ) )) )))


(label bin-add-denorm (lambda (x y)
    (bin-add-carrying (reverse y) (reverse x) '(())) ))


(label bin-add (lambda (x y)
    (discard-car-while-eq () (bin-add-denorm x y)) ))


(label bit-mult (lambda (x y) (cond ((and (eq x t) (eq y t))  t)
                                    ( t                      ()) )))


(label bin-mult-bit (lambda (x y) (cond ((eq y ()) '(()))
                                        ( t           x ) )))


(label bin-mult (lambda (m n) (
    (label bin-mult-bitwise (lambda (nr m cp0) (cond
        (   (null   (cdr nr))
            (append (bin-add (car cp0) (bin-mult-bit m (car nr))) (cadr cp0)) )
        (    t
            (bin-mult-bitwise (cdr nr) m (
                (lambda (pc1) (list (cdr pc1)
                                    (cons (car pc1) (cadr cp0)) ))
                (rotate-right (bin-add-denorm (bin-mult-bit m (car nr))
                                              (car cp0) )) )) ) )))
    (reverse n) m '((()) ()) )))
