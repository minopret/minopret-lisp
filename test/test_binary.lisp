; Test binary.lisp
;
; Useful functions on fixed-size input:
;      bit^4->hex    base64^2->hex^3  quoted-printable->hex^2*pushback
; hex->bit^4  hex^3->base64^2  hex^2->quoted-printable  hex->bit^4 (full circle)
;
; Functions on variable-size input, which exercise all the functions above:
;      bits->hex  base64->hex  quoted-printable->hex
; hex->bits  hex->base64  hex->quoted-printable  hex->bits (full circle)

; Needs data from binary.env.lisp


(assert-equal (quoted-printable->hex data1-qp) data1-hex)

'(The next test might take a minute!)

(assert-equal (quoted-printable->hex data2-qp) data2-hex)

(assert-equal (quoted-printable->hex data3-qp) data3-hex-1)

(assert-equal (hex->bits data3-hex-1) data3-bin)

(assert-equal (bits->hex data3-bin) data3-hex-1)

(assert-equal (hex->base64 data3-hex-1) data3-base64-1)

(assert-equal (base64->hex data3-base64-2) data3-hex-2)

(assert-equal (cdr-while-car-eq '0 (base64->hex data3-base64-1)) data3-hex-1)

(assert-equal (hex->quoted-printable data3-hex-1) data3-qp)
