# Functional-Programming
My journey in functional programming (Haskell, Scheme) plus a surprise visit from the logical programming language, Prolog.

## Haskell 

Inside the /Haskell subdirectory you'll find an applicative order interpreter, taking in an expression and reducing it to normal form in applicative order. See below for an example using the ```appNF_OneStep``` to reduce.

```appNF_OneStep (App (Lambda "a" (Var "a")) (Var "c"))``` should produce ```Just (Var "c")```

## Prolog

Inside the /Prolog subdirectory you'll find two applications. The first one, ```foxes_and_hens.pl``` will solve the classic foxes and hens program in which a farmer tries to get foxes and hens across a river without the foxes eating the hens. To run this application simply run the following: 

```swipl -l foxes_and_hens.pl``` then search for the solution with ```solve(X).```

Next you will find a second application called ```parser.pl```. This application computes an arithmetic result using an LL(1) parser for the grammar below. 

```
srart → expr
expr → term term_tail
term_tail → - term term_tail
term_tail → ε
term → num factor_tail
factor_tail → * num factor_tail
factor_tail → ε
```

To run the application first load it ```swipl -l parser.pl``` then search for then type in your arithmetic expression and solve ```transform([3,-,5],R),parseAndSolve(R,ProdSeq,V).``` should produce
```
% ProdSeq = [0, 1, 4, 6, 2, 4, 6, 3],
% V = -2.
```

## Scheme

