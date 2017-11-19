module Main where

import Prelude

import Dashboard.Component as Dash
import Control.Monad.Aff (Aff, Milliseconds(..), delay)
import Control.Monad.Aff.Console (CONSOLE, log)
import Control.Monad.Eff (Eff)
import Dashboard.Model as Model
import Data.Array (uncons)
import Data.Maybe (Maybe(..))
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
pollProjects baseUrl token query = do
  -- Get projects, poll all of them for jobs
  log "Fetching list of projects..."
  projects <- getProjects baseUrl token
  fetchJobs projects

  -- Wait 30 secs and recur
  delay (Milliseconds 30000.0)
  _ <- pollProjects baseUrl token query
  pure unit
  where
    -- If list of projects is empty, return
    -- If not, take the first, get jobs, and upsert in the Component
    -- Then wait 1s, and recur to fetch the rest
    fetchJobs projects = case uncons projects of
      Nothing -> pure unit
      Just { head: p, tail: ps } -> do
        log $ "Fetching Jobs for Project with id: " <> unsafeStringify p.id
        jobs <- getJobs baseUrl token p
        _ <- query
             $ H.action
             $ Dash.UpsertProjectPipelines
             $ Model.makeProjectRows jobs
        delay (Milliseconds 1000.0)
        fetchJobs ps

main :: forall e. Eff (HA.HalogenEffects (ajax :: AJAX, console :: CONSOLE | e)) Unit
main = do
  token   <- Token   <$> URLParams.get "private_token"
  baseUrl <- BaseUrl <$> URLParams.get "gitlab_url"
  -- TODO: display error if parameters are not provided
  HA.runHalogenAff $ do
    body <- HA.awaitBody
    io <- runUI Dash.ui unit body
    pollProjects baseUrl token io.query
