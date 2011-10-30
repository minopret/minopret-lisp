; Test binary.lisp
;
; Useful functions on fixed-size input:
;      bit^4->hex    base64^2->hex^3  quoted-printable->hex^2*pushback
; hex->bit^4  hex^3->base64^2  hex^2->quoted-printable  hex->bit^4 (full circle)
;
; Functions on variable-size input:
;      bits->hex  base64->hex  quoted-printable->hex
; hex->bits  hex->base64  hex->quoted-printable  hex->bits (full circle)


; Test data. Wrapping each "label" in "not null" causes the result
; to be t. Every statement in a test program should result in t.
(not (null (label data1-qp
   '(! " #))))   ; "))  This comment preserves hiliting.

(not (null (label data1-hex
   '(2 1 2 2 2 3) )))

(not (null (label data2-qp
   '(  A B C D E  F G H I J K
     L M N O P Q  R S T U V W  ; 96 bits of UTF-8
     X Y Z          a b c d e
     f g h i j k  l m n o p q
     r s t u v w  x y z ))))

(not (null (label data2-hex
   '(    4 1 4 2 4 3 4 4 4 5  4 6 4 7 4 8 4 9 4 A 4 B
     4 C 4 D 4 E 4 F 5 0 5 1  5 2 5 3 5 4 5 5 5 6 5 7  ; 96 bits of UTF-8
     5 8 5 9 5 A                  6 1 6 2 6 3 6 4 6 5
     6 6 6 7 6 8 6 9 6 A 6 B  6 C 6 D 6 E 6 F 7 0 7 1
     7 2 7 3 7 4 7 5 7 6 7 7  7 8 7 9 7 A ) )))

(not (null (label data3-qp
   '(= 2 8 l a b e l  = 2 0 q p - d a  ; 96 bits of UTF-8
     t a 3 = 2 0 ' a  = 2 9) )))

(not (null (label data3-hex-1
   '(2 8 6 C 6 1 6 2 6 5 6 C  2 0 7 1 7 0 2 D 6 4 6 1  ; 96 bits of UTF-8
     7 4 6 1 3 3 2 0 2 7 6 1  2 9) )))

(not (null (label data3-hex-2
   '(2 8 6 C 6 1 6 2 6 5 6 C  2 0 7 1 7 0 2 D 6 4 6 1  ; 96 bits of UTF-8
     7 4 6 1 3 3 2 0 2 7 6 1  0 2 9) )))

(not (null (label data3-bin
   '(() ()  t ()    t () () ()   ()  t  t ()    t  t () ()
     ()  t  t ()   () () ()  t   ()  t  t ()   () ()  t ()
     ()  t  t ()   ()  t ()  t   ()  t  t ()    t  t () ()

     () ()  t ()   () () () ()   ()  t  t  t   () () ()  t
     ()  t  t  t   () () () ()   () ()  t ()    t  t ()  t
     ()  t  t ()   ()  t () ()   ()  t  t ()   () () ()  t


     ()  t  t  t   ()  t () ()   ()  t  t ()   () () ()  t
     () ()  t  t   () ()  t  t   () ()  t ()   () () () ()
     () ()  t ()   ()  t  t  t   ()  t  t ()   () () ()  t

     () ()  t ()    t () ()  t   ) )))

(not (null (label data3-base64-1
   '(A o b G F i Z W  w g c X A t Z G
     F 0 Y T M g J 2  E p) )))

(not (null (label data3-base64-2
   '(K G x h Y m V s  I H F w L W R h
     d G E z I C d h  A p) )))



(assert-equal (quoted-printable->hex data1-qp) data1-hex)

(assert-equal (quoted-printable->hex data2-qp) data2-hex)

(assert-equal (quoted-printable->hex data3-qp) data3-hex-1)

; Maximum length within recursion limit.
(assert-equal (hex->bits data3-hex-1) data3-bin)

(assert-equal (bits->hex data3-bin) data3-hex-1)

(assert-equal (hex->base64 data3-hex-1) data3-base64-1)

(assert-equal (base64->hex data3-base64-2) data3-hex-2)

(assert-equal (cdr-while-car-eq '0 (base64->hex data3-base64-1)) data3-hex-1)

(assert-equal (hex->quoted-printable data3-hex-1) data3-qp)
