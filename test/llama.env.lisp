(eenv0 '(
    (ttrue  (llama x (llama y x)))
    (ffalse (llama x (llama y y)))
    (iif    (llama x (llama y (llama z ((x y) z)))))
    (aand   (llama x (llama y ((x y) ffalse))))
    (oor    (llama x (llama y ((x ttrue) y))))
    (nnot   (llama x          ((x ffalse) ttrue)))
    (iiff   (llama x (llama y ((x y) (nnot y)))))
    (ddemorgan
            (llama x (llama y (
                (iiff (nnot ((aand x) y)))
                ((oor (nnot x)) (nnot y)) ))) ) ))
