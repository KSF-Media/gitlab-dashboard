module Dashboard.View where

import Prelude

import CSS (px, em)
import CSS as CSS
import CSS.TextAlign as CSS
import Dashboard.Model as Model
import Dashboard.View.Icon (Icon(..), IconName(..), Modifier(..), fontAwesome)
import Data.Array (head)
import Data.JSDate (JSDate)
import Data.Maybe (fromMaybe)
import Data.Newtype (unwrap)
import Data.String (Pattern(..), split)
import Data.Time.Duration (Milliseconds)
import Gitlab as Gitlab
import Halogen.HTML (HTML, ClassName(..))
import Halogen.HTML as H
import Halogen.HTML.CSS (style)
import Halogen.HTML.Properties as P
import Moment (formatMillis, fromNow)

authorImage :: ∀ p i. String -> HTML p i
authorImage url =
  H.img
    [ P.src url
    , P.height 20
    , P.width 20
    , style do
        CSS.borderRadius (20.0 # px) (20.0 # px) (20.0 # px) (20.0 # px)
    ]

statusIcon :: ∀ p i. Gitlab.JobStatus -> HTML p i
statusIcon status =
  fontAwesome
    case status of
      Gitlab.JobRunning  -> IconStack
         [ Icon [ Stack2x ] CircleO
         , Icon [ Stack1x, Inverse, Spin ] Refresh
         ]
      Gitlab.JobCreated  -> Icon [ Size2x, AlignMiddle ] DotCircleO
      Gitlab.JobManual   -> Icon [ Size2x, AlignMiddle ] UserCircleO
      Gitlab.JobPending  -> Icon [ Size2x, AlignMiddle ] QuestionCircleO
      Gitlab.JobSuccess  -> Icon [ Size2x, AlignMiddle ] CheckCircleO
      Gitlab.JobFailed   -> Icon [ Size2x, AlignMiddle ] TimesCircleO
      Gitlab.JobCanceled -> Icon [ Size2x, AlignMiddle ] StopCircleO
      Gitlab.JobSkipped  -> Icon [ Size2x, AlignMiddle ] ArrowCircleORight

formatStatus :: ∀ p a. Model.PipelineRow -> HTML p a
formatStatus { id: Gitlab.PipelineId id, status } =
  H.div
    [ style do
        CSS.paddingLeft (2.0 # em)
    ]
    [ H.text $ "#" <> show id
    , H.br []
    , H.text $ show status
    ]

formatName :: ∀ p a. Model.NameRow -> HTML p a
formatName  { id
            , name: Gitlab.ProjectName name
            , name_with_namespace: Gitlab.ProjectNameWithNamespace namespace
            }
            =
  H.div []
        [ H.text $ fromMaybe "" $ head $ split (Pattern "/") namespace
        , H.br_
        , H.b_ [ H.text name ]
        ]

formatCommit :: ∀ p a. Model.CommitRow -> HTML p a
formatCommit { authorImg
             , name
             , username
             , commitTitle
             , hash: Gitlab.CommitShortHash hash
             , branch: Gitlab.BranchName branch
             }
             =
  H.div
    [ ]
    [ authorImage authorImg
    , H.text (" " <> name <> " (" <> username <> ")")
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

formatPipeline :: ∀ p i. Model.PipelineRow -> HTML p i
formatPipeline pipeline =
    row (cell <$> cells)
  where
   cells =
     [ [ formatStatus pipeline ]
     , [ formatName pipeline.project ]
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

   rowColor :: Gitlab.PipelineStatus -> ClassName
   rowColor status =
      case status of
        Gitlab.Running  -> ClassName "bg-primary"
        Gitlab.Pending  -> ClassName "bg-info"
        Gitlab.Success  -> ClassName "bg-success"
        Gitlab.Failed   -> ClassName "bg-danger"
        Gitlab.Canceled -> ClassName "bg-warning"
        Gitlab.Skipped  -> ClassName "bg-none"
        Gitlab.Manual   -> ClassName "bg-info"

