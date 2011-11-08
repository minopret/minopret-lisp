(assert-equal (fold-left list () '(1 2 3)) '(((() 1) 2) 3))
(assert-equal (fold-right list () '(1 2 3)) '(1 (2 (3 ()))))

(assert-equal (transpose '((1 2 3)
                           (4 5 6)
                           (7 8 9)) )

                         '((1 4 7)
                           (2 5 8)
                           (3 6 9)) )
