module Dashboard.Model where

import Data.Array
import Data.DateTime
import Data.Either
import Data.JSDate
import Data.Maybe
import Data.Time.Duration
import Gitlab
import Prelude

import Data.NonEmpty (NonEmpty)
import Data.NonEmpty as NE
import Data.URI (URI)
import Data.URI as URI
import Halogen.HTML.Core (ClassName(..))


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


{-
makePipelineRow :: NonEmpty Array Job -> PipelineRow
makePipelineRow jobs = ?a
  where
    job = NE.head jobs
  --{ authorImg: throwLeft $ URI.runParseURI  }


makePipelineRows :: Jobs -> Array PipelineRow
makePipelineRows jobs = map makePipelineRow
                        $ groupBy (\a b -> a.project.name == b.project.name)
                        $ sortWith (\j -> j.project.name) jobs
-}
