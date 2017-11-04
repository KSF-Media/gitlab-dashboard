module Moment where

import Data.JSDate (JSDate, toUTCString)
import Data.Time.Duration (Milliseconds(..))
import Prelude (($))

foreign import formatTime_ :: Number -> String
foreign import fromNow_ :: String -> String

-- | Formats time in hh:mm:ss format
formatMillis :: Milliseconds -> String
formatMillis (Milliseconds n) = formatTime_ n

fromNow :: JSDate -> String
fromNow date = fromNow_ $ toUTCString date

