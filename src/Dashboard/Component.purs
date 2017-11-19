module Dashboard.Component where

import Prelude

import Dashboard.Model (PipelineRow, createdDateTime)
import Dashboard.View (formatPipeline)
import Data.Array (elem, filter, reverse, sortWith, take)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP

type State = Array PipelineRow

data Query a = UpsertProjectPipelines (Array PipelineRow) a


ui :: forall m. H.Component HH.HTML Query Unit Void m
ui =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    }
  where

  initialState :: State
  initialState = []

  render :: State -> H.ComponentHTML Query
  render pipelines =
    HH.table
      [ HP.classes [ H.ClassName "table"
                  , H.ClassName "table-inverse"
                  ]
      ]
      [ HH.thead_
          [ HH.tr_ [ HH.th_ [ HH.text "Status" ]
                   , HH.th_ [ HH.text "Repo" ]
                   , HH.th_ [ HH.text "Commit" ]
                   , HH.th_ [ HH.text "Stages" ]
                   , HH.th_ [ HH.text "Time" ]
                   ]
          ]
      , HH.tbody_ $ map formatPipeline pipelines
      ]

  eval :: Query ~> H.ComponentDSL State Query Void m
  eval = case _ of
    UpsertProjectPipelines pipelines next -> do
      state <- H.get
      H.put
        $ take 40
        $ reverse
        $ sortWith createdDateTime
        -- Always include the pipelines passed as new data.
        -- Filter out of the state the pipelines that we have in the new data,
        -- and merge the remaining ones to get the new state.
        $ pipelines <> filter (\pr -> not $ elem pr.id (map _.id pipelines)) state
      pure next
