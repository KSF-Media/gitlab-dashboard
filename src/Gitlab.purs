module Gitlab where

import Prelude

import Control.Monad.Aff (Aff, error, throwError)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Network.HTTP.Affjax (AJAX, get)
import Network.HTTP.StatusCode (StatusCode(..))
import Simple.JSON (readJSON)

newtype BaseUrl = BaseUrl String
newtype Token = Token String

type Project =
  { id   :: Int
  , name :: String
  }

type User =
  { avatar_url :: String
  }

type Commit =
  { title    :: String
  , short_id :: String
  }

type Pipeline =
  { id     :: Int
  , status :: String -- TODO: make enum?
  }

type Job =
  { project     :: Maybe Project
  , user        :: User
  , commit      :: Commit
  , ref         :: String
  , pipeline    :: Pipeline
  , status      :: String -- TODO: make enum
  , created_at  :: String
  , started_at  :: Maybe String
  , finished_at :: Maybe String
  }

type Projects = Array Project
type Jobs = Array Job


getProjects :: forall a. BaseUrl -> Token -> Aff (ajax :: AJAX | a) Projects
getProjects (BaseUrl baseUrl) (Token token) = do
  let url = baseUrl
            <> "/api/v4/projects?private_token="
            <> token
            <> "&simple=true&per_page=20&order_by=last_activity_at"
  projectsRes <- get url
  when (projectsRes.status /= (StatusCode 200)) do
    throwError $ error "Failed to fetch projects"
  case readJSON projectsRes.response of
    Left e -> do
      throwError $ error ("Failed to parse projects: " <> show e)
    Right projects -> pure projects

getJobs :: forall a. BaseUrl -> Token -> Project -> Aff (ajax :: AJAX | a) Jobs
getJobs (BaseUrl baseUrl) (Token token) project = do
  let url = baseUrl
            <> "/api/v4/projects/"
            <> show project.id
            <> "/jobs?private_token="
            <> token
            <> "&per_page=100"
  jobsRes <- get url
  when (jobsRes.status /= (StatusCode 200)) do
    throwError $ error "Failed to fetch jobs"
  case readJSON jobsRes.response of
    Left e -> do
      throwError $ error ("Failed to parse jobs: " <> show e)
    Right jobs -> pure $ map (setProject project) jobs
    where
      setProject :: Project -> Job -> Job
      setProject p j = j {project = Just p}
