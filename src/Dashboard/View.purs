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
import CSS (px, em)

cell :: ∀ p i. HTML p i -> HTML p i
cell content =
  H.td
    [ P.style do
        CSS.textWhitespace CSS.whitespaceNoWrap
    ]
    [ content ]

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

type Pipeline = { id :: String }

formatStatus :: ∀ p a. Pipeline -> Status -> HTML p a
formatStatus { id } status =
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
    [ ]
  where
    divider =
      H.span
        [ ]
        [ ]
