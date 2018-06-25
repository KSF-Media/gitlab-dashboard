module URLSearchParams where

import Effect (Effect)

foreign import get :: forall e. String -> Effect String
