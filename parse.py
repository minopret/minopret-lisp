from re import sub, M

def pprint(sexpr):
	if isinstance(sexpr, list):
		if len(sexpr) > 0:
			if len(sexpr[0]) > 1:
				pprint(sexpr[0]),
				print '(',
				pprint(sexpr[1]),
				for e in sexpr[2:]:
					print ",",
					pprint(e)
				print ')',
			else:
				print '[',
				print sexpr[0],
				for e in sexpr[1:]:
					print ",",
					pprint(e)
				print ']',
		else:
			print '()',
	else:
		print patom(sexpr),

def patom(s):
	s = s.replace('.', '')
	if s in syms:
		return s
	else:
		return "'" + s + "'"

def atom_num(s):
	d = 0
	for c in s:
		d *= 256
		d += ord(c)
	return d

syms = set("evcon evlis atom eq cond car cdr cons assoc quote append null list pair and not cadr caddr caar cadar caddar eval lambda label".split())

def atom_id(s):
	s = s.replace('.', '')
	if s in syms:
		return "sym_" + s
	else:
		#return '[' + s + ']'
		d = atom_num(s)
		h = list(hex(d))[2:]
		if h[-1] == 'L':
			h = h[0:-1]
		h.reverse()
		hn = h[-1]
		h = h[0:-1]
		nh = len(h)
		h = ' (d'.join(h)
		h += ' h' + hn + (')' * nh)
		#print h
		s = "symbol (d"
		s += h
		return '(' + s + ')'
		#return s

def id_str(d):
	s = ''
	while d > 0:
		(q, r) = divmod(d, 256)
		s = chr(r) + s
		d = q
	return s

def gprint(sexpr):
	if isinstance(sexpr, list):
		if len(sexpr) == 0:
			print 'nil ',
		else:
			ns = len(sexpr)
			while len(sexpr) > 1:
				print '(cons ',
				gprint(sexpr[0]),
				print " ",
				sexpr = sexpr[1:]
			gprint(sexpr[0])
			print ")" * (ns - 1),
	else:
		print atom_id(sexpr),

f = open("lisp3.lisp", "r")
mnplisp = f.read()
f.close()

mnplisp = sub(r'^\s*;.*', r'', mnplisp, 0, flags=M)  # drop comment lines
mnplisp = sub(r'\(', r'( ', mnplisp)  # insert space after open
mnplisp = sub(r'\)', r' )', mnplisp)  # insert space before close
tokens = mnplisp.split()  # tokenize on whitespace (acknowledgment: Peter Norvig in 'lis.py')

expr = []
stack = [expr,]

def add_token(tok):
	stack[-1].append(tok)

def begin_list(quoted = False):
	new_list = []
	if quoted == True:
		new_list.append("quote")
		newer_list = []
		new_list.append(newer_list)
		stack[-1].append(new_list)
		stack.append(new_list)
		new_list = newer_list
	stack[-1].append(new_list)
	stack.append(new_list)
	
def end_list():
	if len(stack) > 1 and len(stack[-2]) > 0 and stack[-2][0] == "quote":
		stack.pop()
	stack.pop()
	
for t in tokens:
	if t == '(':
		begin_list()
	elif t == ')':
		end_list()
	elif t == "'(":
		begin_list(quoted = True)
	else:
		add_token(t)

def for_python():
	for sexpr in stack[0]:
		pprint(sexpr)
		print

def for_gallina():
	for sexpr in stack[0]:
		gprint(sexpr)
		print

