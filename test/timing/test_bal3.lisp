; In balanced ternary
(assert-equal (fact-bal3 '(    0)) '(                            +))  ; 1
(assert-equal (fact-bal3 '(    +)) '(                            +))  ; 1
(assert-equal (fact-bal3 '(  + -)) '(                          + -))  ; 2
(assert-equal (fact-bal3 '(  + 0)) '(                        + - 0))  ; 6
(assert-equal (fact-bal3 '(  + +)) '(                      + 0 - 0))  ; 24
(assert-equal (fact-bal3 '(+ - -)) '(                    + + + + 0))  ; 120
(assert-equal (fact-bal3 '(+ - 0)) '(                + 0 0 0 - 0 0))  ; 720
(assert-equal (fact-bal3 '(+ - +)) '(            + - + 0 - + - 0 0))  ; 5040
(assert-equal (fact-bal3 '(+ 0 -)) '(        + - 0 0 + + 0 - + 0 0))  ; 40320
(assert-equal (fact-bal3 '(+ 0 0)) '(    + - 0 0 + + 0 - + 0 0 0 0))  ; 362880
(assert-equal (fact-bal3 '(+ 0 +)) '(+ - + - + + + 0 + - + 0 0 0 0))  ; 3628800
; In balanced ternary
(assert-equal (fib-bal3 '(    0)) '(        0))
(assert-equal (fib-bal3 '(    +)) '(        +))
(assert-equal (fib-bal3 '(  + -)) '(        +))
(assert-equal (fib-bal3 '(  + 0)) '(      + -))
(assert-equal (fib-bal3 '(  + +)) '(      + 0))
(assert-equal (fib-bal3 '(+ - -)) '(    + - -))
(assert-equal (fib-bal3 '(+ - 0)) '(    + 0 -))
(assert-equal (fib-bal3 '(+ - +)) '(    + + +))
(assert-equal (fib-bal3 '(+ 0 -)) '(  + - + 0))
(assert-equal (fib-bal3 '(+ 0 0)) '(  + + - +))
(assert-equal (fib-bal3 '(+ 0 +)) '(+ - 0 0 +))
(assert-equal (fib-bal3 '(+ + -)) '(+ 0 + 0 -))
