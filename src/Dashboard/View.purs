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

