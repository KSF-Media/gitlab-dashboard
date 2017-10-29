module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import DOM (DOM)
import URLSearchParams as URLParams

main :: forall e. Eff (dom :: DOM, console :: CONSOLE | e) Unit
main = do
  token     <- URLParams.get "private_token"
  gitlabUrl <- URLParams.get "gitlab_url"
  log (token <> " " <> gitlabUrl)
