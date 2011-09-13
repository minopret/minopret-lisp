# This was largely automatically parsed and reformatted from Lisp.
# The early evaluation of recursive calls probably won't work.
# This should be modified all over the place, probably by currying,
# to ensure maximal shortcut evaluation and preferably the ability
# to use an operation stack and a data stack. I'd like to
# eliminate "cond" in favor of "if" expressions or statements.
# Also I'm toying with the idea of object orientation because
# if we do want to do late binding we could pass the operations
# to the data rather than vice versa.


from types import StringTypes


def evlis_( m , a ):
	return cond (
		[ null_ ( m ), ( quote ( () ) ) ],
		[ quote ( "t" ), ( cons ( eval_ ( car ( m ) , a ) , evlis_ ( cdr ( m ) , a ) ) ) ],
	) )


def evcon_( c , a ):
	return cond (
		[ eval_ ( caar_ ( c ) , a ), ( eval_ ( cadar_ ( c ) , a ) ) ],
		[ quote ( "t" ), ( evcon_ ( cdr ( c ) , a ) ) ],
	) )


def eval_( e , a ):
	return cond (
		[ atom ( e ), ( assoc_ ( e , a ) ) ],
		[ atom ( car ( e ) ), ( cond (
			[ eq ( car ( e ) , quote ( quote ) ), ( cadr_ ( e ) ) ],
			[ eq ( car ( e ) , quote ( atom ) ), ( atom ( eval_ ( cadr_ ( e ) , a ) ) ) ],
			[ eq ( car ( e ) , quote ( eq ) ), ( eq ( eval_ ( cadr_ ( e ) , a ) , eval_ ( caddr_ ( e ) , a ) ) ) ],
			[ eq ( car ( e ) , quote ( car ) ), ( car ( eval_ ( cadr_ ( e ) , a ) ) ) ],
			[ eq ( car ( e ) , quote ( cdr ) ), ( cdr ( eval_ ( cadr_ ( e ) , a ) ) ) ],
			[ eq ( car ( e ) , quote ( cons ) ), ( cons ( eval_ ( cadr_ ( e ) , a ) , eval_ ( caddr_ ( e ) , a ) ) ) ],
			[ eq ( car ( e ) , quote ( cond ) ), ( evcon_ ( cdr ( e ) , a ) ) ],
			[ quote ( "t" ), ( eval_ ( cons ( assoc_ ( car ( e ) , a ) , cdr ( e ) ) , a ) ) ],
		) ) ],
		[ eq ( caar_ ( e ) , quote ( lambda_ ) ), ( eval_ ( caddar_ ( e ) , append_ ( pair_ ( cadar_ ( e ) , evlis_ ( cdr ( e ) , a ) ) , a ) ) ) ],
		[ eq ( caar_ ( e ) , quote ( label_ ) ), ( eval_ ( cons ( caddar_ ( e ) , cdr ( e ) ) , cons ( list_ ( cadar_ ( e ) , car ( e ) ) , a ) ) ) ],
	)


def assoc_( x , y ):
	return cond (
		[ eq ( caar_ ( y ) , x ), ( cadar_ ( y ) ) ],
		[ quote ( "t" ), ( assoc_ ( x , cdr ( y ) ) ) ],
	)


def pair_( x , y ):
	return cond (
		[ and_ ( null_ ( x ) , null_ ( y ) ), ( quote ( () ) ) ],
		[ and_ ( not_ ( atom ( x ) ) , not_ ( atom ( y ) ) ), ( cons ( list_ ( car ( x ) , car ( y ) ) , pair_ ( cdr ( x ) , cdr ( y ) ) ) ) ],
	)


def append_( x , y ):
	return cond (
		[ null_ ( x ), ( y ) ],
		[ quote ( "t" ), ( cons ( car ( x ) , append_ ( cdr ( x ) , y ) ) ) ],
	)


def caddar_( x ):
	return car ( cdr ( cdr ( car ( x ) ) ) )


def cadar_( x ):
	return car ( cdr ( car ( x ) ) )


def caar_( x ):
	return car ( car ( x ) )


def caddr_( x ):
	return car ( cdr ( cdr ( x ) ) )


def cadr_( x ):
	return car ( cdr ( x ) )


def list_( x , y ):
	return cons ( x , cons ( y , quote ( () ) ) )


def not_( x ):
	return cond (
		[ x , quote ( () ) ],
		[ quote ( "t" ), ( quote ( "t" ) ) ],
	)


def and_( x , y ):
	return cond (
		[ x , cond (
			[ y , quote ( "t" ) ],
			[ quote ( "t" ), ( quote ( () ) ) ],
		) ] ,
		[ quote ( "t" ), ( quote ( () ) ) ],
	)


def null_( x ):
	return eq ( x , quote ( () ) )


#def if_(c, t, f):
#	result = f
#	if c:
#		result = t
#	return result


def atom(x):
	return x == () or isinstance(x, StringTypes)


def car(x):
	return x[0]


def cdr(x):
	return x[1:]


def cond(x):
	result = ()
	for c in x:
		if c[0] == "t":
			result = c[1]
			break
	return result


def cons(x, y):
	return (x, ) + y


def eq(x, y):
	return atom(x) and atom(y) and x == y


def quote(x):
	return x
