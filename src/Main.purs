module Main where

import Prelude

import Control.Monad.Aff (Fiber, launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import DOM (DOM)
import Gitlab (getProjects)
import Network.HTTP.Affjax (AJAX)
import URLSearchParams as URLParams

type Main = forall e.
            Eff ( ajax :: AJAX
                , console :: CONSOLE
                , dom :: DOM
                | e)
                (Fiber ( ajax :: AJAX
                       , console :: CONSOLE
                       , dom :: DOM
                       | e)
                       Unit)

main :: Main
main = do
  token   <- URLParams.get "private_token"
  baseUrl <- URLParams.get "gitlab_url"
  log (baseUrl <> " " <> token)
  launchAff $ do
    projects <- getProjects baseUrl token
    liftEff $ logShow projects
