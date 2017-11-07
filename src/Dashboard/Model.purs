module Dashboard.Model where

import Data.Array
import Data.DateTime
import Data.JSDate
import Data.NonEmpty (NonEmpty)
import Data.NonEmpty as NE
import Data.Time.Duration
import Data.URI (URI)
import Data.URI as URI
import Gitlab
import Prelude
import Data.Maybe
import Data.Either

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
  , stages      :: Array JobStatus
  , duration    :: Milliseconds
  }


getUniqueStages :: Jobs -> Array JobStatus
getUniqueStages jobs = map _.status
                       $ sortWith _.id
                       $ mapMaybe (\grp -> last
                                           $ sortWith _.id
                                           $ NE.fromNonEmpty (:) grp)
                       $ groupBy (\a b -> a.name == b.name)
                       $ sortWith _.name jobs

