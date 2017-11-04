module Dashboard.Model where

import Prelude

import Gitlab
import Data.URI
import Data.JSDate
import Data.DateTime
import Data.Time.Duration
import Halogen.HTML.Core (ClassName(..))

type PipelineRow =
  { authorImg   :: URI
  , commitTitle :: String
  , hash        :: CommitShortHash
  , branch      :: BranchName
  , created     :: DateTime
  , status      :: PipelineStatus
  , id          :: PipelineId
  , project     :: Project
  , stages      :: Jobs
  , duration    :: Milliseconds
  }

rowColors :: PipelineStatus -> ClassName
rowColors status = case status of
  Running  -> ClassName "bg-primary"
  Pending  -> ClassName "bg-info"
  Success  -> ClassName "bg-success"
  Failed   -> ClassName "bg-danger"
  Canceled -> ClassName "bg-warning"
  Skipped  -> ClassName "bg-none"

-- TODO: return an HTML element instead. See status2icon
statusIcons :: JobStatus -> String
statusIcons status = case status of
  JobCreated  -> "dot-circle-o"
  JobManual   -> "user-circle-o"
  JobRunning  -> "refresh"
  JobPending  -> "question-circle-o"
  JobSuccess  -> "check-circle-o"
  JobFailed   -> "times-circle-o"
  JobCanceled -> "stop-circle-o"
  JobSkipped  -> "arrow-circle-o-right"

