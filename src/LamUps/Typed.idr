module LamUps.Typed

import STLC.Ty
import Data.List

%default total

mutual
  public export
  data Term : List Ty -> Ty -> Type where
    Lam  : Term (a::g) b -> Term g (a~>b)
    Var  : Elem a g -> Term g a
    App  : Term g (a~>b) -> Term g a -> Term g b
    Clos : Term g a -> Subs d g -> Term d a

  public export
  data Subs : List Ty -> List Ty -> Type where
    Lift  : Subs g d -> Subs (a::g) (a::d)
    Slash : Term g a -> Subs g (a::g)
    Shift : Subs (a::g) g

data Redex : Term g a -> Term g a -> Type where
  Beta     : Redex (App  (Lam a)           b       ) (Clos a (Slash b))
  AppR     : Redex (Clos (App a b)         s       ) (App (Clos a s) (Clos b s))
  Lambda   : Redex (Clos (Lam a)           s       ) (Lam (Clos a (Lift s)))
  FVar     : Redex (Clos (Var Here)       (Slash a))  a
  RVar     : Redex (Clos (Var (There el)) (Slash a)) (Var el)
  FVarLift : Redex (Clos (Var Here)       (Lift s) ) (Var Here)
  RVarLift : Redex (Clos (Var (There el)) (Lift s) ) (Clos (Clos (Var n) s) Shift)
  VarShift : Redex (Clos (Var el)          Shift   ) (Var (There el))