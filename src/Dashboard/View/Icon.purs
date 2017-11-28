module Dashboard.View.Icon where

import Prelude

import CSS (px)
import CSS as CSS
import Halogen (ClassName(..))
import Halogen.HTML (HTML)
import Halogen.HTML as H
import Halogen.HTML.CSS (style) as P
import Halogen.HTML.Properties (classes) as P

-- | TODO: Generate `purescript-fontawesome` library.
data IconName
  = Calendar
  | CircleO
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

iconName :: IconName -> String
iconName icon =
  case icon of
    Calendar          -> "calendar"
    CircleO           -> "circle-o"
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

data Modifier
  = Stack2x
  | Stack1x
  | Inverse
  | AlignMiddle
  | Size2x
  | Spin

modifierClass :: Modifier -> ClassName
modifierClass modifier =
  ClassName
    case modifier of
      Stack2x     -> "fa-stack-2x"
      Stack1x     -> "fa-stack-1x"
      Inverse     -> "fa-inverse"
      AlignMiddle -> "align-middle"
      Size2x      -> "fa-2x"
      Spin        -> "fa-spin"

data Icon
  = Icon (Array Modifier) IconName
  | IconStack (Array Icon)

fontAwesome :: ∀ p a. Icon -> HTML p a
fontAwesome (Icon modifiers icon) =
  H.i
    [ P.classes (fontAwesomeClasses icon <> map modifierClass modifiers)
    , P.style do
         CSS.margin (0.0 # px) (3.0 # px) (0.0 # px) (3.0 # px)
    ]
    [ ]
fontAwesome (IconStack icons) =
  H.span
    [ P.classes (fontAwesomeClasses Stack) ]
    (fontAwesome <$> icons)

fontAwesomeClasses :: IconName -> Array ClassName
fontAwesomeClasses icon =
  ClassName <$> [ "fa", "fa-" <> iconName icon ]
