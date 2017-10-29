module Gitlab where

import Prelude
import Network.HTTP.Affjax (AJAX, get)
import Control.Monad.Aff (Aff)

type BaseUrl = String
type Token = String

getProjects :: forall a. BaseUrl -> Token -> Aff (ajax :: AJAX | a) String
getProjects baseUrl token = do
  let url = baseUrl
            <> "/api/v4/projects?private_token="
            <> token
            <> "&simple=true&per_page=20&order_by=last_activity_at"
  projectsRes <- get url
  pure $ projectsRes.response
