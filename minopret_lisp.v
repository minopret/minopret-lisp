(*
   Apparatus for defining a Lisp within Coq.
   Aaron Mansheim, 2011-09-14 to 2011-09-15

   Imports: nothing! Ha ha!
   Uses: Inductive Definition Fixpoint Type Prop
         match -> = forall
         (From "Software Foundations" we know that
         "=" is notation for Type eq, constructor refl_equal
         in the standard library - and we're free to define our own!
         And that "->" is only a special case of "forall"!)
   And some logic & tactic stuff:
         Theorem Lemma Proof Qed
         (plus various proof tactics, but their validity is
         entirely subject to verification by the type checker
         every time that we write "Qed")
   Acknowledges: Benjamin S. Pierce et al., "Software Foundations"
     A fair amount of this is stuff that I learned from that
     and that is present in its SfLib.v.
   Rights: I have not directly copied anything.
     Now, as far as I can easily tell, SfLib.v assigns copyright to
     its authors. However, so much of what I've used is fundamental
     to ML-like languages or foundations of mathematics that
     I really doubt copyright applies to the selection or,
     in few cases such as "bool", even the expression of the ideas.
     the expression. Also this is definitely not an appropriate
     substitute in any way for any part of "Software Foundations".
   Commonalities with SfLib.v (again, I have not directly copied but
     may have recreated the material that I learned - although
     frankly I'm not as good at this and my versions may in
     many cases be different because they're inferior!):
     option, nat, bool, beq_nat, eq_remove_S, double, bin,
     next_bin, ...
     And these, but are the names the same as in SfLib.v?
     beq_nat__eq, bin_nat, next_bin_ok, ...
*)

Require Export hex.
Require Export list.


Definition vcaar (x : list) : @option list :=
match x with
| nil => None
| symbol _ => None
| cons u _ => match u with
  | nil => None
  | symbol _ => None
  | cons u' _ => Some u'
  end
end.

Definition vcadr (x : list) : @option list :=
match x with
| nil => None
| symbol _ => None
| cons _ v => match v with
  | nil => None
  | symbol u' => Some v
  | cons _ _ => Some v
  end
end.

Definition vcaddr (x : list) : @option list :=
match x with
| nil => None
| symbol _ => None
| cons _ v => match v with
  | nil => None  
  | symbol _ => None
  | cons _ v' => match v' with
    | nil => None
    | symbol _ => None
    | cons u _ => Some u
    end
  end
end.

Definition vcadar (x : list) : @option list :=
match x with
| nil => None
| symbol _ => None
| cons u _ => match u with
  | nil => None
  | symbol _ => None
  | cons _ v => match v with
    | nil => None
    | symbol _ => Some v
    | cons _ _ => Some v
    end
  end
end.

Compute (vcadar (cons (cons (symbol hA) (cons (symbol hB) nil)) (cons (symbol hC) nil))).


Definition eq (x y: list) : list :=
match x with
| nil => match y with
  | nil => sym_t
  | symbol _ => nil
  | cons _ _ => nil
  end
| symbol n => match y with
  | nil => nil
  | symbol m => ...
  | cons _ _ => nil
  end
| cons _ _ => nil
end.




Definition label_caar : list :=
  cons sym_label (cons sym_caar (cons
    (cons sym_lambda (cons
      (cons (symbol (d1 h6)) nil)
      (cons
        (cons sym_car (cons
          (cons sym_car (cons (symbol (d1 h6)) nil))
          nil))
        nil)))
     nil)).