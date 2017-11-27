module Main where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Rec.Class (forever)
import Dashboard.Component as Dash
import Gitlab as Gitlab
import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import URLSearchParams as URLParams

-- | Takes the component IO handle and repeatedly tells it to fetch the projects.
pollProjects
  :: forall o. H.HalogenIO Dash.Query o (Aff Dash.Effects)
  -> Aff Dash.Effects Unit
pollProjects io = forever do
  void $ io.query $ H.action $ Dash.FetchProjects

main :: Eff Dash.Effects Unit
main = do
  token   <- Gitlab.Token   <$> URLParams.get "private_token"
  baseUrl <- Gitlab.BaseUrl <$> URLParams.get "gitlab_url"
  let config = { baseUrl, token }
  -- TODO: display error if parameters are not provided
  HA.runHalogenAff $ do
    body <- HA.awaitBody
    io <- runUI (Dash.ui config) unit body
    pollProjects io
