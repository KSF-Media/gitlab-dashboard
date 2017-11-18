module Main where

import Prelude

import Control.Monad.Aff (Fiber, launchAff)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Gitlab (BaseUrl(..), ProjectId(..), ProjectName(..), Token(..), getJobs, getProjects)
import Global.Unsafe (unsafeStringify)
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
  token   <- Token   <$> URLParams.get "private_token"
  baseUrl <- BaseUrl <$> URLParams.get "gitlab_url"
  -- TODO: display error if parameters are not provided
  launchAff $ do
    projects <- getProjects baseUrl token
    log $ unsafeStringify projects
    let proj = {name: (ProjectName "faro"), id: (ProjectId 64)} -- example project with pipelines
    jobs <- getJobs baseUrl token proj
    log $ unsafeStringify jobs
