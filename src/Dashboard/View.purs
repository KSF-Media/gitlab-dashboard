module Dashboard.View where

import Prelude
import Halogen.HTML
import Halogen.HTML as H
import Halogen.HTML.Properties as P
import Halogen.HTML.CSS (style) as P
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.String as String
import CSS as CSS
import CSS.TextAlign as CSS
import CSS (px, em)

authorImage :: ∀ p i. String -> HTML p i
authorImage url =
  H.img
    [ P.height 20
    , P.width 20
    , P.style do
        CSS.borderRadius (20.0 # px) (20.0 # px) (20.0 # px) (20.0 # px)
    ]

-- | TODO: Generate `purescript-fontawesome` library.
data Icon
  = Calendar
  | ClockO
  | Code
  | CodeFork
  | Stack
  | DotCircleO
  | UserCircleO
  | Refresh
  | QuestionCircleO
  | CheckCircleO
  | TimesCircleO
  | StopCircleO
  | ArrowCircleORight

iconName :: Icon -> String
iconName =
  case _ of
    Calendar          -> "calendar"
    ClockO            -> "clock-o"
    Code              -> "code"
    CodeFork          -> "code-fork"
    Stack             -> "stack"
    DotCircleO        -> "dot-circle-o"
    UserCircleO       -> "user-circle-o"
    Refresh           -> "refresh"
    QuestionCircleO   -> "question-circle-o"
    CheckCircleO      -> "check-circle-o"
    TimesCircleO      -> "times-circle-o"
    StopCircleO       -> "stop-circle-o"
    ArrowCircleORight -> "arrow-circle-o-right"

fontAwesome :: ∀ p i. Icon -> Array ClassName -> HTML p i
fontAwesome icon moreClasses =
  H.i
    [ P.classes (fontAwesomeClasses icon <> moreClasses) ]
    [ ]

fontAwesomeClasses :: Icon -> Array ClassName
fontAwesomeClasses icon =
  ClassName <$> [ "fa", "fa-" <> iconName icon ]

data Status
  = Created
  | Manual
  | Running
  | Pending
  | Success
  | Failed
  | Canceled
  | Skipped

derive instance genericStatus :: Generic Status _

instance showStatus :: Show Status where
  show = genericShow

statusIcon :: ∀ p i. Status -> HTML p i
statusIcon Running =
  H.span
    [ P.classes (fontAwesomeClasses Stack) ]
    [ ]
statusIcon status =
  fontAwesome
    case status of
      Created  -> DotCircleO
      Manual   -> UserCircleO
      Running  -> Refresh
      Pending  -> QuestionCircleO
      Success  -> CheckCircleO
      Failed   -> TimesCircleO
      Canceled -> StopCircleO
      Skipped  -> ArrowCircleORight
    []

type Pipeline = { id :: String, status :: Status, repo :: String, commit :: Commit, stages :: Array Status, runningTime :: String}

formatStatus :: ∀ p a. Pipeline -> HTML p a
formatStatus { id, status } =
  H.div
    [ P.style do
        CSS.paddingLeft (2.0 # em)
    ]
    [ H.text $ "#" <> id
    , H.br []
    , H.text $ String.toUpper $ show status
    ]

type Commit = { branch :: String, hash :: String, img :: String, message :: String }

formatCommit :: ∀ p a. Commit -> HTML p a
formatCommit commit =
  H.div
    [ ]
    [ authorImage commit.img
    , divider
    , fontAwesome CodeFork []
    , H.b_ [ H.text commit.branch ]
    , divider
    , fontAwesome Code []
    , H.text commit.hash
    , H.br_
    , H.div
        [ P.classes [ ClassName "truncate" ] ]
        [ H.text commit.message ]
    ]
  where
    divider =
      H.span [ P.style (CSS.marginLeft (1.0 # em)) ] [ ]

formatTimes
  :: ∀ p a.
     { when :: String, runningTime :: String }
  -> HTML p a
formatTimes { when, runningTime } =
  H.div
    [ P.style do
        CSS.textAlign CSS.rightTextAlign
        CSS.paddingRight (2.0 # em)
    ]
    [ fontAwesome ClockO []
    , H.text runningTime
    , H.br_
    , fontAwesome Calendar []
    , H.text when
    ]

rowColor :: Status -> ClassName
rowColor _ = ClassName "FIXME"

formatPipeline :: ∀ p i. Pipeline -> HTML p i
formatPipeline pipeline =
    row (cell <$> cells)
  where
   cells =
     [ [ formatStatus pipeline ]
     , [ H.br_, H.text pipeline.repo, H.br_ ]
     , [ formatCommit pipeline.commit ]
     , statusIcon <$> pipeline.stages
     , [ formatTimes { when: "FIXME ago", runningTime: pipeline.runningTime } ]
     ]

   cell :: ∀ p i. Array (HTML p i) -> HTML p i
   cell =
     H.td
       [ P.style do
           CSS.textWhitespace CSS.whitespaceNoWrap
       ]

   row :: ∀ p i. Array (HTML p i) -> HTML p i
   row =
     H.tr
       [ P.classes [ rowColor pipeline.status ] ]
