; Test binary.lisp
;
; Useful functions:
;      bit^4->hex    base64^2->hex^3  quoted-printable->hex^2*pushback
; hex->bit^4  hex^3->base64^2  hex^2->quoted-printable  hex->bit^4 (full circle)
;
; Wanted: functions on arbitrary length input:
;      bits->hex  base64->hex  quoted-printable->hex
; hex->bits  hex->base64  hex->quoted-printable  hex->bits (full circle)

(label qp-data1 '(! " #))   ; "))  This comment preserves hiliting.

(label qp-data2 '(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e))  ; Maximum length within recursion limit.

(label qp-data3 '(= 2 8 l a b e l = 2 0 q p - d a t a 3 = 2 0 ' a = 2 9))


(assert-equal (quoted-printable->hex qp-data)
             '(7 1 7 0 2 D 6 4 6 1 7 4 6 1))
(assert-equal (quoted-printable->hex qp-data2) 
             '(4 1 4 2 4 3 4 4 4 5 4 6 4 7 4 8
               4 9 4 A 4 B 4 C 4 D 4 E 4 F 5 0
               5 1 5 2 5 3 5 4 5 5 5 6 5 7 5 8
               5 9 5 A 6 1 6 2 6 3 6 4 6 5) )
(assert-equal (quoted-printable->hex qp-data3)
             '(2 8 6 C 6 1 6 2 6 5 6 C 2 0 7 1
               7 0 2 D 6 4 6 1 7 4 6 1 3 3 2 0
               2 7 6 1 2 9) )
