{ name = "gitlab-dashboard"
, dependencies =
  [ "aff"
  , "affjax"
  , "affjax-web"
  , "argonaut-core"
  , "arrays"
  , "console"
  , "css"
  , "datetime"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "foreign-generic"
  , "halogen"
  , "halogen-css"
  , "js-date"
  , "maybe"
  , "newtype"
  , "partial"
  , "prelude"
  , "simple-json"
  , "strings"
  , "tailrec"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
