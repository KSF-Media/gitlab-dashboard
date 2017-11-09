module Gitlab where

import Prelude

import Control.Monad.Aff (Aff, error, throwError)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Data.Either (Either(..))
import Data.Foreign.Generic.EnumEncoding (genericDecodeEnum, genericEncodeEnum)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.JSDate (JSDate, LOCALE, parse, toDateString)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Record (set)
import Data.String (toLower, drop)
import Network.HTTP.Affjax (AJAX, get)
import Network.HTTP.StatusCode (StatusCode(..))
import Simple.JSON (class ReadForeign, class WriteForeign, readJSON, writeJSON)
import Type.Prelude (SProxy(..))

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
derive instance newtypeProjectName :: Newtype ProjectName _
derive newtype instance eqProjectName :: Eq ProjectName
derive newtype instance ordProjectName :: Ord ProjectName
derive newtype instance readforeignProjectName :: ReadForeign ProjectName
derive newtype instance writeforeignProjectName :: WriteForeign ProjectName

newtype CommitShortHash = CommitShortHash String
derive newtype instance readforeignCommitShortHash :: ReadForeign CommitShortHash
derive newtype instance writeforeignCommitShortHash :: WriteForeign CommitShortHash

newtype PipelineId = PipelineId Int
derive newtype instance readforeignPipelineId :: ReadForeign PipelineId
derive newtype instance writeforeignPipelineId :: WriteForeign PipelineId

newtype JobId = JobId Int
derive newtype instance ordJobId :: Ord JobId
derive newtype instance readforeignJobId :: ReadForeign JobId
derive newtype instance writeforeignJobId :: WriteForeign JobId

newtype JobName = JobName String
derive newtype instance eqJobName :: Eq JobName
derive newtype instance ordJobName :: Ord JobName
derive newtype instance readforeignJobName :: ReadForeign JobName
derive newtype instance writeforeignJobName :: WriteForeign JobName

newtype BranchName = BranchName String
derive newtype instance readforeignBranchName :: ReadForeign BranchName
derive newtype instance writeforeignBranchName :: WriteForeign BranchName


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
  , name        :: JobName
  , created_at  :: JSDate
  , started_at  :: Maybe JSDate
  , finished_at :: Maybe JSDate
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

getJobs :: forall a.
           BaseUrl -> Token -> Project
           -> Aff (ajax :: AJAX, locale :: LOCALE | a) Jobs
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
    Right jobs -> pure $ map (setProject project) $ map castDates jobs
    where
      setProject :: Project -> Job -> Job
      setProject p j = j {project = Just p}

      -- I know, but it's just for accessing locale
      readJSDate :: String -> JSDate
      readJSDate date = unsafePerformEff $ parse date

      castDates job = job
        { created_at = readJSDate job.created_at
        , started_at = (Just <<< readJSDate) =<< job.started_at
        , finished_at = (Just <<< readJSDate) =<< job.finished_at
        }
