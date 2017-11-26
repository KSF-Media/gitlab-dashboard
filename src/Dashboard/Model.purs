module Dashboard.Model where

import Data.Array
import Gitlab
import Prelude

import Data.DateTime (DateTime, diff)
import Data.JSDate (JSDate, toDateTime)
import Data.Maybe (Maybe, fromJust, fromMaybe)
import Data.NonEmpty (NonEmpty)
import Data.NonEmpty as NE
import Data.Time.Duration (Milliseconds(..))
import Partial.Unsafe (unsafePartial)

type CommitRow =
  { branch      :: BranchName
  , hash        :: CommitShortHash
  , authorImg   :: String
  , commitTitle :: String
  }

type PipelineRow =
  { commit      :: CommitRow
  , created     :: JSDate
  , status      :: PipelineStatus
  , id          :: PipelineId
  , project     :: Project
  , stages      :: Array JobStatus
  , duration    :: Milliseconds
  }


getUniqueStages :: Array Job -> Array JobStatus
getUniqueStages jobs = map _.status
                       $ sortWith _.id
                       $ mapMaybe (\grp -> last
                                           $ sortWith _.id
                                           $ NE.fromNonEmpty (:) grp)
                       $ groupBy (\a b -> a.name == b.name)
                       $ sortWith _.name jobs

makePipelineRow :: NonEmpty Array Job -> PipelineRow
makePipelineRow jobs =
  { status: job.pipeline.status
  , id: job.pipeline.id
  , project: fromMaybe defaultProject job.project
  , stages: getUniqueStages jobs'
  , created: createdTime
  , duration: fromMaybe (Milliseconds 0.0) $ runningTime jobs'
  , commit: { branch: job.ref
            , hash: job.commit.short_id
            , commitTitle: job.commit.title
            , authorImg: job.user.avatar_url
            }
  }
  where
    job = NE.head jobs
    jobs' = NE.fromNonEmpty (:) jobs
    defaultProject = {id: (ProjectId 0), name: (ProjectName "")}
    createdTime = job.created_at

    -- | Returns the total running time of a set of Jobs
    --   (which should belong to the same Pipeline)
    runningTime :: Array Job -> Maybe Milliseconds
    runningTime pipelineJobs = do
      -- Parse all into DateTime, get the earliest starting time
      started  <- head
                  $ sort
                  $ mapMaybe (\j -> toDateTime =<< j.started_at) pipelineJobs
      -- Parse all into DateTime, get the latest finishing time
      finished <- head
                  $ reverse
                  $ sort
                  $ mapMaybe (\j -> toDateTime =<< j.finished_at) pipelineJobs
      pure $ diff finished started

-- | Given all the Jobs for a Project, makes a PipelineRow out of each Pipeline
makeProjectRows :: Jobs -> Array PipelineRow
makeProjectRows jobs = map makePipelineRow
                       $ groupBy (\a b -> (_.pipeline.id a) == (_.pipeline.id b))
                       $ sortWith _.pipeline.id jobs

createdDateTime :: PipelineRow -> DateTime
createdDateTime job = unsafePartial $ fromJust $ toDateTime job.created

