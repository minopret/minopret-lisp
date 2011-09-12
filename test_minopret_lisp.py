#!/usr/bin/python

# Aaron Mansheim, 2011-09-09
# Test of minopret_lisp.py

import unittest
from types import TupleType
from minopret_lisp import _quote, _atom, _car, _cdr, _cons, _cond, _eq
from minopret_lisp import _definition, _fixpoint, _load_the_language

class test_minopret_lisp(unittest.TestCase):

    def test_quote(self):
        e = _quote("list")
        self.assertEqual(e, "list")

    def test_atom(self):
        e = _atom(())
        self.assertEqual(e, "t")
        e = _atom("list")
        self.assertEqual(e, "t")
        e = _atom(("list", "a"))
        self.assertEqual(e, ())
    
    def test_eq(self):
        e = _eq("a", "a")
        self.assertEqual(e, "t")
        e = _eq("a", "b")
        self.assertEqual(e, ())
        e = _eq((), ())
        self.assertEqual(e, "t")
    
    def test_cons(self):
        e = _cons("a", ())
        self.assertEqual(e, ("a", ))
    
    def test_car(self):
        e = _car(("a", "b"))
        self.assertEqual(e, "a")
    
    def test_cdr(self):
        e = _cdr(("a", "b"))
        self.assertEqual(e, ("b", ))
    
    def test_cond(self):
        pass
        
    def test_definition(self):
        e = _definition(
            (("a", "b"), ("u", "v")),
            "c",
            ("x", "y"),
            ("cons", "x", ("cdr", "y"))
        )
        self.assertEqual(e, (
            ("c", (
                "lambda",
                ("x", "y"),
                ("cons", "x", ("cdr", "y")),
            )),
            ("a", "b"),
            ("u", "v"),
        ))
        
    def test_fixpoint(self):
        e = _fixpoint(
            (("a", "b"), ("u", "v")),
            "c",
            ("x", "y"),
            ("cons", "x", ("c", "y", "a"))
        )
        self.assertEqual(e, (
            (
                "c",
                (
                    "label",
                    "c",
                    (
                        "lambda",
                        ("x", "y"),
                        ("cons", "x", ("c", "y", "a")),
                    ),
                ),
            ),
            ("a", "b"),
            ("u", "v"),
        ))
    
    def test_load_the_language(self):
        env = _load_the_language()
        envd = dict(env)
        definitions_of_one_param = (
            "not null cadr caddr caar cadar caddar"
        ).split()
        definitions_of_two_params = (
            "and list"
        ).split()
        fixpoints_of_two_params = (
            "append assoc eval evcon evlis pair"
        ).split()
        predefines = definitions_of_one_param \
            + definitions_of_two_params \
            + fixpoints_of_two_params
        self.assertEqual(len(envd), len(predefines))
        # Every definition is a lambda construction with a list as body
        for atom in definitions_of_one_param + definitions_of_two_params:
            e = envd[atom]
            self.assertEqual(len(e), 3)
            self.assertEqual(e[0], "lambda")
            self.assertTrue(isinstance(e[1], tuple))
            self.assertTrue(isinstance(e[2], tuple))
        for atom in definitions_of_one_param:
            e = envd[atom]
            self.assertEqual(len(e[1]), 1)
        for atom in definitions_of_two_params:
            e = envd[atom]
            self.assertEqual(len(e[1]), 2)
        for atom in fixpoints_of_two_params:
            e = envd[atom]
            self.assertEqual(len(e), 3)
            self.assertEqual(e[0], "label")
            self.assertEqual(len(e[2]), 3)
            self.assertEqual(e[2][0], "lambda")
            self.assertEqual(len(e[2][1]), 2)


if __name__ == '__main__':
    unittest.main()

