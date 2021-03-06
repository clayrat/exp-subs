module LamSig.Minimal.KAM

import Untyped.Term
import Untyped.KAM
import LamSig.Minimal.Term

-- KAM embedding

mutual
  closLS : Clos -> Tm
  closLS (Cl t e) = Clos (termLS t) (envLS e)

  envLS : Env -> Subs
  envLS []     = Id
  envLS (c::e) = Cons (closLS c) (envLS e)

stkRec : Tm -> Stack -> Tm
stkRec t []     = t
stkRec t (c::s) = stkRec (App t (closLS c)) s

stateLS : State -> Tm
stateLS (t, e, s) = stkRec (Clos (termLS t) (envLS e)) s
