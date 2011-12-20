#!/usr/bin/python
#
# Computes the cosine function.
# 
# Aaron Mansheim, 2011-11-07
#
# Why?
#  * Because I took too many courses in numerical methods.
#  * Because if I clean this up, someone somewhere might enjoy
#    this little insight into demystifying math libraries.
#  * Because I've been writing a Lisp in Python with intent
#    to migrate the Lisp onto only the seven classic primitive
#    functions, and this is a prototype for the math library.
#  * Because cosine has a pretty simple power series and
#    sine, tangent, and arctangent are pretty closely related.
#  * Because last year I made a Python implementation of Paul
#    Schlyter's method of tracking the Earth-Sun-Moon system.
#  * Because I'd like to port that to my Lisp.
#
# Computes the cosine function anywhere in 0 to pi/2
# using only the following operations:
# add, subtract, or multiply integers; multiply or divide an integer by two;
# divide one by two a small-ish number of times. In particular,
# the algorithms should work in fixed-point arithmetic with any even radix.
#
# Some work remains in order to achieve full IEEE 754 double precision
# (or ultimately perhaps, any nonzero error bound that a user may request).


# An effective way to build (inexact) division on multiplication and
# subtraction: Reciprocal of any number q >= 1 by Newton's method on
# this function:
#     f(x)  =  1/x - q.
#
# The crucial characteristics of this f:
# * Newton's method finds x with f(x) = 0, which does indeed imply x = 1/q.
# * There is no division needed in the Newton's method update step:
#     x_new  :=  x - f(x)/f'(x)  =  x - (1/x - q) / (-1/x^2)  =  x(2 - q*x).
#
# In general integer division we would probably want to store reciprocals
# just for the smallest integer arguments. Horner's rule for polynomials
# in integer coefficients, and the Fundamental Theorem of Arithmetic
# for integers generally, could help us hit a very small number of stored
# values extremely frequently.
_reciprocals = {0: 1}

# Because currently I take an interest in positional number systems
# other than binary, and because I want it to be clear which
# multiplies and divides are implementable as digit shifts,
# I'll abstract out the number base. The code assumes that the
# number base is a positive integer greater than 1.
RADIX = 2

def reciprocal(q):
    global _reciprocals
    if q in _reciprocals:
        return _reciprocals[q]

    # Here is a sloppy but quick (unless perhaps q is super-astronomical)
    # starting guess that is definitely between the actual value and zero.
    # I could check my guess that this keeps Newton's method from diverging.
    a = RADIX
    b = 1.0/RADIX
    while q > a:
        a *= a
        b *= b
    x = b

    # The number of iterations could be adjusted case-by-case
    # according to any required precision.
    # The error bound on the ith iteration is known
    # (in Wikipedia--I myself haven't bothered to attain,
    # consider, or remember a derivation yet) to be q*xi - 1.
    # But for now, I'm just going to hard-code the number
    # of iterations.
    for i in range(0, 15):
        #print i, q, x
        x = x*(2 - q*x)
    _reciprocals[q] = x
    return x


# Raise a real number to an integral power.
# In general,
# x^n == Prod(x^(2*i)) for those i with (n // 2^i) % 2 == 1.
# Hooray for (very) elementary number theory.
# Doesn't seem easy? OK but consider an example: Compute x^13.
#                        f := x;                     p := 1
# (6, 1) == 13 divmod 2; f := f   == x^(2^0) == x  ; p := p * f^1 == x
# (3, 0) ==  6 divmod 2; f := f^2 == x^(2^1) == x^2; p := p * f^0 == x
# (1, 1) ==  3 divmod 2; f := f^2 == x^(2^2) == x^4; p := p * f^1 == x^5
# (0, 1) ==  1 divmod 2; f := f^2 == x^(2^3) == x^8; p := p * f^1 == x^13
#
# That is, x^13 == x^(1+  4+8) == x * (x^2)^2 * ((x^2)^2)^2.
def power(x, i):
    product = 1
    factor = x
    while True:
        if i % RADIX != 0:
            product *= factor  # needs a little more adjustment to be radix-independent
        if i <= 0:
            break
        #print i, i // 2, i % 2, factor, product
        j = 1
        while j < RADIX:
            factor *= factor
            j += 1
        i //= RADIX
    return product


_factorials = [1]

def factorial(n):
    global _factorials
    f = 1
    nmax = len(_factorials)
    while nmax <= n:
        _factorials += [nmax * _factorials[nmax - 1]]
        nmax = len(_factorials)
    f = _factorials[n]
    return f


# Cosine, by means of Maclaurin series.
#
# An error bound for a truncated Maclaurin series (Maclaurin polynomial)
# is simply the next term in the series.
#
# Note: We could benefit, and perhaps throw away the factorial function,
# by converting the Maclaurin polynomial to Horner's rule.
# But let's do that some other time.
# It seems even less worthwhile to write a special-purpose
# reciprocal_of_factorial function.
def cos_maclaurin(x, n):
    def cos_maclaurin_term(x, i):
        return (1 if i % 2 == 0 else -1) * power(x, 2*i) \
                * reciprocal(factorial(2*i))
        
    c = 0
    for i in range(0, n):
        c += cos_maclaurin_term(x, i)
    return c, cos_maclaurin_term(x, n)


def main():
    from math import cos

    print 'i', 'cos_est', 'cos_std', 'err_bound', 'err_actual'
    for i in range(0, 7):
        cm, em = cos_maclaurin(0.5, i)
        c = cos(0.5)
        d = c - cm
        print i, cm, c, em, d


if __name__ == "__main__":
    main()
