module URLSearchParams where

import Effect (Effect)

foreign import get :: String -> Effect String
