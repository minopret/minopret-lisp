(* (label and ( lambda (x y) (cond (x (cond (y t) (t ()))) (t ())) )) *)
Definition defun_and : list :=
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
                                        (cons   (symbol (d4 h7))  (* t *)
                                         nil) )
                                (cons   (cons   (symbol (d4 h7))
                                        (cons    nil
                                         nil) )
                                 nil) ) )
                         nil) )
                (cons   (cons   (symbol (d4 h7))
                        (cons    nil
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label append ( lambda (x y) (cond ((null x) y) (t (cons (car x) (append (cdr x) y))) ))) *)
Definition defun_append : list :=
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
                (cons   (cons   (symbol (d4 h7))
                        (cons   (cons    sym_cons
                                (cons   (cons    sym_car
                                        (cons   (symbol (d8 h7))
                                         nil) )
                                (cons   (cons sym_append
                                        (cons   (cons    sym_cdr
                                                (cons   (symbol (d8 h7))
                                                 nil) )
                                        (cons (symbol (d9 h7))
                                         nil) ) )
                                 nil) ) )
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label assoc ( lambda (x y) (cond ((eq x (caar y)) (cadar y)) (t (assoc x (cdr y)))) )) *)
Definition defun_assoc : list :=
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
                (cons   (cons   (symbol (d4 h7))
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
Definition defun_caar : list :=
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
Definition defun_cadar : list :=
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
Definition defun_caddr : list :=
(cons    sym_label
(cons    sym_caddr
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
Definition defun_caddr : list :=
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
Definition defun_cadr : list :=
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
Definition defun_evlis : list :=
(cons   sym_label
(cons   sym_evlis
(cons   (cons   sym_lambda
        (cons   (cons   (symbol (dd h6))  (* m *)
                (cons   (symbol (d1 h6))  (* a *)
                 nil) )
        (cons   (cons   sym_cond
                (cons   (cons   (cons   sym_null
                                (cons   (symbol (dd h6)) 
                                 nil) )
                        (cons    nil
                         nil) )
                (cons   (cons   (symbol (d4 h7))    (* t *)
                        (cons   (cons   sym_cons
                                (cons   (cons    sym_eval
                                        (cons   (cons    sym_car
                                                (cons   (symbol (dd h6)) 
                                                 nil) )
                                        (cons   (symbol (d1 h6))
                                         nil) ) )
                                (cons   (cons    sym_evlis
                                        (cons   (cons    sym_cdr
                                                (cons   (symbol (dd h6))
                                                 nil) )
                                        (cons   (symbol (d1 h6))
                                         nil) ) )
                                 nil) ) )
                         nil) )
                nil) ) )
        nil) ) )
nil) ) ).

Definition defun_evcon : list :=
(cons  sym_label   
(cons  sym_evcon   
(cons  sym_lambda   
(cons  (cons  (symbol (d3 h6))   
              (symbol (d1 h6))
       )
       (cons  sym_cond   (cons  (cons  (cons  sym_eval   (cons  (cons  sym_caar   (symbol (d3 h6)) )   (symbol (d1 h6)) ))   (cons  sym_eval   (cons  (cons  sym_cadar   (symbol (d3 h6)) )   (symbol (d1 h6)) )) )   (cons  (cons  sym_quote   (symbol (d4 h7)) )   (cons  sym_evcon   (cons  (cons  sym_cdr   (symbol (d3 h6)) )   (symbol (d1 h6)) )) ) )) )) )).

Definition defun_eval : list :=
(cons  sym_label   (cons  sym_eval   (cons  sym_lambda   (cons  (cons  (symbol (d5 h6))   (symbol (d1 h6)) )   (cons  sym_cond   (cons  (cons  (cons  sym_atom   (symbol (d5 h6)) )   (cons  sym_assoc   (cons  (symbol (d5 h6))   (symbol (d1 h6)) )) )   (cons  (cons  (cons  sym_atom   (cons  sym_car   (symbol (d5 h6)) ) )   (cons  sym_cond   (cons  (cons  (cons  sym_eq   (cons  (cons  sym_car   (symbol (d5 h6)) )   (cons  sym_quote   sym_quote ) ))   (cons  sym_cadr   (symbol (d5 h6)) ) )   (cons  (cons  (cons  sym_eq   (cons  (cons  sym_car   (symbol (d5 h6)) )   (cons  sym_quote   sym_atom ) ))   (cons  sym_atom   (cons  sym_eval   (cons  (cons  sym_cadr   (symbol (d5 h6)) )   (symbol (d1 h6)) )) ) )   (cons  (cons  (cons  sym_eq   (cons  (cons  sym_car   (symbol (d5 h6)) )   (cons  sym_quote   sym_eq ) ))   (cons  sym_eq   (cons  (cons  sym_eval   (cons  (cons  sym_cadr   (symbol (d5 h6)) )   (symbol (d1 h6)) ))   (cons  sym_eval   (cons  (cons  sym_caddr   (symbol (d5 h6)) )   (symbol (d1 h6)) )) )) )   (cons  (cons  (cons  sym_eq   (cons  (cons  sym_car   (symbol (d5 h6)) )   (cons  sym_quote   sym_car ) ))   (cons  sym_car   (cons  sym_eval   (cons  (cons  sym_cadr   (symbol (d5 h6)) )   (symbol (d1 h6)) )) ) )   (cons  (cons  (cons  sym_eq   (cons  (cons  sym_car   (symbol (d5 h6)) )   (cons  sym_quote   sym_cdr ) ))   (cons  sym_cdr   (cons  sym_eval   (cons  (cons  sym_cadr   (symbol (d5 h6)) )   (symbol (d1 h6)) )) ) )   (cons  (cons  (cons  sym_eq   (cons  (cons  sym_car   (symbol (d5 h6)) )   (cons  sym_quote   sym_cons ) ))   (cons  sym_cons   (cons  (cons  sym_eval   (cons  (cons  sym_cadr   (symbol (d5 h6)) )   (symbol (d1 h6)) ))   (cons  sym_eval   (cons  (cons  sym_caddr   (symbol (d5 h6)) )   (symbol (d1 h6)) )) )) )   (cons  (cons  (cons  sym_eq   (cons  (cons  sym_car   (symbol (d5 h6)) )   (cons  sym_quote   sym_cond ) ))   (cons  sym_evcon   (cons  (cons  sym_cdr   (symbol (d5 h6)) )   (symbol (d1 h6)) )) )   (cons  (cons  sym_quote   (symbol (d4 h7)) )   (cons  sym_eval   (cons  (cons  sym_cons   (cons  (cons  sym_assoc   (cons  (cons  sym_car   (symbol (d5 h6)) )   (symbol (d1 h6)) ))   (cons  sym_cdr   (symbol (d5 h6)) ) ))   (symbol (d1 h6)) )) ) )))))))) )   (cons  (cons  (cons  sym_eq   (cons  (cons  sym_caar   (symbol (d5 h6)) )   (cons  sym_quote   sym_lambda ) ))   (cons  sym_eval   (cons  (cons  sym_caddar   (symbol (d5 h6)) )   (cons  sym_append   (cons  (cons  sym_pair   (cons  (cons  sym_cadar   (symbol (d5 h6)) )   (cons  sym_evlis   (cons  (cons  sym_cdr   (symbol (d5 h6)) )   (symbol (d1 h6)) )) ))   (symbol (d1 h6)) )) )) )   (cons  (cons  sym_eq   (cons  (cons  sym_caar   (symbol (d5 h6)) )   (cons  sym_quote   sym_label ) ))   (cons  sym_eval   (cons  (cons  sym_cons   (cons  (cons  sym_caddar   (symbol (d5 h6)) )   (cons  sym_cdr   (symbol (d5 h6)) ) ))   (cons  sym_cons   (cons  (cons  sym_list   (cons  (cons  sym_cadar   (symbol (d5 h6)) )   (cons  sym_car   (symbol (d5 h6)) ) ))   (symbol (d1 h6)) )) )) ) )))) )) )).

(* (label list ( lambda (x y) (cons x (cons y ())) )) *)
Definition defun_list : list :=
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
Definition defun_not : list :=
(cons    sym_label
(cons    sym_not
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                 nil)
        (cons   (cons    sym_cond
                (cons   (cons   (symbol (d8 h7))
                        (cons    nil
                         nil))
                (cons   (cons   (symbol (d4 h7))
                        (cons   (symbol (d4 h7))
                         nil) )
                 nil) ) )
         nil) ) )
 nil) ) ).

(* (label null ( lambda (x) (eq x ()) )) *)
Definition defun_null : list :=
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
Definition defun_pair : list :=
(cons    sym_label
(cons    sym_pair
(cons   (cons    sym_lambda
        (cons   (cons   (symbol (d8 h7))
                (cons   (symbol (d9 h7))
                 nil) )
        (cons   (cons    sym_cond
                (cons   (cons  (cons  sym_and   (cons  (cons  sym_null   (symbol (d8 h7)) )   (cons  sym_null   (symbol (d9 h7)) ) ))   (cons  sym_quote   nil  ) )   (cons  (cons  sym_and   (cons  (cons  sym_not   (cons  sym_atom   (symbol (d8 h7)) ) )   (cons  sym_not   (cons  sym_atom   (symbol (d9 h7)) ) ) ))

(cons    sym_cons   
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
