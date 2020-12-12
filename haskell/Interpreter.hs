module Interpreter where
import Control.Exception
import Debug.Trace
import Data.List


-- Problem 1
--
-- interpret(x)     = x
-- interpret(\x.E1) = \x.interpret(E1)
-- interpret(E1 E2) = let f = interpret(E1)
--                        a = interpret(E2)
--                    in case f of
--                       \x.E3 -> interpret(E3[a/x])
--                           - -> f a
--


---- Data Types ----

data Expr =
  Var Name            --- a variable
  | App Expr Expr     --- function application
  | Lambda Name Expr  --- lambda abstraction
  deriving
    (Eq,Show)         --- the Expr data type derives from built-in Eq and Show classes,
                      --- thus, we can compare and print expressions

type Name = String    --- a variable name


---- Functions ----

-- Purpose: To take two lists of Names and combine them without duplicates
-- For example, combine ["a","b"] ["a"] should produce ["a","b"]
combine :: [Name] -> [Name] -> [Name]
combine x y = nub(x ++ y)


-- Purpose: take expression expr and return the list of variables that are free in expr without repetition
-- For example, freeVars (App (Var "a") (Var "a")) should produce ["a"]
freeVars :: Expr -> [Name]
freeVars (Var var_name) = [var_name]
freeVars (App expr_one expr_two) = (combine (freeVars expr_one) (freeVars expr_two))
freeVars (Lambda var_name expr) = (freeVars expr) \\ [var_name]


-- Purpose: take a list of expressions and generate an (infinite) list of variables that are not free in any of the expressions in the list
-- For example, freshVars [Lambda "1_" (App (Var "a") (App (Var "1_") (Var "2_")))] should produce [1_,3_,4_,5_,..]
freshVars :: [Expr] -> [Name]
freshVars expr =
  let infinite_list = (map (\x -> (show x) ++ "_") [1..]) in
      (filter (\x -> (notElem x (foldr ((++) . freeVars) [] expr))) infinite_list)


-- Purpose: take a variable x and an expression e, and return a function that takes an expression E and returns E[e/x]
-- For example, subst ("a", (Lambda "b" (Var "b"))) (App (Var "a") (Var "c")) should produce App (Lambda "b" (Var "b")) (Var c)
subst :: (Name,Expr) -> Expr -> Expr

subst (name_one,expr_one) (Var x) =
  if name_one == x then expr_one else (Var x)

subst (name_one,expr_one) (App expr_two expr_three) =
  App (subst (name_one,expr_one) expr_two) (subst (name_one,expr_one) expr_three)

subst (name_one,expr_one) (Lambda name_two expr_two) =
  if name_one == name_two then (Lambda name_two expr_two)
  else let fresh_var = (head (freshVars [expr_one, expr_two, (Var name_one)])) in
      (Lambda fresh_var (subst (name_one, expr_one) (subst (name_two, (Var fresh_var)) expr_two)))


-- Purpose: take expression e, if there is redex available in e, pick the correct applicative order redex and reduce e.
-- For example, appNF_OneStep (App (Lambda "a" (Var "a")) (Var "c")) should produce Just (Var "c")
appNF_OneStep :: Expr -> Maybe Expr
appNF_OneStep expr_list = case expr_list of
  (Var a) -> Nothing

  (Lambda var_name expr) -> case appNF_OneStep expr of
        Nothing -> Nothing
        Just x -> Just (Lambda var_name x)

  (App expr_one expr_two) ->
    case (appNF_OneStep expr_one, appNF_OneStep expr_two) of
      (Just x, Just y)   -> Just (App x expr_two)
      (Just x, Nothing)  -> Just (App x expr_two)
      (Nothing, Just y)  -> Just (App expr_one y)
      (Nothing, Nothing) -> case expr_one of
                              (Var a)      -> Nothing
                              (App a b)    -> Nothing
                              (Lambda a b) -> Just (subst (a, expr_two) b)


-- Purpose: Given integer n and expression e, do n reductions (or as many as possible) and return the resulting expression.
-- For example, appNF_n 2 (App (Lambda "a" (Lambda "b" (Var "c"))) (Lambda "d" (App (Lambda "b" (Var "d")) (Lambda "a" (Var "c"))))) should produce Lambda "1_" (Var "c")
appNF_n :: Int -> Expr -> Expr
appNF_n redux_count expr =
  if redux_count < 0 then (error "Invalid number of reductions!")
  else if redux_count == 0 then expr
  else case appNF_OneStep expr of
    Nothing -> expr
    Just x -> (appNF_n (redux_count - 1) x)
