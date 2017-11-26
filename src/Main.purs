module Main where

import Prelude

import Dashboard.Component as Dash
import Control.Monad.Aff (Aff, Milliseconds(..), delay)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff (Eff)
import Control.Monad.Rec.Class (forever)
import Dashboard.Model as Model
import Data.Array (uncons)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse_)
import Gitlab (BaseUrl(..), Token(..), getJobs, getProjects)
import Global.Unsafe (unsafeStringify)
import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Network.HTTP.Affjax (AJAX)
import URLSearchParams as URLParams


pollProjects ::
  forall a eff.
  BaseUrl
  -> Token
  -> (Dash.Query Unit -> Aff (ajax :: AJAX, console :: CONSOLE | eff) a)
  -> Aff (ajax :: AJAX, console :: CONSOLE | eff) Unit
pollProjects baseUrl token query = forever do
  -- Get projects, poll all of them for jobs
  log "Fetching list of projects..."
  projects <- getProjects baseUrl token
  fetchJobs projects
  -- wait 30 secs
  delay (Milliseconds 30000.0)  
  where
    -- update each job, wait 1s after each update
    fetchJobs = traverse_ \project -> do
        log $ "Fetching Jobs for Project with id: " <> unsafeStringify project.id
        jobs <- getJobs baseUrl token project
        _ <- query
             $ H.action
             $ Dash.UpsertProjectPipelines
             $ Model.makeProjectRows jobs
        delay (Milliseconds 1000.0)

main :: forall e. Eff (HA.HalogenEffects (ajax :: AJAX, console :: CONSOLE | e)) Unit
main = do
  token   <- Token   <$> URLParams.get "private_token"
  baseUrl <- BaseUrl <$> URLParams.get "gitlab_url"
  -- TODO: display error if parameters are not provided
  HA.runHalogenAff $ do
    body <- HA.awaitBody
    io <- runUI Dash.ui unit body
    pollProjects baseUrl token io.query
