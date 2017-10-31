module Dashboard.View where

import Prelude ((#), (<>), (<$>))
import Halogen.HTML
import Halogen.HTML as H
import Halogen.HTML.Properties as P
import Halogen.HTML.CSS (style) as P
import CSS as CSS
import CSS (px)

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

fontAwesome :: ∀ p i. String -> Array ClassName -> HTML p i
fontAwesome name moreClasses =
  H.i
    [ P.classes (classes <> moreClasses) ]
    [ ]
  where
    classes = ClassName <$> [ "fa", "fa-" <> name ]
