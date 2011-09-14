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
		print sexpr,

def atom_id(s):
	d = 0
	for c in s:
		d *= 256
		d += ord(c)
	return d

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
			print '(',
			gprint(sexpr[0]),
			for e in sexpr[1:]:
				print " ",
				gprint(e)
			print ')',
	else:
		print atom_id(sexpr),

f = open("minopret.lisp", "r")
mnplisp = f.read()
f.close()

mnplisp = sub(r'^\s*;.*', r'', mnplisp, 0, flags=M)  # drop comment lines
mnplisp = sub(r'\(', r'( ', mnplisp)  # insert space after open
mnplisp = sub(r'\)', r' )', mnplisp)  # insert space before cloes
tokens = mnplisp.split()  # tokenize on whitespace (acknowledgment: Peter Norvig in 'lis.py')

stack = [[]]
level = 0
for t in tokens:
	if t == '(':
		stack.append([])
		level += 1
	elif t == ')':
		stack[level - 1].append(stack[level])
		stack.pop()
		level -= 1
	else:
		stack[level].append(t)

def for_python():
	for sexpr in stack[0]:
		pprint(sexpr)
		print

def for_gallina():
	for sexpr in stack[0]:
		gprint(sexpr)
		print

