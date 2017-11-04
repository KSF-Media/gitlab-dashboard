module Gitlab where

import Prelude

import Control.Monad.Aff (Aff, error, throwError)
import Data.Either (Either(..))
import Data.Foreign.Generic.EnumEncoding (genericDecodeEnum, genericEncodeEnum)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Data.String (toLower, drop)
import Network.HTTP.Affjax (AJAX, get)
import Network.HTTP.StatusCode (StatusCode(..))
import Simple.JSON (class ReadForeign, class WriteForeign, readJSON, writeJSON)

newtype BaseUrl = BaseUrl String
newtype Token = Token String

data PipelineStatus
  = Running
  | Pending
  | Success
  | Failed
  | Canceled
  | Skipped

derive instance eqPipelineStatus :: Eq PipelineStatus
derive instance genericPipelineStatus :: Generic PipelineStatus _

instance readForeignPipelineStatus :: ReadForeign PipelineStatus where
  readImpl = genericDecodeEnum {constructorTagTransform: toLower}
instance writeForeignPipelineStatus :: WriteForeign PipelineStatus where
  writeImpl = genericEncodeEnum {constructorTagTransform: toLower}
instance showPipelineStatus :: Show PipelineStatus where
  show = genericShow

data JobStatus
  = JobCreated
  | JobManual
  | JobRunning
  | JobPending
  | JobSuccess
  | JobFailed
  | JobCanceled
  | JobSkipped

derive instance eqJobStatus :: Eq JobStatus
derive instance genericJobeStatus :: Generic JobStatus _

instance readForeignJobStatus :: ReadForeign JobStatus where
  readImpl = genericDecodeEnum {constructorTagTransform: (drop 3) <<< toLower}
instance writeForeignJobStatus :: WriteForeign JobStatus where
  writeImpl = genericEncodeEnum {constructorTagTransform: (drop 3) <<< toLower}
instance showJobStatus :: Show JobStatus where
  show = genericShow

newtype ProjectId = ProjectId Int
derive newtype instance readforeignProjectId :: ReadForeign ProjectId
derive newtype instance writeforeignProjectId :: WriteForeign ProjectId

newtype ProjectName = ProjectName String
derive newtype instance readforeignProjectName :: ReadForeign ProjectName
derive newtype instance writeforeignProjectName :: WriteForeign ProjectName

newtype CommitShortHash = CommitShortHash String
derive newtype instance readforeignCommitShortHash :: ReadForeign CommitShortHash
derive newtype instance writeforeignCommitShortHash :: WriteForeign CommitShortHash

newtype PipelineId = PipelineId Int
derive newtype instance readforeignPipelineId :: ReadForeign PipelineId
derive newtype instance writeforeignPipelineId :: WriteForeign PipelineId

newtype JobId = JobId Int
derive newtype instance readforeignJobId :: ReadForeign JobId
derive newtype instance writeforeignJobId :: WriteForeign JobId

newtype BranchName = BranchName String
derive newtype instance readforeignBranchName :: ReadForeign BranchName
derive newtype instance writeforeignBranchName :: WriteForeign BranchName

newtype ISODateString = ISODateString String
derive newtype instance readforeignISODateString :: ReadForeign ISODateString
derive newtype instance writeforeignISODateString :: WriteForeign ISODateString


type Project =
  { id   :: ProjectId
  , name :: ProjectName
  }

type User =
  { avatar_url :: String
  }

type Commit =
  { title    :: String
  , short_id :: CommitShortHash
  }

type Pipeline =
  { id     :: PipelineId
  , status :: PipelineStatus
  }

type Job =
  { project     :: Maybe Project
  , user        :: User
  , commit      :: Commit
  , ref         :: BranchName
  , pipeline    :: Pipeline
  , status      :: JobStatus
  , id          :: JobId
  , created_at  :: ISODateString
  , started_at  :: Maybe ISODateString
  , finished_at :: Maybe ISODateString
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
            <> writeJSON project.id -- same as show in this case
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
