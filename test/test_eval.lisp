'1
(assert-equal (eval () '(car a)) ()) ; 1
; 2, 21 ; is guarded against
(assert-equal (eval 'x ()) 'x) ; 2, 22
(assert-equal (eval 'x 'a) 'x) ; 2, 22
; 2, 25, 23 ; inconsistent. See 2, 25, 24
(assert-equal (eval 'x '(())) 'x) ; 2, 25, 24
; (assert-equal (eval 'x '(a)) 'x) ; 2, 26, {23, 24} ; error (caaar a)
; (assert-equal (eval 'x '((a))) 'x) ; 2, 26, {23, 24} ; error (caaar a)
; 2, 27, 23 ; inconsistent. See 3, 27, 23
(assert-equal (eval 'x '(((x ())))) 'x) ; 2, 27, 24

'2,28,23
; 2, 28, 23 ; inconsistent. See 3, 28, 23
(assert-equal (eval 'x '(((u v)))) 'x) ; 2, 28, 24
; 3, 21 ; is guarded against
; 3, 22 ; inconsistent. See 2, 22
; 3, 25, 23 ; inconsistent. See 3, 25, 24
(assert-equal (eval 'x '(() ((x y)))) 'y) ; 3, 25, 24
; (assert-equal (eval 'x '(y _?)) 'x) ; 3, 26, {23, 24} ; error (cadar a)
(assert-equal (eval 'x '(((x y)))) 'y) ; 3, 27, 23
(assert-equal (eval 'x '(((x ())) ((x y)))) 'y) ; 3, 27, 24 ; spec ok?
(assert-equal (eval 'x '(((q) (x y)))) 'y) ; 3, 28, 23

'3,28,3
(assert-equal (eval 'x '(((q r) (x y)))) 'y) ; 3, 28, 23
(assert-equal (eval 'x '(((q r)) ((x y)))) 'y) ; 3, 28, 24
(assert-equal (eval ''x '(())) 'x) ; 4
(assert-equal (eval '(atom 'x) '(())) 't) ; 5
(assert-equal (eval '(car '(x y)) '(())) 'x) ; 6

'7
(assert-equal (eval '(cdr '(x y)) '(())) '(y)); 7
(assert-equal (eval '(cons 'x '()) '(())) '(x)) ; 8
(assert-equal (eval '(eq 'x 'x) '(())) 't) ; 9
(assert-equal (eval '(cond) '(())) ()) ; 10 ; spec ok?
(assert-equal (eval '(cond (t 'x)) '(())) 'x) ; 11

'12
(assert-equal (eval '(cond (() 'x) (t 'y)) '(())) 'y) ; 12
; (assert-equal (eval '(() x) '_?) '_); 13, 21 ; error at 21
; (assert-equal (eval '(f x) 'a) '_); 13, 22 ; error at 21
; 13, 25, 23 ; inconsistent. See 13, 25, 24
; (assert-equal (eval '(f) '(())) 'y) ; 13, 25, 24 ; error at 21
; (assert-equal (eval '(f x) '(())) 'y) ; 13, 25, 24 ; error at 21
; (assert-equal (eval '(f) '(a)) 'y) ; 13, 26, {23, 24} ; error (caaar a)
; (assert-equal (eval '(f) '((a))) 'y) ; 13, 26, {23, 24} ; error (caaar a)
(assert-equal (eval '(f '(x y)) '(((f car)))) 'x) ; 13, 27, 23
; (assert-equal (eval '(f '(x y)) '(((f ())))) 'x) ; 13, 27, 24 ; error at 21
(assert-equal (eval '(f '(x y)) '(((g cdr) (f car)))) 'x) ; 13, 28, 23
; (assert-equal (eval '(f '(x y)) '(((g cdr) (f ())))) 'x) ; 13, 28, 24 ; error at 21
(assert-equal (eval '((lambda () 'x)) '(())) 'x) ; 14
(assert-equal (eval '((lambda (t) (cons t '(u))) 'x) '(())) '(x u)) ; 15<->16

'{15,16}
(assert-equal (eval '((lambda (s t) (cons s (cons t '(u)))) 'x 'y)
    '(()) ) '(x y u)) ; 15<->16
(assert-equal (eval '((label b c) d) '(((c car) (d (u v))))) 'u); 17
(assert-equal (eval '((x)) '(())) '()); 18

