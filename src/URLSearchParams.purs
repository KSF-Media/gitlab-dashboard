module URLSearchParams where

import Control.Monad.Eff (Eff)
import DOM (DOM)

foreign import get :: forall e. String -> Eff (dom :: DOM | e) String
