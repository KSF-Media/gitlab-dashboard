module Main where

import Prelude

import Control.Monad.Rec.Class (forever)
import Dashboard.Component as Dash
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay)
import Effect.Class.Console (log)
import Gitlab as Gitlab
import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import URLSearchParams as URLParams

-- | Takes the component IO handle and repeatedly tells it to fetch the projects.
pollProjects
  :: forall o. H.HalogenIO Dash.Query o Aff
  -> Aff Unit
pollProjects io = forever do
  query <- io.query (H.mkTell $ Dash.FetchProjects)
  case query of 
    Just q -> pure q
    Nothing -> do 
      log $ "Polling failed"
      delay (Milliseconds 5000.0)

main :: Effect Unit
main = do
  token   <- Gitlab.Token   <$> URLParams.get "private_token"
  baseUrl <- Gitlab.BaseUrl <$> URLParams.get "gitlab_url"
  let config = { baseUrl, token }
  -- TODO: display error if parameters are not provided
  HA.runHalogenAff do
    body <- HA.awaitBody
    io <- runUI (Dash.ui config) unit body
    pollProjects io
