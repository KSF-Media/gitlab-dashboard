module Gitlab where

import Prelude

import Control.Monad.Aff (Aff)
import Data.Either (Either(..))
import Network.HTTP.Affjax (AJAX, get)
import Simple.JSON (class ReadForeign, class WriteForeign, readJSON)


type BaseUrl = String
type Token = String

newtype Id = Id Int
derive newtype instance rfId :: ReadForeign Id
derive newtype instance wfId :: WriteForeign Id

newtype Name = Name String
derive newtype instance rfName :: ReadForeign Name
derive newtype instance wfName :: WriteForeign Name

type Project =
  { id :: Id
  , name :: Name
  }

type Projects = Array Project


getProjects :: forall a. BaseUrl -> Token -> Aff (ajax :: AJAX | a) Projects
getProjects baseUrl token = do
  let url = baseUrl
            <> "/api/v4/projects?private_token="
            <> token
            <> "&simple=true&per_page=20&order_by=last_activity_at"
  projectsRes <- get url
  let ps = case readJSON projectsRes.response of
        Left e -> []
        Right projects -> projects
  pure ps