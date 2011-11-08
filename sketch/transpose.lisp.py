# A Python program in single static assignment style,
# as a sketch for the corresponding Lisp program.
# Aaron Mansheim, 2011-11-05
#
# Some other uses for this that might be fun:
# - Compare compiling it with various Python tools.
# - Use it as an example of how to translate between
#   applicative and imperative syntax.
# - Rewrite it in gcc's intermediate languages
#   GIMPLE and GENERIC.
# - What would it be like to translate between
#   GIMPLE and Lisp?

# params: m, a matrix (list of M lists each of length N)
# return: the transpose of m (list of N lists each of length M)
def transpose(m):
    # mr: matrix in reverse, to shorten
    # mt: matrix transposed, to lengthen
    m.reverse()
    mr, mt = m, []
    del m

    while len(mr) > 0:
        if len(mt) == 0:
            del mt
            # rr: the row in reverse, to shorten
            # mrs:  matrix in reverse, shortened
            # rt: the row transposed, to lengthen
            mr[0].reverse()
            rr, mrs, rt = mr[0], mr[1:], []
            del mr

            while len(rr) > 0:
                # rf: first value in row
                # rrs: row in reverse, shortened
                # rtl: row transposed, lengthened
                rr, rt = rr[1:], [[rr[0]]] + rt
            del rr

            # mtl: matrix transposed, lengthened
            mtl = rt
            del rt
        else:
            #  rr: the last row reversed, to shorten
            # mrs: matrix in reverse, shortened
            # mtr: matrix transposed, reversed, shortening
            # mtl: matrix transposed, lengthening, initially empty
            mr[0].reverse()
            mt.reverse()
            rr, mrs, mtr, mtl \
                    = mr[0], mr[1:], mt, []
            del mr
            del mt

            while len(rr) > 0:
                mtl, rr, mtr \
                    = [ [rr[0]] + mtr[0] ] + mtl, rr[1:], mtr[1:]
            del rr
            del mtr
        mr, mt = mrs, mtl
    del mr

    return mt


m = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
print 'The transpose of ' + str(m) + ' is ' + str(transpose(m)) + '.'
