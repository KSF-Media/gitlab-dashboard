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
  "running"  -> ClassName "bg-primary"
  "pending"  -> ClassName "bg-info"
  "success"  -> ClassName "bg-success"
  "failed"   -> ClassName "bg-danger"
  "canceled" -> ClassName "bg-warning"
  "skipped"  -> ClassName "bg-none"
  _          -> ClassName "bg-none"

-- TODO: return an HTML element instead. See status2icon
statusIcons :: JobStatus -> String
statusIcons status = case status of
  "created"  -> "dot-circle-o"
  "manual"   -> "user-circle-o"
  "running"  -> "refresh"
  "pending"  -> "question-circle-o"
  "success"  -> "check-circle-o"
  "failed"   -> "times-circle-o"
  "canceled" -> "stop-circle-o"
  "skipped"  -> "arrow-circle-o-right"
  _          -> ""

