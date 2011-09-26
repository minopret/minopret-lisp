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
; Aaron Mansheim, 2011-09-24



; Put this in a standard library

(label equal (lambda (x y) (cond
    ((atom x) (cond ((and (atom y) (eq x y)) t) (t ())))
    (t (cond ((atom y) ())
             (t (and (equal (car x) (car y)) (equal (cdr x) (cdr y)))) )) )))



; hex_mult_3: This would assist computing a ternary digit value
; a_i*3^i in hex. Using this table, it's easy: 1 3 9 1B 51 F3 2D9 88B 19A1 ...
; Just requires the ability to carry lead digits 0, 1, & 2 from this table.
; But to sum up a ternary number (a_i * 3^i) would require the ability to
; add any hex digits together.

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

; Add two hex numbers by reducing to balanced ternary arithmetic.
(label hex_add (lambda (x y) (bal3_to_hex (bal3_add (hex_to_bal3 x) (hex_to_bal3 y)))))

(label hex_to_trit (lambda (x) (cond
  ((eq x '0) '(0 0 0 0))  ((eq x '1) '(0 0 0 +))  ((eq x '2) '(0 0 + -))
  ((eq x '3) '(0 0 + 0))  ((eq x '4) '(0 0 + +))  ((eq x '5) '(0 + - -))
  ((eq x '6) '(0 + - 0))  ((eq x '7) '(0 + - +))  ((eq x '8) '(0 + 0 -))
  ((eq x '9) '(0 + 0 0))  ((eq x 'A) '(0 + 0 +))  ((eq x 'B) '(0 + + -))
  ((eq x 'C) '(0 + + 0))  ((eq x 'D) '(0 + + +))  ((eq x 'E) '(+ - - -))
  ((eq x 'F) '(+ - - 0))
)))

; for hex_to_bal3 and bal3_to_hex we have a bunch of work ahead.



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

(label trit_add_carrying (lambda (x y c) (cond
    ((eq c '0) (trit_add  x y))
    ((eq c '+) (trit_add+ x y))
    (       t  (trit_add- x y))
)))

; nonce functions
(label list_car_cdr (lambda (x) (list (car x) (cdr x))))
(label suffix_cadr (lambda (x y) (list (car x) (append (cadr x) y) )))
;unused I think:
;;(label list_cdr_car (lambda (x) (list (cdr x) (car x))))
;;(label suffix_car (lambda (x y) (cons (append (car y) x) (cdr y))))

; params:   x: left addend, a trit
;           y: right addend, a trit
;           c: carry digit, a trit
;           s: sum of less significant digits without carry, a bal3
; return: car: new carry digit, a trit
;        cadr: new sum without carry, a bal3
(label bal3_trit_add (lambda (x y c s)
    (suffix_cadr s (list_car_cdr (trit_add_carrying x y c))) ))

;; Work in progress
; Wow, this could end up slower than the Ackermann function.
; I hope I can revise it for reasonable speed.
;
; params:  yr: reversed higher digits for y, initially ()
;          xr: reversed higher digits for x, initially ()
;           x: left addend, a bal3
;           y: right addend, a bal3
;           c: carry digit, a trit
;           s: old sum with carry, a bal3
; return: car: carry digit, a trit
;        cadr: new sum without carry, a bal3
;;(label bal3_add_carrying (lambda (yr xr x y c s) (cond
;;    ((null (cdr x)) (cond
;;        ((null (cdr y)) ...(bal3_trit_add (car x) (car y) c s)...)
;;        (            t  ......


;; Reasons why bal3_add, bal3_acc, etc. are to be removed
;(bal3_add '(+ - - 0) '(+ 0 - -))   ; doesn't work
;(bal3_add '(0) '(-))   ; doesn't work
; (bal3_acc '(0 - - +) '(- - 0 +) '0 '()) ; doesn't work sensibly
; ==> (('-', '-', '+'), ('-', '0', '+'), '0', ('-',))
; (equal (bal3_acc '(0 - - +) '(- - 0 +) '0 '()) '(+ (-)))

;; To be removed
;;(label bal3_add (lambda (x y) (bal3_add_carrying x y '() '())))

;; To be removed
; Loop for balanced-ternary addition.
;
; params: x: least significant digits of left addend
;         y: least significant digits of right addend
;      msxr: most significant digits of left addend, in reverse order, initially null
;      msyr: most significant digits of right addend, in reverse order, initially null
; return: car: + if carry to next digit, 0 if not;
;         cadr: list of computed least significant digits
;         cddr: null

;;(label bal3_add_carrying (lambda (x y msxr msyr) (cond
;;  ((null (cdr x)) (cond ( (null (cdr y))
;;                          (bal3_acc (cons (car x) msxr)
;;                                    (cons (car y) msyr) '0 ()) )
;;                        (  t
;;                          (bal3_add_carrying x (cdr y)
;;                             msxr (cons (car y) msyr))) ))
;;              (t  (cond ( (null (cdr y))
;;                          (bal3_add_carrying (cdr x) y
;;                            (cons (car x) msxr) msyr) )
;;                        (  t
;;                          (bal3_add_carrying (cdr x) (cdr y)
;;                            (cons (car x) msxr) (cons (car y) msyr) ) ) )) )))

;; To be removed
; Technical function to add the next leftward pair of digits in balanced ternary addition.
;
; params: xr: leftward digits of left addend, listed from least to most significant;
;         yr: leftward digits of right addend, listed from least to most significant,
;             with same place value as xr;
;          c: carry digit (0 or +);
;          s: the sum so far;
; returns: car: the next carry digit (0 or +);
;          cdr: new sum: the next sum digit for x & y, prepended to s

;;(label bal3_acc (lambda (xr yr c s) (cond
;;  ((null xr) (cond ((null yr) (list c s))
;;                   ((eq c '0) (bal3_acc xr (cdr yr) '0 (cons (car yr) s)))
;;                   (       t  (bal3_acc '(+) (cdr yr) '0 s)) ))
;;  (       t  (cond ((null yr) (bal3_acc xr (cons c ()) '0 s))
;;                   (       t  (bal3_regroup (cdr xr) (cdr yr)
;;                                            (cond ((eq c '0) (trit_add  (car xr) (car yr)))
;;                                                  (       t  (trit_add+ (car xr) (car yr))) )
;;                                             s)) )) )))

;; To be removed
; Technical function to assist carrying in balanced ternary addition.
;  params:  xr: reversed remaining more significant digits of left addend
;           yr: reversed remaining more significant digits of right addend,
;               with same place value as xr
;          cs1: the carry digit and result digit from the latest digit sum
;           s0: the sum of the less significant digits
; returns: car: xr (unchanged)
;         cadr: yr (unchanged)
;        caddr: carry digit (0 or 1);
;        cdddr: prepend non-carry digits to the previous sum
;;(label bal3_regroup (lambda (xr yr cs1 s0)
;;  (append (list xr yr) (list (car cs1) (append (cdr cs1) s0))) ))



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



; Note at this point that, in this representation,
; shifting a number left or right to multiply or divide by 3
; is actually NOT quick and NOT easy because we put the
; least significant digit last.
; I suppose that's the price of easier readability and carrying.



; automatic unit tests

(equal (bal3_neg '(- + + - 0 0 0 - + + -))
                 '(+ - - + 0 0 0 + - - +))
(equal (trit_add- '- '-) '(- 0))
(equal (trit_add- '- '0) '(- +))
(equal (trit_add- '- '+) '(0 -))
(equal (trit_add- '0 '-) '(- +))
(equal (trit_add- '0 '0) '(0 -))
(equal (trit_add- '0 '+) '(0 0))
(equal (trit_add- '+ '-) '(0 -))
(equal (trit_add- '+ '0) '(0 0))
(equal (trit_add- '+ '+) '(0 +))
(equal (trit_add  '- '-) '(- +))
(equal (trit_add  '- '0) '(0 -))
(equal (trit_add  '- '+) '(0 0))
(equal (trit_add  '0 '-) '(0 -))
(equal (trit_add  '0 '0) '(0 0))
(equal (trit_add  '0 '+) '(0 +))
(equal (trit_add  '+ '-) '(0 0))
(equal (trit_add  '+ '0) '(0 +))
(equal (trit_add  '+ '+) '(+ -))
(equal (trit_add+ '- '-) '(0 -))
(equal (trit_add+ '- '0) '(0 0))
(equal (trit_add+ '- '+) '(0 +))
(equal (trit_add+ '0 '-) '(0 0))
(equal (trit_add+ '0 '0) '(0 +))
(equal (trit_add+ '0 '+) '(+ -))
(equal (trit_add+ '+ '-) '(0 +))
(equal (trit_add+ '+ '0) '(+ -))
(equal (trit_add+ '+ '+) '(+ 0))


