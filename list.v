Require Export hex.

(* Handle functions that don't always apply well to their input type *)
Inductive option {X: Type} : Type :=
| Some : X -> @option X
| None : @option X.

(* Time to start defining Lisp data. *)

Inductive expr : Type :=
| nil : expr
| symbol : hex -> expr
| cons : expr -> expr -> expr.

Definition car (x : expr) : @option expr :=
match x with
| nil => None
| symbol _ => None
| cons u _ => Some u
end.

Definition cdr (x: expr) : @option expr :=
match x with
| nil => Some nil
| symbol _ => None
| cons _ v => Some v
end.

Definition sym_t : expr := symbol (d4 (h7)).

Definition atom (x: expr) : expr :=
match x with
| nil => sym_t
| symbol _ => sym_t
| cons _ _ => nil
end.

Fixpoint cond (x: expr) : @option expr :=
match x with
| nil => None
| symbol _ => None
| cons u v => 

(*
    US-ASCII printable

    0 1 2 3 4 5 6 7 8 9 A B C D E F

2     ! ''# $ % & ' ( ) * + , - . /
3   0 1 2 3 4 5 6 7 8 9 : ; < = > ?
4   @ A B C D E F G H I J K L M N O
5   P Q R S T U V W X Y Z [ \ ] ^ _
6   ` a b c d e f g h i j k l m n o
7   p q r s t u v w x y z { | } ~
*)

Definition sym_and : expr :=
  symbol (d4 (d6 (dE (d6 (d1 h6))))).

Definition sym_append : expr :=
  symbol (d4 (d6 (dE (d6 (d5 (d6 (d0 (d7 (d0 (d7 (d1 h6))))))))))).

Definition sym_assoc : expr :=
  symbol (d3 (d6 (dF (d6 (d3 (d7 (d3 (d7 (d1 h6))))))))).

Definition sym_atom : expr :=
  symbol (dD (d6 (dF (d6 (d4 (d7 (d1 h6))))))).

Definition sym_caar : expr :=
  symbol (d2 (d7 (d1 (d6 (d1 (d6 (d3 h6))))))).

Definition sym_cadar : expr :=
  symbol (d2 (d7 (d1 (d6 (d4 (d6 (d1 (d6 (d3 h6))))))))).

Definition sym_caddar : expr :=
  symbol (d2 (d7 (d1 (d6 (d4 (d6 (d4 (d6 (d1 (d6 (d3 h6))))))))))).

Definition sym_cadr : expr :=
  symbol (d2 (d7 (d4 (d6 (d1 (d6 (d3 h6))))))).

Definition sym_caddr : expr :=
  symbol (d2 (d7 (d4 (d6 (d4 (d6 (d1 (d6 (d3 h6))))))))).

Definition sym_car : expr :=
  symbol (d2 (d7 (d1 (d6 (d3 h6))))).

Definition sym_cdr : expr :=
  symbol (d2 (d7 (d4 (d6 (d3 h6))))).

Definition sym_cond : expr :=
  symbol (d4 (d6 (dE (d6 (dF (d6 (d3 h6))))))).

Definition sym_cons : expr :=
  symbol (d3 (d7 (dE (d6 (dF (d6 (d3 h6))))))).

Definition sym_eq : expr :=
  symbol (d1 (d7 (d5 h6))).

Definition sym_eval : expr :=
  symbol (dC (d6 (d1 (d6 (d6 (d7 (d5 h6))))))).

Definition sym_evcon : expr :=
  symbol (dE (d6 (dF (d6 (d3 (d6 (d6 (d7 (d5 h6))))))))).

Definition sym_evlis : expr :=
  symbol (d3 (d7 (d9 (d6 (dC (d6 (d6 (d7 (d5 h6))))))))).

Definition sym_label : expr :=
  symbol (dC (d6 (d5 (d6 (d2 (d6 (d1 (d6 (dC h6))))))))).

Definition sym_lambda : expr :=
  symbol (d1 (d6 (d4 (d6 (d2 (d6 (dD (d6 (d1 (d6 (dC h6))))))))))).

Definition sym_expr : expr :=
  symbol (d4 (d7 (d3 (d7 (d9 (d6 (dC h6))))))).

Definition sym_not : expr :=
  symbol (d4 (d7 (dF (d6 (dE h6))))).

Definition sym_null : expr :=
  symbol (dC (d6 (dC (d6 (d5 (d7 (dE h6))))))).

Definition sym_pair : expr :=
  symbol (d2 (d7 (d9 (d6 (d1 (d6 (d0 h7))))))).

Definition sym_quote : exprS :=
  symbol (d5 (d6 (d4 (d7 (dF (d6 (d5 (d7 (d1 h7))))))))).