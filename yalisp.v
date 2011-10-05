Require Export list.

(* (label and ( lambda (x y) (cond (x (cond (y t) (t ()))) (t ())) )) *)
Definition defun_and : expr :=
(cons   sym_label
(cons   sym_and
(cons   (cons   sym_lambda
        (cons   (cons   (symbol (d8 h7))  (* x *)
                (cons   (symbol (d9 h7))  (* y *)
                 nil) )
        (cons   (cons   sym_cond   
                (cons   (cons   (symbol (d8 h7))
                        (cons   (cons    sym_cond
                                (cons   (cons   (symbol (d9 h7))
                                        (cons    sym_t
                                         nil) )
                                (cons   (cons    sym_t
                                        (cons    nil
                                         nil) )
                                 nil) ) )
                         nil) )
                (cons   (cons    sym_t
                        (cons    nil
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label append ( lambda (x y) (cond ((null x) y) (t (cons (car x) (append (cdr x) y))) ))) *)
Definition defun_append : expr :=
(cons    sym_label
(cons    sym_append
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                (cons   (symbol (d9 h7))
                 nil) )
        (cons   (cons    sym_cond
                (cons   (cons   (cons    sym_null
                                (cons   (symbol (d8 h7))
                                 nil) )
                        (cons   (symbol (d9 h7))
                         nil) )
                (cons   (cons    sym_t
                        (cons   (cons    sym_cons
                                (cons   (cons    sym_car
                                        (cons   (symbol (d8 h7))
                                         nil) )
                                (cons   (cons sym_append
                                        (cons   (cons    sym_cdr
                                                (cons   (symbol (d8 h7))
                                                 nil) )
                                        (cons 	(symbol (d9 h7))
                                         nil) ) )
                                 nil) ) )
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label assoc ( lambda (x y) (cond ((eq x (caar y)) (cadar y)) (t (assoc x (cdr y)))) )) *)
Definition defun_assoc : expr :=
(cons    sym_label
(cons    sym_assoc
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                (cons   (symbol (d9 h7))
                 nil) )
        (cons   (cons    sym_cond
                (cons   (cons   (cons    sym_eq
                                (cons   (symbol (d8 h7))
                                (cons   (cons    sym_caar
                                        (cons   (symbol (d9 h7))
                                         nil) )
                                 nil) ) )
                        (cons   (cons    sym_cadar
                                (cons   (symbol (d9 h7))
                                 nil) )
                         nil) )
                (cons   (cons    sym_t
                        (cons   (cons    sym_assoc
                                (cons   (symbol (d8 h7))
                                (cons   (cons    sym_cdr
                                        (cons   (symbol (d9 h7))
                                         nil) )
                                 nil) ) )
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label caar ( lambda (x) (car (car x)) )) *)
Definition defun_caar : expr :=
(cons    sym_label
(cons    sym_caar
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                 nil)
        (cons   (cons    sym_car
                (cons   (cons    sym_car
                        (cons   (symbol (d8 h7))
                         nil) )
                 nil) )
         nil) ) )
 nil) ) ).

(* (label cadar ( lambda (x) (car (cdr (car x))) )) *)
Definition defun_cadar : expr :=
(cons    sym_label
(cons    sym_cadar
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                 nil)
        (cons   (cons    sym_car
                (cons   (cons    sym_cdr
                        (cons   (cons    sym_car
                                (cons   (symbol (d8 h7))
                                nil) )
                         nil) )
                 nil) )
         nil) ) )
 nil) ) ).
 
(* (label caddar ( lambda (x) (car (cdr (cdr (car x)))) )) *)
Definition defun_caddar : expr :=
(cons    sym_label
(cons    sym_caddar
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                 nil)
        (cons   (cons    sym_car
                (cons   (cons    sym_cdr
                        (cons   (cons    sym_cdr
                                (cons   (cons    sym_car
                                        (cons   (symbol (d8 h7))
                                        nil) )
                                 nil) )
                         nil) )
                 nil) )
         nil) ) )
 nil) ) ).

(* (label caddr ( lambda (x) (car (cdr (cdr x))) )) *)
Definition defun_caddr : expr :=
(cons    sym_label
(cons    sym_caddr
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                 nil)
        (cons   (cons    sym_car
                (cons   (cons    sym_cdr
                        (cons   (cons    sym_cdr
                                (cons   (symbol (d8 h7))
                                 nil) )
                         nil) )
                 nil) )
         nil) ) )
 nil) ) ).

(* (label cadr ( lambda (x) (car (cdr x)) )) *)
Definition defun_cadr : expr :=
(cons    sym_label
(cons    sym_cadr
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                 nil)
        (cons   (cons    sym_car
                (cons   (cons    sym_cdr
                        (cons   (symbol (d8 h7))
                         nil) )
                 nil) )
         nil) ) )
 nil) ) ).

(* (label evlis (lambda (m a) (cond ((null m) ()) (t (cons (eval (car m) a) (evlis (cdr m) a)))))) *)
Definition defun_evlis : expr :=
(cons   sym_label
(cons   sym_evlis
(cons   (cons   sym_lambda
        (cons   (cons   (symbol (dD h6))  (* m *)
                (cons   (symbol (d1 h6))  (* a *)
                 nil) )
        (cons   (cons   sym_cond
                (cons   (cons   (cons   sym_null
                                (cons   (symbol (dD h6)) 
                                 nil) )
                        (cons    nil
                         nil) )
                (cons   (cons    sym_t
                        (cons   (cons   sym_cons
                                (cons   (cons    sym_eval
                                        (cons   (cons    sym_car
                                                (cons   (symbol (dD h6)) 
                                                 nil) )
                                        (cons   (symbol (d1 h6))
                                         nil) ) )
                                (cons   (cons    sym_evlis
                                        (cons   (cons    sym_cdr
                                                (cons   (symbol (dD h6))
                                                 nil) )
                                        (cons   (symbol (d1 h6))
                                         nil) ) )
                                 nil) ) )
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label evcon (lambda (c a) (cond
        ((eval (caar c) a) (eval (cadar c) a))
        ( t                (evcon (cdr c) a))
 *)
Definition defun_evcon : expr :=
(cons    sym_label   
(cons    sym_evcon   
(cons   (cons    sym_lambda   
        (cons   (cons   (symbol (d3 h6))    (* c *)
                (cons   (symbol (d1 h6))    (* a *)
                 nil) )
        (cons   (cons    sym_cond
                (cons   (cons   (cons    sym_eval
                                (cons   (cons    sym_caar   
                                        (cons   (symbol (d3 h6))
                                         nil) )
                                (cons   (symbol (d1 h6))
                                 nil) ) )
                        (cons   (cons    sym_eval
                                (cons   (cons    sym_cadar
                                        (cons   (symbol (d3 h6))
                                         nil) )
                                (cons   (symbol (d1 h6))
                                 nil) ) )
                         nil) )
                (cons   (cons    sym_t
                        (cons   (cons    sym_evcon
                                (cons   (cons    sym_cdr
                                        (cons   (symbol (d3 h6))
                                         nil) )
                                (cons   (symbol (d1 h6))
                                 nil) ) )
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label eval (lambda (m a) (cond 
    ((atom m) (assoc m a))
    ((atom (car m)) (cond
        ((eq (car m) (quote quote)) (cadr m))
        ((eq (car m) (quote atom)) (atom (eval (cadr m) a)))
        ((eq (car m) (quote eq)) (eq (eval (cadr m) a) (eval (caddr m) a)))
        ((eq (car m) (quote car)) (car (eval (cadr m) a)))
        ((eq (car m) (quote cdr)) (cdr (eval (cadr m) a)))
        ((eq (car m) (quote cons)) (cons (eval (cadr m) a) (eval (caddr m) a)))
        ((eq (car m) (quote cond)) (evcon (cdr m) a))
        ( t                       (eval (cons (assoc (car m) a) (cdr m)) a))
    ...
 *)
Definition defun_eval : expr :=
(cons    sym_label
(cons    sym_eval
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d5 h6))    (* m *)
                (cons   (symbol (d1 h6))    (* a *)
                 nil) )
        (cons   (cons    sym_cond
                (cons   (cons   (cons    sym_atom
                                (cons   (symbol (d5 h6))
                                 nil) )
                        (cons   (cons    sym_assoc   
                                (cons   (symbol (d5 h6))   
                                (cons   (symbol (d1 h6))
                                 nil) ) )
                         nil) )
                (cons   (cons   (cons    sym_atom
                                (cons   (cons    sym_car   
                                        (cons   (symbol (d5 h6))
                                         nil) )
                                 nil) )
                        (cons   (cons    sym_cond
                                (cons   (cons   (cons    sym_eq   
                                                (cons   (cons    sym_car   
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                (cons   (cons    sym_quote
                                                        (cons    sym_quote
                                                         nil) )
                                                 nil) ) )
                                        (cons   (cons    sym_cadr   
                                                (cons   (symbol (d5 h6))
                                                 nil) )
                                         nil) )
                                (cons   (cons   (cons    sym_eq
                                                (cons   (cons    sym_car
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                (cons   (cons    sym_quote
                                                        (cons    sym_atom
                                                         nil) )
                                                 nil) ) )
                                        (cons   (cons    sym_atom
                                                (cons   (cons    sym_eval
                                                        (cons   (cons    sym_cadr
                                                                (cons   (symbol (d5 h6))
                                                                 nil) )
                                                        (cons   (symbol (d1 h6))
                                                         nil) ) )
                                                 nil) )
                                         nil) )
                                (cons   (cons   (cons    sym_eq
                                                (cons   (cons    sym_car
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                (cons   (cons    sym_quote
                                                        (cons    sym_eq
                                                         nil) )
                                                 nil) ) )
                                        (cons   (cons    sym_eq
                                                (cons   (cons    sym_eval
                                                        (cons   (cons    sym_cadr
                                                                (cons   (symbol (d5 h6))
                                                                 nil) )
                                                        (cons   (symbol (d1 h6))
                                                         nil) ) )
                                                (cons   (cons    sym_eval
                                                        (cons   (cons    sym_caddr   
                                                                (cons   (symbol (d5 h6))
                                                                 nil) )
                                                        (cons   (symbol (d1 h6))
                                                         nil) ) )
                                                 nil) ) )
                                         nil) )
                                (cons   (cons   (cons    sym_eq
                                                (cons   (cons    sym_car   
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                (cons   (cons    sym_quote
                                                        (cons    sym_car
                                                         nil) )
                                                 nil) ) )
                                        (cons   (cons    sym_car
                                                (cons   (cons    sym_eval
                                                        (cons   (cons    sym_cadr
                                                                (cons   (symbol (d5 h6))
                                                                 nil) )
                                                        (cons   (symbol (d1 h6))
                                                         nil) ) )
                                                 nil) )
                                         nil) )
                                (cons   (cons   (cons    sym_eq   
                                                (cons   (cons    sym_car   
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                (cons   (cons    sym_quote
                                                        (cons    sym_cdr
                                                         nil) )
                                                 nil) ) )
                                        (cons   (cons    sym_cdr   
                                                (cons   (cons    sym_eval   
                                                        (cons   (cons    sym_cadr   
                                                                (cons   (symbol (d5 h6))
                                                                 nil) ) 
                                                        (cons   (symbol (d1 h6))
                                                         nil) ) )
                                                 nil) )
                                         nil) )
                                (cons   (cons   (cons    sym_eq   
                                                (cons   (cons    sym_car   
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                (cons   (cons    sym_quote   
                                                        (cons    sym_cons
                                                         nil) )
                                                 nil) ) )
                                        (cons   (cons    sym_cons   
                                                (cons   (cons    sym_eval   
                                                        (cons   (cons    sym_cadr   
                                                                (cons   (symbol (d5 h6))
                                                                 nil) )
                                                        (cons   (symbol (d1 h6))
                                                         nil) ) )
                                                (cons   (cons    sym_eval   
                                                        (cons   (cons    sym_caddr   
                                                                (cons   (symbol (d5 h6))
                                                                 nil) )
                                                        (cons   (symbol (d1 h6))
                                                         nil) ) )
                                                 nil) ) )
                                         nil) )
                                (cons   (cons   (cons    sym_eq   
                                                (cons   (cons    sym_car   
                                                        (cons   (symbol (d5 h6)) 
                                                         nil) )
                                                (cons   (cons    sym_quote   
                                                        (cons    sym_cond 
                                                         nil) )
                                                 nil) ) )
                                        (cons   (cons    sym_evcon   
                                                (cons   (cons    sym_cdr   
                                                        (cons   (symbol (d5 h6)) 
                                                         nil) )
                                                (cons   (symbol (d1 h6)) 
                                                 nil) ) )
                                         nil) )
                                (cons   (cons   (cons    sym_quote   
                                                (cons    sym_t 
                                                 nil) )
                                        (cons   (cons    sym_eval   
                                                (cons   (cons    sym_cons   
                                                        (cons   (cons    sym_assoc   
                                                                (cons   (cons    sym_car   
                                                                        (cons   (symbol (d5 h6))
                                                                         nil) )
                                                                (cons   (symbol (d1 h6))
                                                                 nil) ) )
                                                        (cons   (cons    sym_cdr
                                                                (cons   (symbol (d5 h6))
                                                                 nil) )
                                                         nil) ) )
                                                (cons   (symbol (d1 h6))
                                                 nil) ) )
                                         nil) )
                                 nil) ) ) ) ) ) ) ) )
                         nil) )
                (cons   (cons   (cons    sym_eq
                                (cons   (cons    sym_caar
                                        (cons   (symbol (d5 h6))
                                         nil) )
                                (cons   (cons    sym_quote
                                        (cons    sym_lambda
                                         nil) )
                                 nil) ) )
                        (cons   (cons    sym_eval   
                                (cons   (cons    sym_caddar   
                                        (cons   (symbol (d5 h6))
                                         nil) )
                                (cons   (cons    sym_append
                                        (cons   (cons    sym_pair   
                                                (cons   (cons    sym_cadar
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                (cons   (cons    sym_evlis
                                                        (cons   (cons    sym_cdr
                                                                (cons   (symbol (d5 h6))
                                                                 nil) )
                                                        (cons   (symbol (d1 h6))
                                                         nil) ) )
                                                 nil) ) )
                                        (cons   (symbol (d1 h6))
                                         nil) ) )
                                  nil) ) )
                         nil) )
                (cons   (cons   (cons    sym_eq   
                                (cons   (cons    sym_caar   
                                        (cons   (symbol (d5 h6))
                                         nil) )
                                (cons   (cons    sym_quote   
                                        (cons    sym_label
                                         nil) )
                                 nil) ) )
                        (cons   (cons    sym_eval   
                                (cons   (cons    sym_cons   
                                        (cons   (cons    sym_caddar   
                                                (cons   (symbol (d5 h6))
                                                 nil) )
                                        (cons   (cons    sym_cdr   
                                                (cons   (symbol (d5 h6))
                                                 nil) )
                                         nil) ) )
                                (cons   (cons    sym_cons   
                                        (cons   (cons    sym_list   
                                                (cons   (cons    sym_cadar   
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                (cons   (cons    sym_car   
                                                        (cons   (symbol (d5 h6))
                                                         nil) )
                                                 nil) ) )
                                        (cons   (symbol (d1 h6))
                                         nil) ) )
                                 nil) ) )
                         nil) )
                 nil) ) ) ) )
         nil) ) )
 nil) ) ).

(* (label list ( lambda (x y) (cons x (cons y ())) )) *)
Definition defun_list : expr :=
(cons    sym_label
(cons    sym_list
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                (cons   (symbol (d9 h7))
                 nil) )
        (cons   (cons    sym_cons
                (cons   (symbol (d8 h7))
                (cons   (cons    sym_cons
                        (cons   (symbol (d9 h7))
                        (cons    nil
                         nil) ) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label not ( lambda (x) (cond (x ()) (t t)) )) *)
Definition defun_not : expr :=
(cons    sym_label
(cons    sym_not
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                 nil)
        (cons   (cons    sym_cond
                (cons   (cons   (symbol (d8 h7))
                        (cons    nil
                         nil))
                (cons   (cons    sym_t
                        (cons    sym_t
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label null ( lambda (x) (eq x ()) )) *)
Definition defun_null : expr :=
(cons    sym_label
(cons    sym_null
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                 nil)
        (cons   (cons    sym_eq
                (cons   (symbol (d8 h7))
                (cons   (cons    sym_quote
                        (cons    nil
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(*
(label pair ( lambda (x y) (cond ((null (cdr x)) (list (car x) (car y)))
                                 (    t    (cons (list (car x) (car y)) (pair (cdr x) (cdr y)))) )))
*)
Definition defun_pair : expr :=
(cons    sym_label
(cons    sym_pair
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                (cons   (symbol (d9 h7))
                 nil) )
        (cons   (cons    sym_cond
                (cons   (cons   (cons    sym_and
                                (cons   (cons    sym_null
                                        (cons   (symbol (d8 h7))
                                         nil) )
                                (cons   (cons    sym_null   
                                        (cons   (symbol (d9 h7))
                                         nil) )
                                 nil) ) )
                        (cons    nil
                         nil) )
                (cons   (cons   (cons    sym_and
                                (cons   (cons    sym_not
                                        (cons   (cons    sym_atom   
                                                (cons   (symbol (d8 h7))
                                                 nil) )
                                         nil) )
                                (cons   (cons    sym_not
                                        (cons   (cons    sym_atom
                                                (cons   (symbol (d9 h7))
                                                 nil) )
                                         nil) )
                                 nil) ) )
                        (cons   (cons    sym_cons   
                                (cons   (cons    sym_list
                                        (cons   (cons    sym_car
                                                (cons   (symbol (d8 h7))
                                                 nil) )
                                        (cons   (cons    sym_car
                                                (cons   (symbol (d9 h7))
                                                 nil) )
                                         nil) ) )
                                (cons   (cons    sym_pair 
                                        (cons   (cons    sym_cdr
                                                (cons   (symbol (d8 h7))
                                                 nil) )
                                        (cons   (cons    sym_cdr
                                                (cons   (symbol (d9 h7))
                                                 nil) )
                                         nil) ) )
                                 nil) ) )
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).
