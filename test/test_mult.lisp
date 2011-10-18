
; (15 * 1) - 5 == 10; record a 1 and carry 27/3 == 9
(assert-equal (bal3-mult-trit-acc '(+ - - 0) '+ '((- + +) (s)))
             '((0 0 + 0) (+ s)) )
; cp1 := (bal3-add-denorm (bal3-mult-trit '(+ - - 0) '+) '(- + +))
;     == (bal3-add-denorm '(+ - - 0) '(- + +))
;     == '(0 + 0 +)
; pc1 := (rotate-right '(0 + 0 +))
;     == '(+ 0 + 0)
;   p := (cons '+ (s))
;     == '(+ s)
; ret := '((0 + 0) (+ s))

; (15 * -1) - 5 == -20; record a 1 and carry -21/3 == -7
(assert-equal (bal3-mult-trit-acc '(+ - - 0) '- '((- + +) (s)))
             '((0 - + -) (+ s)) )

; (15 * 0) - 5 == -5; record a 1 and carry -6/3 == -2
(assert-equal (bal3-mult-trit-acc '(+ - - 0) '0 '((- + +) (s)))
             '((0 - +) (+ s)) )

; 15 * 22 = (27 - 9 - 3) * (27 - 9 + 3 + 1) = 330 = 243 + 81 + 9 - 3
(assert-equal (bal3-mult '(+ - - 0) '(+ - + +)) '(+ + 0 + - 0))
;        + - - 0
;        + - + +
;        =======
;        + - - 0
;      + - - 0
;    - + + 0
;  + - - 0
;  =============
;    + + 0 + - 0

(assert-equal (bal3-mult '(+) '(+ -)) '(+ -))
(assert-equal (bal3-mult '(+ -) '(+ 0)) '(+ - 0))
(assert-equal (bal3-mult '(+ - 0) '(+ +)) '(+ 0 - 0))
(assert-equal (bal3-mult '(+ 0 - 0) '(+ - -)) '(+ + + + 0))
