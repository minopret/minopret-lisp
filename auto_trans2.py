# This was largely automatically parsed and reformatted from Lisp.
# The early evaluation of recursive calls might well fail.
# This should be modified all over the place, probably by currying,
# to ensure maximal shortcut evaluation and preferably the ability
# to use an operation stack and a data stack. I have
# eliminated Python "cond" in favor of Python "if" statements.
# Also I'm toying with the idea of object orientation because
# if we do want to do late binding we could pass the operations
# to the data rather than vice versa.


from types import StringTypes


def evlis_ (m, a):
	result = ()
	if null_ (m) != "t":
		result = cons (eval_ (car (m), a), evlis_ (cdr (m), a))
	return result


def evcon_ (c, a):
	result = ()
	if eval_ (caar_ (c), a) == "t":
		result = eval_ (cadar_ (c), a)
	else:
		result = evcon_ (cdr (c), a)
	return result


def eval_ (e, a):
	result = ()
	if atom (e) == "t":
		result = assoc_ (e, a)
	elif atom (car (e)) == "t":
		if car (e) == "quote":
			result = cadr_ (e)
		elif car (e) == "atom":
			result = atom (eval_ (cadr_ (e), a))
		elif car (e) == "eq":
			result = eq (eval_ (cadr_ (e), a), eval_ (caddr_ (e), a))
		elif car (e) == "car":
			result = car (eval_ (cadr_ (e), a))
		elif car (e) == "cdr":
			result = cdr (eval_ (cadr_ (e), a))
		elif car (e) == "cons":
			result = cons (eval_ (cadr_ (e), a), eval_ (caddr_ (e), a))
		elif car (e) == "cond":
			result = evcon_ (cdr (e), a)
		else:
			result = eval_ (cons (assoc_ (car (e), a), cdr (e)), a)
	elif caar_ (e) == "lambda_":
		result = eval_ (caddar_ (e), append_ (pair_ (cadar_ (e), evlis_ (cdr (e), a)), a))
	elif caar_ (e) == "label_":
		result = eval_ (cons (caddar_ (e), cdr (e)), cons (list_ (cadar_ (e), car (e)), a))
	return result


def assoc_ (x, y):
	result = ()
	if eq (caar_ (y), x) == "t":
		result = cadar_ (y)
	else:
		result = assoc_ (x, cdr (y))
	return result


def pair_ (x, y):
	result = ()
	if and_ (null_ (x), null_ (y)) != "t" and and_ (not_ (atom (x)), not_ (atom (y))) == "t":
		result = cons (list_ (car (x), car (y)), pair_ (cdr (x), cdr (y)))
	return result


def append_ (x, y):
	result = ()
	if null_ (x) == "t":
		result = y
	else:
		result = cons (car (x), append_ (cdr (x), y))
	return result


def caddar_ (x):
	return car (cdr (cdr (car (x))))


def cadar_ (x):
	return car (cdr (car (x)))


def caar_ (x):
	return car (car (x))


def caddr_ (x):
	return car (cdr (cdr (x)))


def cadr_ (x):
	return car (cdr (x))


def list_ (x, y):
	return cons (x, cons (y, ()))


def not_ (x):
	result = ()
	if x != "t":
		result = "t"
	return result


def and_ (x, y):
	result = ()
	if x == "t" and y == "t":
		result = "t"
	return result


def null_ (x):
	result = ()
	if x == ()
		result = "t"
	return result




def atom (x):
	result = ()
	if x == () or isinstance(x, StringTypes):
		result = "t"
	return result


def car (x):
	return x[0]


def cdr (x):
	return x[1:]


def cons (x, y):
	return (x, ) + y


def eq (x, y):
	result = ()
	if atom (x) == "t" and atom (y) == "t" and x == y:
		result = "t"
	return result
