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

(label qp-data3 '(= 2 8 l a b e l = 2 0 q p - d a t a 5 = 2 0 ' a = 2 9))



;(quoted-printable->hex qp-data1)
;(quoted-printable->hex qp-data2)
(quoted-printable->hex qp-data3)
