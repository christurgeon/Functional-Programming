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
where ProdSeq is the sequence of productions applied to get the result and V is the actual result.

## Scheme

Lastly, in the Scheme subdirectory you'll find another two applications. The first is ```lis.rakt``` which computes the longest increasing subsequence using a polynomial and brute force solution. This was developed in R5RS legacy scheme in the DrRacket environment. See below on how to run. Simply replace ```lis_fast``` with ```list_slow``` to switch between algorithms.

 ```(lis_fast `(1 2 3 3 5 4 9))``` should produce ```(1 2 3 3 5 9)```
 
 Secondly, we have ```yabi.rakt``` which interprets then evaluates boolean expressions. In order to run, you must build a list of boolean expressions and pass them in as list of lists to ```myinterpreter``` which will evaluate each and return a list wherein each element is the boolean result of the evaluated expression at that index within the input list. See below for an example.
 
```(myinterpreter ((prog (myor false false)) (prog (myand true false))))``` should produce ```(#f #f)```

