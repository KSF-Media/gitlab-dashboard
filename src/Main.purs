module Main where

import Prelude

import Effect.Aff (Aff, Milliseconds(..), catchError, delay)
import Effect.Class.Console (log)
import Effect (Effect)
import Effect.Exception as Error
import Control.Monad.Rec.Class (forever)
import Dashboard.Component as Dash
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
  io.query (H.action $ Dash.FetchProjects)
    `catchError` \error -> do
      log $ "Polling failed with error: " <> Error.message error
      delay (Milliseconds 5000.0)

main :: Effect Unit
main = do
  token   <- Gitlab.Token   <$> URLParams.get "private_token"
  baseUrl <- Gitlab.BaseUrl <$> URLParams.get "gitlab_url"
  groupId <- Gitlab.GroupId <$> URLParams.get "group_id"
  userId  <- Gitlab.UserId  <$> URLParams.get "user_id"
  let config = { baseUrl, token, groupId, userId }
  -- TODO: display error if parameters are not provided
  HA.runHalogenAff $ do
    body <- HA.awaitBody
    io <- runUI (Dash.ui config) unit body
    pollProjects io
