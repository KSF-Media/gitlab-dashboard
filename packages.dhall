let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.7-20230408/packages.dhall
        sha256:eafb4e5bcbc2de6172e9457f321764567b33bc7279bd6952468d0d422aa33948

let additions =
      { foreign-generic =
        { repo = "https://github.com/jsparkes/purescript-foreign-generic"
        , version = "844f2ababa2c7a0482bf871e1e6bf970b7e51313"
        , dependencies =
          [ "arrays"
          , "assert"
          , "bifunctors"
          , "console"
          , "control"
          , "effect"
          , "either"
          , "exceptions"
          , "foldable-traversable"
          , "foreign"
          , "foreign-object"
          , "identity"
          , "lists"
          , "maybe"
          , "newtype"
          , "partial"
          , "prelude"
          , "record"
          , "strings"
          , "transformers"
          , "tuples"
          , "typelevel-prelude"
          , "unsafe-coerce"
          ]
        }
      , simple-json =
        { repo = "https://github.com/justinwoo/purescript-simple-json"
        , version = "b85e112131240ff95b5c26e9abb8e2fa6db3c656"
        , dependencies =
          [ "prelude"
          , "typelevel-prelude"
          , "record"
          , "variant"
          , "nullable"
          , "foreign-object"
          , "foreign"
          , "exceptions"
          , "arrays"
          ]
        }
      }

in  upstream // additions
