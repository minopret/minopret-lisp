'0
(assert-equal (eval () '(car a)) ()) ; 1
; 2, 21 ; is guarded against
(assert-equal (eval 'x ()) 'x) ; 2, 22
(assert-equal (eval 'x 'a) 'x) ; 2, 22
; 2, 25, 23 ; inconsistent. See 2, 25, 24
(assert-equal (eval 'x '(())) 'x) ; 2, 25, 24
; (assert-equal (eval 'x '(a)) ) ; 2, 26, {23, 24} ; error (caaar a)
; (assert-equal (eval 'x '((a))) ) ; 2, 26, {23, 24} ; error (caaar a)
; 2, 27, 23 ; inconsistent. See 3, 27, 23
(assert-equal (eval 'x '(((x ())))) 'x) ; 2, 27, 24

'5
; 2, 28, 23 ; inconsistent. See 3, 28, 23
(assert-equal (eval 'x '(((u v)))) 'x) ; 2, 28, 24
; 3, 21 ; is guarded against
; 3, 22 ; inconsistent. See 2, 22
; 3, 25, 23 ; inconsistent. See 3, 25, 24
(assert-equal (eval 'x '(() ((x y)))) 'y) ; 3, 25, 24
; (assert-equal (eval 'x '(y _?)) y) ; 3, 26, {23, 24} ; error (cadar a)
(assert-equal (eval 'x '(((x y)))) 'y) ; 3, 27, 23
(assert-equal (eval 'x '(((x ())) ((x y)))) 'y) ; 3, 27, 24 ; spec ok?
(assert-equal (eval 'x '(((q) (x y)))) 'y) ; 3, 28, 23

'10
(assert-equal (eval 'x '(((q r) (x y)))) 'y) ; 3, 28, 23
(assert-equal (eval 'x '(((q r)) ((x y)))) 'y) ; 3, 28, 24
(assert-equal (eval ''x '(())) 'x) ; 4
(assert-equal (eval '(atom 'x) '(())) 't) ; 5
(assert-equal (eval '(car '(x y)) '(())) 'x) ; 6

'15
(assert-equal (eval '(cdr '(x y)) '(())) '(y)); 7
(assert-equal (eval '(cons 'x '()) '(())) '(x)) ; 8
(assert-equal (eval '(eq 'x 'x) '(())) 't) ; 9
(assert-equal (eval '(cond) '(())) ()) ; 10 ; spec ok?
(assert-equal (eval '(cond (t 'x)) '(())) 'x) ; 11

'20
(assert-equal (eval '(cond (() 'x) (t 'y)) '(())) 'y) ; 12
; (assert-equal (eval '(() x) '_?) '_); 13, 21 ; * INFINITE LOOP!
; (assert-equal (eval '(f x) 'a) '_); 13, 22 ; * INFINITE LOOP!
; 13, 25, 23
; 13, 25, 24
; 13, 26, 23
; 13, 26, 24
; 13, 27, 23
; 13, 27, 24
; 13, 28, 23
; 13, 28, 24
(assert-equal (eval '((lambda () 'x)) '(())) 'x) ; 14
(assert-equal (eval '((lambda (t) (cons t '(u))) 'x) '(())) '(x u)) ; 15<->16
(assert-equal (eval '((lambda (s t) (cons s (cons t '(u)))) 'x 'y)
    '(()) ) '(x y u)) ; 15<->16
(assert-equal (eval '((label b c) d) '(((c car) (d (u v))))) 'u); 17
(assert-equal (eval '((x)) '(())) '()); 18

; (assert-equal (eval '(car 'a) '((a b))) 'error) ; * b
; (assert-equal (eval '(cdr 'a) '((a b))) 'error) ; * ()
; (assert-equal '(eval (x)) '(()))  ; * HANGS!

; Redundant.
; (assert-equal (eval '((lambda (x) (cond (x t) (t ()))) t) '(((t t)))) t)
