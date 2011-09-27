; Tests of balanced-ternary arithmetic including
; conversion with decimal and hexadecimal.
;
; Utilities with a temporary home here: equal assert_equal
;
; Aaron Mansheim, 2011-09-26



; Put this stuff in a standard library (used here in automated unit tests)

; Standard: Common Lisp. Probably all Schemes and all Lisps since 1.5.
(label equal (lambda (x y) (cond
    ((atom x) (cond ((and (atom y) (eq x y)) t) (t ())))
    (t (cond ((atom y) ())
             (t (and (equal (car x) (car y)) (equal (cdr x) (cdr y)))) )) )))

; Standard: none. Roughly similar functionality to lisp-unit.
(label assert_equal (lambda (x y) (cond
    ((equal x y) t)
    (t (append (list 'Expecting y) (list 'found x))) )))



(assert_equal (trit_add- '- '-) '(- 0))
(assert_equal (trit_add- '- '0) '(- +))
(assert_equal (trit_add- '0 '-) '(- +))
(assert_equal (trit_add  '- '-) '(- +))
(assert_equal (trit_add- '- '+) '(0 -))
(assert_equal (trit_add- '0 '0) '(0 -))
(assert_equal (trit_add- '+ '-) '(0 -))
(assert_equal (trit_add  '- '0) '(0 -))
(assert_equal (trit_add  '0 '-) '(0 -))
(assert_equal (trit_add+ '- '-) '(0 -))
(assert_equal (trit_add- '0 '+) '(0 0))
(assert_equal (trit_add- '+ '0) '(0 0))
(assert_equal (trit_add  '- '+) '(0 0))
(assert_equal (trit_add  '0 '0) '(0 0))
(assert_equal (trit_add  '+ '-) '(0 0))
(assert_equal (trit_add+ '- '0) '(0 0))
(assert_equal (trit_add+ '0 '-) '(0 0))
(assert_equal (trit_add- '+ '+) '(0 +))
(assert_equal (trit_add  '0 '+) '(0 +))
(assert_equal (trit_add  '+ '0) '(0 +))
(assert_equal (trit_add+ '- '+) '(0 +))
(assert_equal (trit_add+ '0 '0) '(0 +))
(assert_equal (trit_add+ '+ '-) '(0 +))
(assert_equal (trit_add  '+ '+) '(+ -))
(assert_equal (trit_add+ '0 '+) '(+ -))
(assert_equal (trit_add+ '+ '0) '(+ -))
(assert_equal (trit_add+ '+ '+) '(+ 0))

; tests of trit_add_carrying x y c
(assert_equal (trit_add_carrying '- '- '-) '(- 0))
(assert_equal (trit_add_carrying '- '- '0) '(- +))
(assert_equal (trit_add_carrying '- '0 '-) '(- +))
(assert_equal (trit_add_carrying '0 '- '-) '(- +))
(assert_equal (trit_add_carrying '- '- '+) '(0 -))
(assert_equal (trit_add_carrying '- '0 '0) '(0 -))
(assert_equal (trit_add_carrying '- '+ '-) '(0 -))
(assert_equal (trit_add_carrying '0 '- '0) '(0 -))
(assert_equal (trit_add_carrying '0 '0 '-) '(0 -))
(assert_equal (trit_add_carrying '+ '- '-) '(0 -))
(assert_equal (trit_add_carrying '- '0 '+) '(0 0))
(assert_equal (trit_add_carrying '- '+ '0) '(0 0))
(assert_equal (trit_add_carrying '0 '- '+) '(0 0))
(assert_equal (trit_add_carrying '0 '0 '0) '(0 0))
(assert_equal (trit_add_carrying '0 '+ '-) '(0 0))
(assert_equal (trit_add_carrying '+ '0 '-) '(0 0))
(assert_equal (trit_add_carrying '+ '- '0) '(0 0))
(assert_equal (trit_add_carrying '- '+ '+) '(0 +))
(assert_equal (trit_add_carrying '0 '0 '+) '(0 +))
(assert_equal (trit_add_carrying '0 '+ '0) '(0 +))
(assert_equal (trit_add_carrying '+ '- '+) '(0 +))
(assert_equal (trit_add_carrying '+ '0 '0) '(0 +))
(assert_equal (trit_add_carrying '+ '+ '-) '(0 +))

; tests of bal3_trits_add
(assert_equal (bal3_trits_add '- '- '(- s)) '(- 0 s))
(assert_equal (bal3_trits_add '- '- '(0 s)) '(- + s))
(assert_equal (bal3_trits_add '- '0 '(- s)) '(- + s))
(assert_equal (bal3_trits_add '0 '- '(- s)) '(- + s))
(assert_equal (bal3_trits_add '- '- '(+ s)) '(0 - s))
(assert_equal (bal3_trits_add '- '0 '(0 s)) '(0 - s))
(assert_equal (bal3_trits_add '- '+ '(- s)) '(0 - s))
(assert_equal (bal3_trits_add '0 '- '(0 s)) '(0 - s))
(assert_equal (bal3_trits_add '0 '0 '(- s)) '(0 - s))
(assert_equal (bal3_trits_add '+ '- '(- s)) '(0 - s))
(assert_equal (bal3_trits_add '- '0 '(+ s)) '(0 0 s))
(assert_equal (bal3_trits_add '- '+ '(0 s)) '(0 0 s))
(assert_equal (bal3_trits_add '0 '- '(+ s)) '(0 0 s))
(assert_equal (bal3_trits_add '0 '0 '(0 s)) '(0 0 s))
(assert_equal (bal3_trits_add '0 '+ '(- s)) '(0 0 s))
(assert_equal (bal3_trits_add '+ '0 '(- s)) '(0 0 s))
(assert_equal (bal3_trits_add '+ '- '(0 s)) '(0 0 s))
(assert_equal (bal3_trits_add '- '+ '(+ s)) '(0 + s))
(assert_equal (bal3_trits_add '0 '0 '(+ s)) '(0 + s))
(assert_equal (bal3_trits_add '0 '+ '(0 s)) '(0 + s))
(assert_equal (bal3_trits_add '+ '- '(+ s)) '(0 + s))
(assert_equal (bal3_trits_add '+ '0 '(0 s)) '(0 + s))
(assert_equal (bal3_trits_add '+ '+ '(- s)) '(0 + s))

(assert_equal (bal3_add '(0) '(-)) '(-))
(assert_equal (bal3_add '(+ 0) '(0 -)) '(+ -))
(assert_equal (bal3_add '(+ - - 0) '(+ 0 - -)) '(+ + + -))
(assert_equal (bal3_neg '(+ - - 0)) '(- + + 0))
(assert_equal (bal3_neg '(- + + - 0 0 0 - + + -))
                        '(+ - - + 0 0 0 + - - +))
(assert_equal (bal3_minus '(+ - - 0) '(+ 0 - -)) '(- 0 +))
