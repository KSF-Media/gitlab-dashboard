module Gitlab where

import Prelude

import Affjax (get)
import Affjax.ResponseFormat (json)
import Affjax.Web (driver)
import Data.Argonaut.Core as JSON
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.JSDate (JSDate, parse)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Data.String (toLower, drop)
import Effect.Aff (Aff, error, throwError)
import Effect.Class.Console (log)
import Effect.Unsafe (unsafePerformEffect)
import Foreign.Generic.EnumEncoding (genericDecodeEnum, genericEncodeEnum)
import Simple.JSON (class ReadForeign, class WriteForeign, readJSON)

newtype BaseUrl = BaseUrl String
newtype Token = Token String

data PipelineStatus
  = Running
  | Pending
  | Success
  | Failed
  | Canceled
  | Skipped
  | Manual

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
derive newtype instance showProjectId :: Show ProjectId
derive newtype instance readforeignProjectId :: ReadForeign ProjectId
derive newtype instance writeforeignProjectId :: WriteForeign ProjectId

newtype ProjectName = ProjectName String
derive instance newtypeProjectName :: Newtype ProjectName _
derive newtype instance eqProjectName :: Eq ProjectName
derive newtype instance ordProjectName :: Ord ProjectName
derive newtype instance readforeignProjectName :: ReadForeign ProjectName
derive newtype instance writeforeignProjectName :: WriteForeign ProjectName

newtype ProjectNameWithNamespace = ProjectNameWithNamespace String
derive instance newtypeProjectNameWithNamespace :: Newtype ProjectNameWithNamespace _
derive newtype instance eqProjectNameWithNamespace :: Eq ProjectNameWithNamespace
derive newtype instance ordProjectNameWithNamespace :: Ord ProjectNameWithNamespace
derive newtype instance readforeignProjectNameWithNamespace :: ReadForeign ProjectNameWithNamespace
derive newtype instance writeforeignProjectNameWithNamespace :: WriteForeign ProjectNameWithNamespace

newtype CommitShortHash = CommitShortHash String
derive newtype instance readforeignCommitShortHash :: ReadForeign CommitShortHash
derive newtype instance writeforeignCommitShortHash :: WriteForeign CommitShortHash

newtype PipelineId = PipelineId Int
derive newtype instance eqPipelineId :: Eq PipelineId
derive newtype instance ordPipelineId :: Ord PipelineId
derive newtype instance readforeignPipelineId :: ReadForeign PipelineId
derive newtype instance writeforeignPipelineId :: WriteForeign PipelineId

newtype JobId = JobId Int
derive newtype instance eqJobId :: Eq JobId
derive newtype instance ordJobId :: Ord JobId
derive newtype instance readforeignJobId :: ReadForeign JobId
derive newtype instance writeforeignJobId :: WriteForeign JobId

newtype JobName = JobName String
derive newtype instance eqJobName :: Eq JobName
derive newtype instance ordJobName :: Ord JobName
derive newtype instance readforeignJobName :: ReadForeign JobName
derive newtype instance writeforeignJobName :: WriteForeign JobName
derive newtype instance showJobName :: Show JobName

newtype BranchName = BranchName String
derive newtype instance readforeignBranchName :: ReadForeign BranchName
derive newtype instance writeforeignBranchName :: WriteForeign BranchName


type Project =
  { id   :: ProjectId
  , name :: ProjectName
  , name_with_namespace :: ProjectNameWithNamespace
  }

type User =
  { avatar_url :: String
  , name :: String
  , username :: String
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
  { project_     :: Maybe Project
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


getProjects :: BaseUrl -> Token -> Aff Projects
getProjects (BaseUrl baseUrl) (Token token) = do
  let url = baseUrl
            <> "/api/v4/projects?private_token="
            <> token
            <> "&simple=true&per_page=20&order_by=last_activity_at"
  projectsRes <- get driver json url
  x <- case projectsRes of
    Right x -> case readJSON $ JSON.stringify x.body of
      Left err -> do
        throwError $ error ("Failed to parse projects: " <> show err)
      Right projects -> pure projects
    Left _ -> do
      throwError $ error ("Failed to fetch projects") 
  pure x

getJobs :: BaseUrl -> Token -> Project -> Aff Jobs
getJobs (BaseUrl baseUrl) (Token token) project = do
  let url = baseUrl
            <> "/api/v4/projects/"
            <> show project.id
            <> "/jobs?private_token="
            <> token
            <> "&per_page=100"
  jobsRes <- get driver json url
  x <- case jobsRes of
    Right res -> case readJSON $ JSON.stringify res.body of
      Left err -> do
        log $ "readJSON failed with: " <> show err
        throwError $ error ("Failed to parse jobs: " <> show err)
      Right jobs -> do
        pure $ map (setProject project) $ map castDates jobs
    Left _ -> do  
      throwError $ error "Failed to fetch jobs"
  pure x
    
    where

      setProject :: Project -> Job -> Job
      setProject p j = j {project_ = Just p}

      -- I know, but it's just for accessing locale
      readJSDate :: String -> JSDate
      readJSDate date = unsafePerformEffect $ parse date

      castDates job = job
        { created_at = readJSDate job.created_at
        , started_at = (Just <<< readJSDate) =<< job.started_at
        , finished_at = (Just <<< readJSDate) =<< job.finished_at
        }
