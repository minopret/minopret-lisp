; A similar encoding as UTF-8 that uses balanced base 81 digits
; as the code alphabet, rather than bytes.
;
; Aaron Mansheim, September 2011


; Remember, there's no such thing as "plain" text. So we focus on
; Unicode. Note that UTF-8 is an encoding for 2^31 values
; (sometimes including surrogate halves, but let's not worry about
; them more than UTF-8 does), and 2^31 is between 3^19 and 3^20.
; We could put each Unicode point into 5 bal81 digits. If like
; UTF-8 we wish to code each value independently and code
; values from certain ranges smaller than those from others, 
; we could for example do as follows:
;  range: hex 00-7F; bal81 digits: 2; trits: 6
;         bal3: (00000000)-(00+---0+)
;  range: hex 80-7FF; bal81 digits: 2; trits: 7
;         bal3:   (+---+-)-(+0-++-++)
;  range: hex 800-FFFF; bal81 digits: 3; trits: 10
;         bal3:     (+0-++0--)- (+0+000-0+-0)
;  range: hex 10000-1FFFFF; bal81 digits: 4; trits: 13
;         bal3:      (+0+000-0+-+)-  (++00---0-+-+-+)
;  range: hex 200000-3FFFFFF; bal81 digits: 5; trits: 16
;         bal3:      (++00---0-+-+-0-)-   (+---00+-++++--+++)
;  range: hex 4000000-7FFFFFFF; bal81 digits: 5?; trits: 20
;         bal3:    (+---00+-++++-0---)- (++++++++++++++++++++)
;          AND  (--------------------)- (-0--0-000--+++-+-+0+)
;          for (+--------------------)-(+-0--0-000--+++-+-+0+)

; Let's start the first bal81 for any code point hex 00-7F with a zero trit.
; The second bal81 starts with a negative trit.
; A code for the first bal81 of a code point outside hex 00-7F
; starts with a positive trit.
; A code for the second or any later bal81 of any code point starts
; with a negative trit.
;  range: hex 0-7F; bal81 digits: 2; 6-trit pattern 0xxx -xxx
;  range: hex 80-7FF; bal81 digits: 3; 7-trit pattern +-0x -xxx -xxx
;  range: hex 800-FFFF; bal81 digits: 4; 10-trit pattern +-+x -xxx -xxx -xxx
;  range: hex 10000-1FFFFF; bal81 digits: 5;
;                           13-trit pattern +0-x -xxx -xxx -xxx -xxx
;  range: hex 200000-3FFFFFF; bal81 digits: 5;
;                       16-trit pattern +00x -xxx -xxx -xxx -xxx
;  range: hex 4000000-7FFFFFFF; bal81 digits: 7;
;                       20-trit pattern ++xx -xxx -xxx -xxx -xxx -xxx -xxx

; "byte order mark", code point U+FEFF:
;  10-trit pattern +-+0 -+00 ---0 --+-  bal81: Li<y
;  range: hex 800-FFFF; bal81 digits: _; 10-trit pattern +-+x -xxx -xxx -xxx
; What we get if the byte order mark is mangled: bal81: iLy<
; That has two invalid features: the initial bal81 'i' (a continuation bal81)
; and the sequence Ly (an initial bal81 for range hex 800-FFFF followed by 
; a continuation bal81 that shows the stored code point is in fact negative).

; Translation tables between US-ASCII and bal81.
(label bal81_to_ascii (lambda (x) (assoc-equal x '(
; no tab atom; no newline atom
                                                  ((1 l) !) ; no space atom
          ((1 j) #) ((1 i) $) ((1 h) %) ((1 g) &) ((1 f) ') ; no double-quote atom
                    ((2 <) *) ((2 \) +) ((2 [) ,) ((2 {) -) ; no paren atoms
((2 z) .) ((2 y) /) ((2 x) 0) ((2 w) 1) ((2 v) 2) ((2 u) 3)
((2 t) 4) ((2 s) 5) ((2 r) 6) ((2 q) 7) ((2 p) 8) ((2 o) 9)
((2 n) :)           ((2 l) <) ((2 k) =) ((2 j) >) ((2 i) ?) ; no semicolon atom
((2 h) @) ((2 g) A) ((2 f) B) ((2 e) C) ((3 -) D) ((3 <) E)
((3 \) F) ((3 [) G) ((3 {) H) ((3 z) I) ((3 y) J) ((3 x) K)
((3 w) L) ((3 v) M) ((3 u) N) ((3 t) O) ((3 s) P) ((3 r) Q)
((3 q) R) ((3 p) S) ((3 o) T) ((3 n) U) ((3 m) V) ((3 l) W)
((3 k) X) ((3 j) Y) ((3 i) Z) ((3 h) [) ((3 g) \) ((3 f) ])
((3 e) ^) ((4 -) _) ((4 <) `) ((4 \) a) ((4 [) b) ((4 {) c)
((4 z) d) ((4 y) e) ((4 x) f) ((4 w) g) ((4 v) h) ((4 u) i)
((4 t) j) ((4 s) k) ((4 r) l) ((4 q) m) ((4 p) n) ((4 o) o)
((4 n) p) ((4 m) q) ((4 l) r) ((4 k) s) ((4 j) t) ((4 i) u)
((4 h) v) ((4 g) w) ((4 f) x) ((4 e) y) ((5 -) z) ((5 <) {)
((5 \) |) ((5 [) }) ((5 {) ~)
))))

(label ascii_to_bal81 (lambda (x) (assoc x '(
; no tab atom; no newline atom
                                                  (! (1 l)) ; no space atom
          (# (1 j)) ($ (1 i)) (% (1 h)) (& (1 g)) (' (1 f)) ; no double-quote atom
                    (* (2 <)) (+ (2 \)) (, (2 [)) (- (2 {)) ; no paren atoms
(. (2 z)) (/ (2 y)) (0 (2 x)) (1 (2 w)) (2 (2 v)) (3 (2 u))
(4 (2 t)) (5 (2 s)) (6 (2 r)) (7 (2 q)) (8 (2 p)) (9 (2 o))
(: (2 n))           (< (2 l)) (= (2 k)) (> (2 j)) (? (2 i)) ; no semicolon atom
(@ (2 h)) (A (2 g)) (B (2 f)) (C (2 e)) (D (3 -)) (E (3 <))
(F (3 \)) (G (3 [)) (H (3 {)) (I (3 z)) (J (3 y)) (K (3 x))
(L (3 w)) (M (3 v)) (N (3 u)) (O (3 t)) (P (3 s)) (Q (3 r))
(R (3 q)) (S (3 p)) (T (3 o)) (U (3 n)) (V (3 m)) (W (3 l))
(X (3 k)) (Y (3 j)) (Z (3 i)) ([ (3 h)) (\ (3 g)) (] (3 f))
(^ (3 e)) (_ (4 -)) (` (4 <)) (a (4 \)) (b (4 [)) (c (4 {))
(d (4 z)) (e (4 y)) (f (4 x)) (g (4 w)) (h (4 v)) (i (4 u))
(j (4 t)) (k (4 s)) (l (4 r)) (m (4 q)) (n (4 p)) (o (4 o))
(p (4 n)) (q (4 m)) (r (4 l)) (s (4 k)) (t (4 j)) (u (4 i))
(v (4 h)) (w (4 g)) (x (4 f)) (y (4 e)) (z (5 -)) ({ (5 <))
(| (5 \)) (} (5 [)) (~ (5 {))
))))

; Comparison chart for bal3 notation, bal81, decimal, bit, and byte:
; Non-negative ranges:
; bal3:  0 +   decimal: 0-1  #values incl. neg.:3; trits: 1;  0 bytes;   bits: 1
;       +- ++           2-4                     9   0     2                  2-3
;      +-- +++          5-13                   27   1     3                  3-4
;     +--- ++++        14-40                   81         4; bal81's: 1      5-6
;    +---- +++++       41-121                 243   2     5                  6-7
;   +----- ++++++     122-364                 729         6;  1 byte;        8-9
;  +------ +++++++    365-1093               2187   3     7                 10-11
; +------- ++++++++  1094-3280               6561         8           2     11-12
;bal81:+-- +++       1123-265720           531441   6    12   2       3     18-19
;     +--- ++++    265721-21523360       43046721   7    16   3       4     24-25
;    +---- +++++ 21523361-1743392200   3486784401  10    20           5     30-31
;     etc. etc.1743392201-14214768240 282429536481 11    24   4       6     37-38
; NOTE: 2^31 = 2147483648
;                    etc. etc.               etc.  13    28   5       7     43-44
;                                                  15    32   6       8     49-50
;                                                  17    36   7       9     56-57
;                                                  19    40          10     62-63
;                                  digits base 10: 20    44   8      11     68-69


