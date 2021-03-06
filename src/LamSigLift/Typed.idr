module ES.LamSigLift.Typed

--import Data.List.Elem
import Iter
import Elem
import STLC.Ty
import STLC.Term

--%access public export
%default total

mutual
  public export
  data Tm : List Ty -> Ty -> Type where
    Var  : Tm (a::g) a
    Lam  : Tm (a::g) b -> Tm g (a~>b)
    App  : Tm g (a~>b) -> Tm g a -> Tm g b
    Clos : Tm g a -> Subs d g -> Tm d a

  public export
  data Subs : List Ty -> List Ty -> Type where
    Id    : Subs g g
    Lift  : Subs g d -> Subs (a::g) (a::d)
    Shift : Subs (a::g) g
    Cons  : Tm g a -> Subs g d -> Subs g (a::d)
    Comp  : Subs g e -> Subs e d -> Subs g d

encodeEl : (el : Elem a g) -> Subs g (a::dropWithElem g el)
encodeEl  Here      = Id
encodeEl (There el) = Comp Shift (encodeEl el)

encode : Term g a -> Tm g a
encode (Var el)  = Clos Var (encodeEl el)
encode (Lam t)   = Lam $ encode t
encode (App t u) = App (encode t) (encode u)

isVal : Tm g a -> Bool
isVal (Lam _) = True
isVal  Var    = True
isVal  _      = False

step : Tm g a -> Maybe (Tm g a)
step (App (Lam t)     u                                ) = Just $ Clos t (Cons u Id)
step (App  t          u                                ) =
  if isVal t
    then Nothing
    else [| App (step t) (pure u) |]
step (Clos (App t u)   s                               ) = Just $ App (Clos t s) (Clos u s)
step (Clos (Lam t)     s                               ) = Just $ Lam (Clos t (Lift s))
step (Clos (Clos t s)  r                               ) = Just $ Clos t (Comp r s)
step (Clos  Var       (Cons t s)                       ) = Just t
step (Clos  Var       (Lift s)                         ) = Just Var
step (Clos  Var       (Comp s (Lift r))                ) = Just $ Clos Var s
step (Clos  t          Id                              ) = Just t
step (Clos  t         (Comp s (Comp r q))              ) = Just $ Clos t (Comp (Comp s r) q)
step (Clos  t         (Comp s (Cons u r))              ) = Just $ Clos t (Cons (Clos u s) (Comp s r))
step (Clos  t         (Comp (Lift s) (Lift r))         ) = Just $ Clos t (Lift (Comp s r))
step (Clos  t         (Comp (Comp s (Lift r)) (Lift q))) = Just $ Clos t (Comp s (Lift (Comp r q)))
step (Clos  t         (Comp (Cons u s) (Lift r))       ) = Just $ Clos t (Cons u (Comp s r))
step (Clos  t         (Comp s Id)                      ) = Just $ Clos t s
step (Clos  t         (Comp Id s)                      ) = Just $ Clos t s
step (Clos  t         (Lift Id)                        ) = Just t
step (Clos  t         (Comp (Cons u s) Shift)          ) = Just $ Clos t s
step (Clos  t         (Comp (Lift s) Shift)            ) = Just $ Clos t (Comp Shift s)
step (Clos  t         (Comp (Comp s (Lift r)) Shift)   ) = Just $ Clos t (Comp (Comp s Shift) r)
step  _                                                  = Nothing

stepIter : Tm g a -> Tm g a
stepIter = iter step
