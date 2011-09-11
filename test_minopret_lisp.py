#!/usr/bin/python

# Aaron Mansheim, 2011-09-09
# Test of minopret_lisp.py

import unittest
from types import TupleType
from minopret_lisp import _quote, _atom, _car, _cdr, _cons, _cond, _eq
from minopret_lisp import _defun, _load_the_builtins, _load_the_language
from minopret_lisp import _eval

class test_minopret_lisp(unittest.TestCase):

    def test_quote(self):
        e = _quote("list")
        self.assertEqual(e, "list")

    def test_atom(self):
        e = _atom(())
        self.assertEqual(e, "t")
        e = _atom("list")
        self.assertEqual(e, "t")
        e = _atom(_atom)
        self.assertEqual(e, "t")
        e = _atom(("list", "a"))
        self.assertEqual(e, ())
    
    def test_eq(self):
        e = _eq("a", "a")
        self.assertEqual(e, "t")
        e = _eq("a", "b")
        self.assertEqual(e, ())
    
    def test_cons(self):
        e = _cons("a", ())
        self.assertEqual(e, ("a", ))
    
    def test_car(self):
        e = _car(("a", "b"))
        self.assertEqual(e, "a")
    
    def test_cdr(self):
        e = _cdr(("a", "b"))
        self.assertEqual(e, ("b", ))
    
    def do_not_test_cond(self):
        pass
        
    def test_defun(self):
        e = _defun(
            (("a", "b"), ("u", "v")),
            "c",
            ("x", "y"),
            ("cons", "x", ("cdr", "y"))
        )
        self.assertEqual(e, (
            ("c", (
                ("lambda", ("x", "y")),
                ("cons", "x", ("cdr", "y")),
            )),
            ("a", "b"),
            ("u", "v"),
        ))

    def check_builtins(self, d):
        builtins = "atom car cdr cond cons eq quote".split()
        self.assertEqual(d["atom"], _atom)
        self.assertEqual(d["car"], _car)
        self.assertEqual(d["cdr"], _cdr)
        self.assertEqual(d["cond"], _cond)
        self.assertEqual(d["cons"], _cons)
        self.assertEqual(d["eq"], _eq)
        self.assertEqual(d["quote"], _quote)
    
    def test_load_the_builtins(self):
        env = _load_the_builtins()
        envd = dict(env)
        self.check_builtins(envd)
        self.assertEqual(len(envd), 7)
    
    def test_load_the_language(self):
        env = _load_the_language()
        envd = dict(env)
        self.check_builtins(envd)
        predefines_of_two_params = (
            "and append assoc eval evcon evlis list pair"
        ).split()
        predefines_of_one_param = "not null".split()
        predefines = predefines_of_one_param + predefines_of_two_params
        self.assertEqual(len(envd), 7 + len(predefines))
        # Every predefine is a lambda construction with a list as body
        for atom in predefines:
            e = envd[atom]
            self.assertEqual(len(e[0]), 2)
            self.assertEqual(e[0][0], "lambda")
            self.assertTrue(isinstance(e[1], tuple))
        for atom in predefines_of_one_param:
            e = envd[atom]
            self.assertEqual(len(e[0][1]), 1)
        for atom in predefines_of_two_params:
            e = envd[atom]
            self.assertEqual(len(e[0][1]), 2)
        
    
    def test_eval_an_atom(self):
        bogus_env = ("bogus", "env")
        result = _eval((), bogus_env)
        self.assertEqual(result, ((), bogus_env))
        result = _eval("a", bogus_env)
        self.assertEqual(result, ("a", bogus_env))  # questionable spec
        result = _eval(_atom, bogus_env)
        self.assertEqual(result, (_atom, bogus_env))

    def test_eval_an_applied_builtin(self):
        bogus_env = ("bogus", "env")
        result = _eval((_atom, "list"), bogus_env)
        self.assertEqual(result, ("t", bogus_env))
        result = _eval((_eq, "list", "list"), bogus_env)
        self.assertEqual(result, ("t", bogus_env))
        result = _eval((_eq, "list", "null"), bogus_env)
        self.assertEqual(result, ((), bogus_env))
        # result = _eval((_cond, ...), bogus_env)
        # self.assertEqual(result, (..., bogus_env))
        

if __name__ == '__main__':
    unittest.main()

