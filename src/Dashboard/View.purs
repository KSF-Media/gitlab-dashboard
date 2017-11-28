module Dashboard.View where

import Prelude

import Gitlab

import CSS (px, em)
import CSS as CSS
import CSS.TextAlign as CSS
import Data.JSDate (JSDate)
import Data.Newtype (unwrap)
import Data.Time.Duration (Milliseconds)
import Halogen.HTML (HTML, ClassName(..))
import Halogen.HTML as H
import Halogen.HTML.CSS (style)
import Halogen.HTML.Properties as P
import Moment (formatMillis, fromNow)

import Dashboard.Model (CommitRow, PipelineRow)
import Dashboard.View.Icon (Icon(..), IconName(..), Modifier(..), fontAwesome)

authorImage :: ∀ p i. String -> HTML p i
authorImage url =
  H.img
    [ P.src url
    , P.height 20
    , P.width 20
    , style do
        CSS.borderRadius (20.0 # px) (20.0 # px) (20.0 # px) (20.0 # px)
    ]

statusIcon :: ∀ p i. JobStatus -> HTML p i
statusIcon status =
  fontAwesome
    case status of
      JobRunning  -> IconStack
         [ Icon [ Stack2x ] CircleO
         , Icon [ Stack1x, Inverse, Spin ] Refresh
         ]
      JobCreated  -> Icon [ Size2x, AlignMiddle ] DotCircleO
      JobManual   -> Icon [ Size2x, AlignMiddle ] UserCircleO
      JobPending  -> Icon [ Size2x, AlignMiddle ] QuestionCircleO
      JobSuccess  -> Icon [ Size2x, AlignMiddle ] CheckCircleO
      JobFailed   -> Icon [ Size2x, AlignMiddle ] TimesCircleO
      JobCanceled -> Icon [ Size2x, AlignMiddle ] StopCircleO
      JobSkipped  -> Icon [ Size2x, AlignMiddle ] ArrowCircleORight  

formatStatus :: ∀ p a. PipelineRow -> HTML p a
formatStatus { id: PipelineId id, status } =
  H.div
    [ style do
        CSS.paddingLeft (2.0 # em)
    ]
    [ H.text $ "#" <> show id
    , H.br []
    , H.text $ show status
    ]

formatCommit :: ∀ p a. CommitRow -> HTML p a
formatCommit { authorImg
             , commitTitle
             , hash: CommitShortHash hash
             , branch: BranchName branch
             } =
  H.div
    [ ]
    [ authorImage authorImg
    , divider
    , fontAwesome $ Icon [] CodeFork
    , H.b_ [ H.text (" " <> branch) ]
    , divider
    , fontAwesome $ Icon [] Code
    , H.text (" " <> hash)
    , H.br_
    , H.div
        [ P.classes [ ClassName "truncate" ] ]
        [ H.text commitTitle ]
    ]
  where
    divider =
      H.span [ style (CSS.marginLeft (1.0 # em)) ] [ ]

formatTimes
  :: ∀ p a. { when     :: JSDate
            , duration :: Milliseconds
            }
  -> HTML p a
formatTimes { when, duration } =
  H.div
    [ style do
        CSS.textAlign CSS.rightTextAlign
        CSS.paddingRight (2.0 # em)
    ]
    [ fontAwesome $ Icon [] ClockO
    , H.text (" " <> formatMillis duration)
    , H.br_
    , fontAwesome $ Icon [] Calendar
    , H.text (" " <> fromNow when)
    ]

rowColor :: PipelineStatus -> ClassName
rowColor =
  case _ of
    Running  -> ClassName "bg-primary"
    Pending  -> ClassName "bg-info"
    Success  -> ClassName "bg-success"
    Failed   -> ClassName "bg-danger"
    Canceled -> ClassName "bg-warning"
    Skipped  -> ClassName "bg-none"

formatPipeline :: ∀ p i. PipelineRow -> HTML p i
formatPipeline pipeline =
    row (cell <$> cells)
  where
   cells =
     [ [ formatStatus pipeline ]
     , [ H.b_ [ H.text $ unwrap pipeline.project.name ] ]
     , [ formatCommit pipeline.commit ]
     , statusIcon <$> pipeline.stages
     , [ formatTimes { when: pipeline.created, duration: pipeline.duration } ]
     ]

   cell :: Array (HTML p i) -> HTML p i
   cell =
     H.td
       [ style do
           CSS.textAlign      CSS.leftTextAlign
           CSS.textWhitespace CSS.whitespaceNoWrap
       ]

   row :: Array (HTML p i) -> HTML p i
   row =
     H.tr
       [ P.classes [ rowColor pipeline.status ] ]
