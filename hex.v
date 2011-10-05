(* Keep this in your back pocket:
   Coq fully enables us to define equality rather than use the
   equality built in. However, redefining equality is a bit
   inconvenient. The rewrite tactics are written to use the
   built-in equality.

Inductive eq {X: Type} (a : X) : X -> Prop :=
| refl_equal : eq a a.

*)



(* My favorite big hammer to wield *)
Theorem functionality : forall (X Y : Type) (f : X -> Y) (u v : X),
  u = v -> f u = f v.
Proof. intros X Y f u v H. rewrite H. reflexivity.
Qed.



(* Propositional logic *)

Inductive False : Prop :=
(* no constructor - In Coq, "False" literally means "no way" *) .

(* This "principle of explosion" may help to
   motivate the next definition.
*)
Theorem ex_falso_quodlibet : forall P : Prop, False -> P.
Proof. intros P H. inversion H. Qed.

(* Here is our standard by which all other truths are measured. *)
Definition True : Prop := False -> False.

(* 
   Novices in Coq etc.: Please interpret this next declaration thus:
     "If you have ANY proof objects for propositions P and Q,
      'conj' accepts them as proof of proposition 'and P Q'."

   Experts in Coq etc.: Yes, I know there's a more compact notation.
*)
Inductive and (P Q : Prop) : Prop :=
| conj : forall (_ : P) (_ : Q), and P Q.

Definition not (P : Prop) : Prop := P -> False.

Definition iff (P Q : Prop) : Prop := and (P -> Q) (Q -> P).



(* This proposition defines two-element boolean algebra
   as any algebraic structure whose statements are convertible to
   propositions (Prop), and are built from objects for
     conjunction (and), negation (not), verity (true), and falsity (false)
   with appropriate equations relating these.
   More info about this and its equations:
http://homepages.feis.herts.ac.uk/~comqejb/algspec/pr.html
http://en.wikipedia.org/w/index.php?title=Two-element_Boolean_algebra&oldid=432309715#Some_basic_identities

   It's sort of stupid that I'm using an "elegant" (implying, not-so-obvious)
   axiomatization of boolean algebra in what is basically a tutorial work.
   But I'd better move on from here or this will never be done.
*)
Definition models_boolean_algebra_2 (X: Type)
  (f t: X) (feq: X -> X -> Prop) (fand: X -> X -> X) (fnot: X -> X) : Prop :=
forall a b c : X,
and (and (feq (fand (fand a b) c) (fand (fand b c) a))
         (and (feq (fand (fnot a) a) f)
              (not (t = f))))
    (and (feq (fand a t) a)
         (feq (fand a (fnot (fand a b))) (fand a (fnot b)))).


(* Been wondering, how would I define a type for
models of the two-element boolean algebra? *)


Theorem boolean_algebra_for_Prop :
  models_boolean_algebra_2 Prop False True iff and not.
Proof. unfold models_boolean_algebra_2. intros a b c. split. split. split.
(* abc -> bca *) intros H. inversion H as [Hab Hc]. inversion Hab as [Ha Hb].
  assert (Kbc: and b c). apply (conj b c Hb Hc). apply (conj (and b c) a Kbc Ha).
(* bca -> abc *) intros H. inversion H as [Hbc Ha]. inversion Hbc as [Hb Hc].
  assert (Kab: and a b). apply (conj a b Ha Hb). apply (conj (and a b) c Kab Hc).
split. split.
(* and (not a) a -> False *) intros H. inversion H as [Hn Ha]. unfold not in Hn.
  apply Hn in Ha. inversion Ha.
(* False -> and (not a) a *) intros H. inversion H.
(* not (True = False) *) unfold not. intros H. rewrite <- H.
  unfold True. intros HF. inversion HF.
split. split.
(* and a True -> a *) intros H. inversion H as [Ha Ht]. apply Ha.
(* a -> and a True *) intros H. split. apply H. unfold True. intros H2. apply H2.
split.
(* and a (not (and a b)) -> and a (not b) *) intros H. inversion H as [Ha Hab].
  unfold not in Hab. split. apply Ha. unfold not. intros Hb.
  assert (K: and a b). apply (conj a b Ha Hb). apply Hab in K. inversion K.
(* and a (not b) -> and a (not (and a b)) *) intros H. inversion H as [Ha Hn].
  split. apply Ha. unfold not. intros Hab. inversion Hab as [Hd Hb].
  unfold not in Hn. apply Hn in Hb. inversion Hb.
Qed.



(* Now, boolean algebra as functions of "truthy" and "falsy" data *)

(* Note that this type "bool" works as expected with Coq's
   "if _ then _ else _" simply because "bool" has two constructors and
   the constructor for "true" is the first of the two.
 *)
Inductive bool : Type :=
| true : bool
| false : bool.

Definition andb (x y : bool) : bool :=
if x then (if y then true else false) else false.

Definition negb (x : bool) : bool := if x then false else true.



Theorem boolean_algebra_2_on_bool :
  models_boolean_algebra_2 bool false true (@eq bool) andb negb.
Proof. unfold models_boolean_algebra_2. intros a. destruct a as [|].
(* a *) intros b. destruct b as [|].
  (* b *) intros c. destruct c as [|].
    (* c *) simpl. split. split. reflexivity.
      split. reflexivity.
      unfold not. intros H. inversion H.
      split. reflexivity. reflexivity.
    (* ~c *) simpl. split. split. reflexivity.
      split. reflexivity.
      unfold not. intros H. inversion H.
      split. reflexivity. reflexivity.
  (* ~b *) intros c. simpl. split. split. reflexivity.
      split. reflexivity.
      unfold not. intros H. inversion H.
    split. reflexivity. reflexivity.
(* ~a *) intros b. destruct b as [|].
  (* b *) intros c. destruct c as [|].
    (* c *) simpl. split. split. reflexivity.
      split. reflexivity.
      unfold not. intros H. inversion H.
      split. reflexivity. reflexivity.
    (* ~c *) simpl. split. split. reflexivity.
      split. reflexivity.
      unfold not. intros H. inversion H.
      split. reflexivity. reflexivity.
  (* ~b *) intros c. simpl. split. split. reflexivity.
      split. reflexivity.
      unfold not. intros H. inversion H.
    split. reflexivity. reflexivity.
Qed.



Definition reflexive {X: Type} (f : X -> X -> Prop) : Prop :=
forall x : X, f x x.

Definition symmetric {X: Type} (f : X -> X -> Prop) : Prop :=
forall x y : X, f x y -> f y x.

Definition transitive {X: Type} (f : X -> X -> Prop) : Prop :=
forall x y z : X, f x y -> f y z -> f x z.

Definition equivalence_relation {X: Type} (f : X -> X -> Prop) : Prop :=
and (reflexive f) (and (symmetric f) (transitive f)).



(* This proposition defines counting numbers,
   more specifically second-order Peano axioms.
http://en.wikipedia.org/w/index.php?title=Peano_axioms&oldid=450336562#The_axioms
 *)

Definition models_natural_numbers 
  (N: Type) (least : N)  (eqn : N -> N -> Prop) (fsucc : N -> N)
  (B: Type) (f t: B) (eqb: B -> B -> Prop) (fand: B -> B -> B) (fnot: B -> B)
  : Prop :=
and (models_boolean_algebra_2 B f t eqb fand fnot) (
  and (equivalence_relation eqn) (
    and (forall (n : N), not (eqn least (fsucc n))) (
      and (forall (n m : N), (eqn (fsucc n) (fsucc m)) -> (eqn n m)) (
        forall (P : N -> B),
          (eqb (P least) t) ->
          (forall (n : N), eqb (P n) t -> (eqb (P (fsucc n))) t) ->
          (forall (n : N), eqb (P n) t)
      )
    )
  )
).




(* Natural numbers in unary notation *)
Inductive nat : Type :=
| O : nat
| S : nat -> nat.

Theorem eq_remove_S : forall (n m : nat),
n = m -> S n = S m.
Proof. intros n. induction n as [| n'].
(* n = O *) intros m H. induction m as [| m'].
  (* m = O *) reflexivity.
  (* m = S m' *) inversion H.
(* n = S n' *) intros m H. induction m as [| m'].
  (* m = O *) inversion H.
  (* m = S m' *) rewrite H. reflexivity.
Qed.

(* What do I mean by "classifier"?
   For example, the function c(n, m) = remainder(n, m)
   is a classifier for integers under the equivalence relation
     e(a, b) that includes pairs (a, b) that satisfy
     a == b (modulo m).
*)
(*
Definition is_classifier {X: Type} (c : X -> X) (e : X -> X -> Prop) : Prop
:=
    equivalence_relation e ->
    forall x : X,  ( e x (c x) /\ forall (y : X), e x y -> (e y (c x)) ).

Definition is_homomorphism {X Y: Type} (f : X -> Y)
  (eX : X -> X -> Prop) (eY : Y -> Y -> Prop) : Prop :=
forall (cX : X -> X) (cY : Y -> Y),
  is_classifier cX eX -> is_classifier cY eY ->
  forall (x1 x2 : X), cX x1 = cX x2 -> cY (f x1) = cY (f x2).

(* I think I'm haven't quite achieved the right statement of this one. *)
Theorem equiv_functionality : forall (X Y: Type)
  (eX : X -> X -> Prop) (cX : X -> X)
  (f : X -> Y) (u v : X),
is_classifier cX eX -> eX v (cX u) -> cX v = cX u.
*)

(* My favorite big hammer to wield *)
(* Theorem functionality : forall (X Y : Type) (f : X -> Y) (u v : X),
  u = v -> f u = f v.
Proof. intros X Y f u v H. rewrite H. reflexivity.
Qed. *)

(* Theorem equiv_remove_S : forall (equiv : nat -> nat -> Prop) (n m : nat),
  equivalence_relation equiv -> equiv n m -> equiv (S n) (S m).
Proof. intros equiv n. induction n as [| n']. *)
(* n = O *) (* intros m Hequiv H. inversion Hequiv as [Hr Hst].
  unfold reflexive in Hr. induction m as [| m']. *)
  (* m = O *) (* apply Hr. *)
  (* m = S m' *)

Definition pred (n : nat) : nat :=
match n with
| O => O  (* best we can do *)
| S n' => n'
end.

Theorem eq_add_S : forall (n m : nat),
S n = S m -> n = m.
Proof. intros n. induction n as [| n'].
(* n = O *) intros m H. induction m as [| m'].
  (* m = O *) reflexivity.
  (* m = S m' *) inversion H.
(* n = S n' *) intros m H.
  apply (functionality nat nat pred) in H.
  simpl in H. apply H.
Qed.

Fixpoint beq_nat (n m : nat) : bool :=
match n with
| O => match m with
  | O => true
  | S _ => false
  end
| S n' => match m with
  | O => false
  | S m' => beq_nat n' m'
  end
end.

Theorem beq_nat__eq : forall (n m : nat),
  beq_nat n m = true -> n = m.
Proof. intros n. induction n as [| n'].
(* n = O *) intros m H. induction m as [| m'].
  (* m = O *) reflexivity.
  (* m = S m' *) simpl in H. inversion H.
(* n = S n' *) intros m H. induction m as [| m'].
  (* m = O *) simpl in H. inversion H.
  (* m = S m' *) simpl in H. apply IHn' in H.
     apply eq_remove_S. apply H.
Qed.

Theorem eq__beq_nat : forall (n m : nat),
  n = m -> beq_nat n m = true.
Proof. intros n. induction n as [| n'].
(* n = O *) intros m H. induction m as [| m'].
  (* m = O *) reflexivity.
  (* m = S m' *) inversion H.
(* n = S n' *) intros m H. induction m as [| m'].
  (* m = O *) inversion H.
  (* m = S m' *) rewrite <- H. simpl. apply IHn'. reflexivity.
Qed.

Lemma beq_nat_refl: reflexive (fun (n m: nat) => beq_nat n m = true).
unfold reflexive. intros x. induction x as [| x'].
  (* refl O *) reflexivity.
  (* refl S x' *) simpl. apply IHx'.
Qed.

Lemma beq_nat_symm: symmetric (fun (n m: nat) => beq_nat n m = true).
Proof. unfold symmetric. intros x. induction x as [| x'].
  (* symm O y *) intros y H. destruct y as [| y'].
    (* symm O O *) reflexivity.
    (* symm O (S y') *) inversion H.
  (* symm (S x') y *) intros y H. induction y as [| y'].
    (* symm (S x') O *) inversion H.
    (* symm (S x') (S y') *) simpl. apply IHx'. simpl in H. apply H.
Qed.

Lemma beq_nat_trans: transitive (fun (n m: nat) => beq_nat n m = true).
Proof. unfold transitive. intros x y z Hx Hz.
  apply beq_nat__eq in Hx. rewrite Hx. apply Hz.
Qed.

Theorem bequiv_nat:
  equivalence_relation (fun (n m: nat) => beq_nat n m = true).
Proof. unfold equivalence_relation. split.
(* refl *) apply beq_nat_refl.
split.
(* symm *) apply beq_nat_symm.
(* trans *) apply beq_nat_trans.
Qed.

Definition eqnb {B: Type} (t: B) (feq: B -> B -> Prop)
  (feqn: nat -> nat -> B): nat -> nat -> Prop :=
fun (n m: nat) => feq (feqn n m) t.



(* Because we have a couple of different boolean models,
   I want to arrange to plug them into this natural number
   model.
 *)(*
Theorem natural_numbers_on_nat :
  forall (B: Type) (f t: B) (feq: B -> B -> Prop)
    (fand: B -> B -> B) (fnot: B -> B),
    models_boolean_algebra_2 B f t feq fand fnot ->
    forall (feqn: nat -> nat -> B),
      equivalence_relation (eqnb t feq feqn) ->
      (forall n: nat, not ((eqnb t feq feqn) O (S n)) ) ->
      models_natural_numbers nat O (eqnb t feq feqn) S
        B f t feq fand fnot.
Proof. intros B f t feq fand fnot Hb feqn Heqnb Hneqnb.
unfold models_natural_numbers. split.
* boolean * apply Hb.
split.
* equiv * apply Heqnb.
split.
* O <> S n * apply Hneqnb.
split.
* eqn add S * intros n m H.
  inversion Heqnb as [Hr Hst]. inversion Hst as [Hs Ht].
  unfold reflexive in Hr. unfold symmetric in Hs.
  unfold transitive in Ht.


 simpl in H.
  simpl in H. apply H.
* nat_ind * intros P HO HS n. induction n as [| n'].
  * nat_ind O * apply HO.
  * nat_ind (S O) * apply HS in IHn'. apply IHn'.
Qed. *)



(* Binary-encoded positive natural numbers *)
Inductive bin : Type :=
| xH : bin
| xI : bin -> bin
| xO : bin -> bin.

(* Double a natural number *)
Fixpoint double (n : nat) : nat :=
match n with
| O => O
| S n' => S (S (double n'))
end.

(* Convert binary to unary *)
Fixpoint bin_nat (b : bin) : nat :=
match b with
| xH => S O (* every positive binary number has a leading 1 digit *)
| xI b' => S (double (bin_nat b'))
| xO b' => double (bin_nat b')
end.

(* Compute next binary number *)
Fixpoint next_bin (b : bin) : bin :=
match b with
| xH => xO xH
| xI b' => xO (next_bin b')
| xO b' => xI b'
end.

(* Verify that next_bin does for binary what
   the "S" constructor does for unary.
   What we're aiming for here is "isomorphism".
*)
Theorem next_bin__S : forall b : bin,
S (bin_nat b) = bin_nat (next_bin b).
Proof. intros b. induction b as [| b' | b'].
(* xH *) reflexivity.
(* xI *) simpl. rewrite <- IHb'. reflexivity.
(* xO *) reflexivity. Qed.

Fixpoint beq_bin (n m : bin) : bool :=
match n with
| xH => match m with
  | xH => true
  | xI _ => false
  | xO _ => false
  end
| xI n' => match m with
  | xH => false
  | xI m' => beq_bin n' m'
  | xO _ => false
  end
| xO n' => match m with
  | xH => false
  | xI _ => false
  | xO m' => beq_bin n' m'
  end
end.

Lemma double_O__O : forall n : nat,
  O = double n -> O = n.
Proof. intros n H. induction n as [| n'].
(* n = 0 *) reflexivity.
(* n = S n' *) simpl in H. inversion H.
Qed.

Fixpoint evenb (n : nat) : bool :=
match n with
| O => true
| S n' => if evenb n' then false else true
end.

Lemma double_nat_even : forall n : nat,
  evenb (double n) = true.
Proof. intros n. induction n as [| n'].
(* n = O *) reflexivity.
(* n = S n' *) simpl. rewrite IHn'. reflexivity.
Qed.

Lemma double_bin_even : forall b : bin,
  evenb (bin_nat (xO b)) = true.
Proof. intros b. simpl. apply double_nat_even. Qed.

Lemma beq_double : forall n m : nat,
  beq_nat (double n) (double m) = beq_nat n m.
Proof. intros n. induction n as [| n'].
(* n = O *) intros m. induction m as [| m'].
  (* m = O *) reflexivity.
  (* m = S m' *) reflexivity.
(* n = S n' *) intros m. induction m as [| m'].
  (* m = O *) reflexivity.
  (* m = S m' *) simpl. apply IHn'.
Qed.

Lemma beq_parity : forall n m : nat,
  beq_nat (double n) (S (double m)) = false.
Proof. intros n. induction n as [| n'].
(* n = O *) intros m. induction m as [| m'].
  (* m = O *) reflexivity.
  (* m = S m' *) reflexivity.
(* n = S n' *) intros m. induction m as [| m'].
  (* m = O *) reflexivity.
  (* m = S m' *) simpl. apply IHn'.
Qed.

Lemma bin_pos : forall b : bin,
  beq_nat (bin_nat b) O = false.
Proof. intros b. induction b as [| b' | b'].
(* b = xH *) reflexivity.
(* b = xI _ *) reflexivity.
(* b = xO _ *) simpl.
   assert (H: double O = O).
     reflexivity.
   rewrite <- H. rewrite beq_double. apply IHb'.
Qed.

Lemma bin_nat_xH : bin_nat xH = S O.
Proof. reflexivity. Qed.

Lemma bin_nat_xI : forall n : bin,
  bin_nat (xI n) = S (double (bin_nat n)).
Proof. reflexivity. Qed.

Lemma bin_nat_xO : forall n : bin,
  bin_nat (xO n) = double (bin_nat n).
Proof. reflexivity. Qed.

Theorem beq_bin__beq_nat : forall (n m : bin),
beq_bin n m = beq_nat (bin_nat n) (bin_nat m).
Proof. intros n. induction n as [| n' | n'].
(* n = xH *) intros m. induction m as [| m' | m'].
  (* m = xH *) reflexivity.
  (* m = xI m' *) simpl. remember (double (bin_nat m')) as dm'.
    induction dm' as [| dm''].
    (* dm' = O *) apply double_O__O in Heqdm'.
      symmetry in Heqdm'. apply eq__beq_nat in Heqdm'.
      rewrite bin_pos in Heqdm'. inversion Heqdm'.
    (* dm' = S dm'' *) reflexivity.
  (* m = xO m' *) rewrite bin_nat_xO.
    remember (double (bin_nat m')) as dm'.
    induction dm' as [| dm''].
    (* dm' = O *) reflexivity.
    (* dm' = S dm'' *) induction dm'' as [| dm'''].
      (* dm'' = O *)
        apply (functionality nat bool evenb
                             (S O) (double (bin_nat m'))) in Heqdm'.
        rewrite double_nat_even in Heqdm'. inversion Heqdm'.
      (* dm'' = S dm''' *) reflexivity.
(* n = xI n' *) intros m. induction m as [| m' | m'].
  (* m = xH *) simpl. assert (H: O = double O). reflexivity.
    rewrite H. rewrite beq_double. rewrite bin_pos. reflexivity.
  (* m = xI m' *) simpl. rewrite beq_double. apply IHn'.
  (* m = xO m' *) simpl. remember (bin_nat m') as nm'.
    induction nm' as [| nm''].
    (* nm' = O *) reflexivity.
    (* nm' = S nm'' *) simpl. symmetry. apply beq_parity.
(* n = xO n' *) intros m. induction m as [| m' | m'].
  (* m = xH *) simpl. symmetry. assert (H: O = double O). reflexivity.
    rewrite H. apply beq_parity.
  (* m = xI m' *) simpl. symmetry. apply beq_parity.
  (* m = xO m' *) simpl. rewrite beq_double. apply IHn'.
Qed.

Theorem bequiv_bin :
  equivalence_relation (fun (n m: bin) => beq_bin n m = true).
Proof. unfold equivalence_relation. split.
(* refl *) unfold reflexive. intros x. rewrite beq_bin__beq_nat.
  apply beq_nat_refl.
split.
(* symm *) unfold symmetric. intros x y H. rewrite beq_bin__beq_nat.
  rewrite beq_bin__beq_nat in H. apply beq_nat_symm. apply H.
(* trans *) unfold transitive. intros x y z Hx Hz. rewrite beq_bin__beq_nat.
  rewrite beq_bin__beq_nat in Hx. rewrite beq_bin__beq_nat in Hz.
  apply (beq_nat_trans (bin_nat x) (bin_nat y) (bin_nat z) Hx Hz).
Qed.

(* Theorem natural_numbers_on_bool_and_bin : models_natural_numbers
  bin xH (fun (n m: bin) => beq_bin n m = true) next_bin
  bool false true (@eq bool) andb negb.
Proof. unfold models_natural_numbers. split.
* bool * apply boolean_algebra_on_bool.
split.
* equiv * apply bequiv_bin.
split.
* least * intros n. unfold not. intros H. induction n as [| n' | n' ].
  * xH * inversion H.
  * xI n' * inversion H.
  * xO n' * inversion H.
split.
* beq_bin add next_bin *)



Inductive hex : Type :=
                    h1 : hex        | h2 : hex        | h3 : hex
| h4 : hex        | h5 : hex        | h6 : hex        | h7 : hex
| h8 : hex        | h9 : hex        | hA : hex        | hB : hex
| hC : hex        | hD : hex        | hE : hex        | hF : hex
| d0 : hex -> hex | d1 : hex -> hex | d2 : hex -> hex | d3 : hex -> hex
| d4 : hex -> hex | d5 : hex -> hex | d6 : hex -> hex | d7 : hex -> hex
| d8 : hex -> hex | d9 : hex -> hex | dA : hex -> hex | dB : hex -> hex
| dC : hex -> hex | dD : hex -> hex | dE : hex -> hex | dF : hex -> hex.

Fixpoint hex_bin (h : hex) : bin :=
match h with                            | h1   => xH
| h2   => xO  xH                        | h3   => xI  xH
| h4   => xO (xO  xH)                   | h5   => xI (xO  xH)
| h6   => xO (xI  xH)                   | h7   => xI (xI  xH)
| h8   => xO (xO (xO  xH))              | h9   => xI (xO (xO  xH))
| hA   => xO (xI (xO  xH))              | hB   => xI (xI (xO  xH))
| hC   => xO (xO (xI  xH))              | hD   => xI (xO (xI  xH))
| hE   => xO (xI (xI  xH))              | hF   => xI (xI (xI  xH))
| d0 b => xO (xO (xO (xO (hex_bin b)))) | d1 b => xI (xO (xO (xO (hex_bin b))))
| d2 b => xO (xI (xO (xO (hex_bin b)))) | d3 b => xI (xI (xO (xO (hex_bin b))))
| d4 b => xO (xO (xI (xO (hex_bin b)))) | d5 b => xI (xO (xI (xO (hex_bin b))))
| d6 b => xO (xI (xI (xO (hex_bin b)))) | d7 b => xI (xI (xI (xO (hex_bin b))))
| d8 b => xO (xO (xO (xI (hex_bin b)))) | d9 b => xI (xO (xO (xI (hex_bin b))))
| dA b => xO (xI (xO (xI (hex_bin b)))) | dB b => xI (xI (xO (xI (hex_bin b))))
| dC b => xO (xO (xI (xI (hex_bin b)))) | dD b => xI (xO (xI (xI (hex_bin b))))
| dE b => xO (xI (xI (xI (hex_bin b)))) | dF b => xI (xI (xI (xI (hex_bin b))))
end.

Fixpoint next_hex (h : hex) : hex :=
match h with      | h1 => h2        | h2 => h3        | h3 => h4
| h4 => h5        | h5 => h6        | h6 => h7        | h7 => h8
| h8 => h9        | h9 => hA        | hA => hB        | hB => hC
| hC => hD        | hD => hE        | hE => hF        | hF => d0 h1
| d0 h' => d1 h'  | d1 h' => d2 h'  | d2 h' => d3 h'  | d3 h' => d4 h'
| d4 h' => d5 h'  | d5 h' => d6 h'  | d6 h' => d7 h'  | d7 h' => d8 h'
| d8 h' => d9 h'  | d9 h' => dA h'  | dA h' => dB h'  | dB h' => dC h'
| dC h' => dD h'  | dD h' => dE h'  | dE h' => dF h'  | dF h' => d0 (next_hex h')
end.

Fixpoint beq_hex (u v : hex) : bool := beq_bin (hex_bin u) (hex_bin v).




(* My earlier criterion for two-element boolean algebra:
   whether it has the NAND truth table.
feq t (fand
  (fand
    (fnot (fand (fnot t) (fnot t)))  * nand t t -> f *
    (fnot (fand (fnot t) (fnot f)))  * nand t f -> f *
  )
  (fand
    (fnot (fand (fnot f) (fnot t)))  * nand f t -> f *
    (fand (fnot f) (fnot f))         * nand f f -> t *
  )
).
*)
