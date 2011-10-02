; minopret lisp 0.3:
;
; Aaron Mansheim 2011-07-15
;
; This is in the form of an association list to
; be passed to the second parameter of eval.
;
; 1960 McCarthy lisp from my memory of Paul Graham's
; Common Lisp version and my previous attempts in Python.
; I have been careful to avoid error conditions
; without adding any function or special form for
; that purpose.
;
; It is my intention that only a top-level application
; of car, cadr, caddr, cadar, or caddar to an atom
; will cause the interpreter to fail.
;
; In this implementation 'assoc' is a special form,
; not a proper function.
;
; I have also avoided the apostrophe
; abbreviation because I want to parse this easily.

; What all of this is:
;
; list delimiters: parentheses. Welcome to Lisp!
;
; function application:
;     The first list element is applied to the rest.
;
; primitive functions: atom car cdr cond cons eq quote
;
; special forms (functions defined only by their 
;     interpretation in "eval"): label lambda
;
; convenience notations:   ' quote    ; comment
;     Actually I am not using the apostrophe for quote.
;
; extra meanings:         () false    t true

(quote (

; accessors. These stop the interpreter if no such element exists!
; Some day I may add a No Result condition, but for now I'll be careful.
(caar (lambda (x) (car (car x))))                 ; first of first
(cadar (lambda (x) (car (cdr (car x)))))          ; second of first
(caddar (lambda (x) (car (cdr (cdr (car x))))))   ; third of first
(cadr (lambda (x) (car (cdr x))))                 ; second
(caddr (lambda (x) (car (cdr (cdr x)))))          ; third

; Is the argument an empty list?
(null (lambda (x) (eq x (quote ()))))

; The 'cond' built-in only tests whether the condition is the truth symbol t,
; then returns the unevaluated result. Here 'lambda' causes the evaluations.
; So 'evcon' gives a higher interpretation of a 'cond'. It returns the
; evaluated second member of the first pair whose first member evaluates true.
(evcon (lambda (x a) (cond (  ; x is list of condition-result pairs
    ((atom x) (quote ()))           ; if null or symbol, return empty result.
    ((atom (car x)) (quote ()))     ; if not a condition-result list, empty.
    ((eval (car (car x)) a) (cond (      ; if first of pair is true, return:
        ((eq (cdr x) (quote ())) (quote ())) ;   if no result given, return empty;
        ((quote t) (eval (car (cdr x)) a)) ; otherwise return result normally;
    ((quote t) (evcon (cdr x)))     ; else discard pair and examine the next.
))))

; evaluate each member of a list
(evlis (lambda (x a) (cond (
    ((atom x) (quote ()))           ; if null or symbol, return empty result.
    ((quote t) cons (eval (car x) a) (evlis (cdr x) a))
))))

; short-circuit evaluation of logical conjunction
(and (lambda (x y) (cond (
    (x (cond (
        (y (quote t))
        ((quote t) (quote ()))
    )))
    ((quote t) (quote ()))
))))

; logical negation
(not (lambda (x) (cond (
    (x (quote ()))
    ((quote t) (quote t))
))))

; form a list that has two given items as its elements
(list (lambda (x y) (
    cons x (cons y (quote ()))
)))

; form a list of corresponding elements from two lists
(pair (lambda (x y) (cond (
    (
        (and (not (atom x)) (not (atom y)))
        (cons (list (car x) (car y)) (pair (cdr x) (cdr y)))
    )
    ((quote t) (quote ()))  ; make a silly request, get a silly response
))))

; run two lists together
(append (lambda (x y) (cond (
    ((atom x) y)  ; null case; also, make a silly request...
    ((quote t) (cons (car x) (append (cdr x) y)))
))))

; This is only here for your reference - yes, YOU.
; Return the second of the first pair whose first matches.
; This uses only itself and primitives in hopes that
; we won't get an infinite loop of lookups;
; the lambda definition is inline in 'eval' for the
; same reason.
(assoc (lambda (e a) (cond (
    ((eq a (quote ())) (quote ()))  ; ran out of pairs?
    (eq e (car (car a))) (car (cdr (car a))))
    ((quote t) (assoc e (cdr a)))
))))

(eval (lambda (m a) (cond (
    ((eq m (quote ())) (quote ()))  ; Empty list evaluates to itself.
    ((atom m) (cond (
        ; The built-ins aren't in the lookup table.
        ; I'll decline to fib by giving a plausible expression for them.
        ((eq m (quote assoc)) (quote ()))

        ; But in general, atoms do evaluate to their bindings in 'a'.
        ((quote t) (assoc m a))  
    )))
    ((atom (car m)) (cond (  ; apply a built-in or other named function
        (   
            ; We have inlined the lookup function
            ; so that we can store the others in the table.
            (eq (car m) (quote assoc))
            (cond (
                ((eq (car (cdr (cdr m))) (quote ())) (quote ()))
                (
                    (eq (car (cdr m)) (car (car (car (cdr (cdr m))))))
                    (car (cdr (car (car (cdr (cdr m))))))
                )
                ((quote t) (assoc (cadr m) (cdr (car (cdr (cdr m))))))
            ))
        )

        ; Built-ins.
        ; Note the applications of built-ins use
        ; cadr and caddr without checking whether
        ; those elements exist. If desired,
        ; avoid that particular circularity by
        ; building the check into the interpreter.
        ((eq (car m) (quote atom))  (atom (eval (cadr x) a)))
        ((eq (car m) (quote car))   (car (eval (cadr x) a)))
        ((eq (car m) (quote cdr))   (cdr (eval (cadr m) a)))
        ((eq (car m) (quote cond))  (evcon (cdr m) a))
        ((eq (car m) (quote cons))  (cons (eval (cadr m) a) (eval (caddr m) a)))
        ((eq (car m) (quote eq))    (eq (eval (cadr m) a) (eval (caddr m) a)))
        ((eq (car m) (quote quote)) (quote (cadr m)))

        ; But in general, we do look up car atoms in 'a'.
        ((quote t) (assoc m a))
    )))
    ((null (car m)) (quote ()))  ; a list of the empty list evaluates to it
    ((atom (car m)) (cond (      ; apply a function by name
        (     ; apply a function by name
            (quote t)
            ... (assoc (m) a) ... 
        )
    )))
    ((null (caar m)) (quote ())) ; a list of list of empty evaluates to it
    ((atom (caar m)) (cond (     ; a list of list beginning 'lambda' is special
        (
            (eq (caar m) (quote label))    ; special form 'label'
        ... (eval (cons (caddr m) (cdr m)) (cons (list (cadr m) (caddr m)) a))
        )
        (
            (eq m (quote lambda))
            ( ... )
        )
        ((quote t) (assoc (m) a))
    )))
    (
        't
        ...
    ) ; apply a function
))))

)
