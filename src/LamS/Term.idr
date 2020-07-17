module ES.LamS.Term

import STLC.Ty

%default total

mutual
  data Term : List Ty -> Ty -> Type where
    Var : Elem a g -> Term g a
    Lam : Term (a::g) b -> Term g (a~>b)
    App : Term g (a~>b) -> Term g a -> Term g b
    Sub : Elem
