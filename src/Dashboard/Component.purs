module Dashboard.Component where

import Prelude

import Dashboard.Model (PipelineRow, createdDateTime, makeProjectRows)
import Dashboard.View (formatPipeline)
import Data.Array as Array
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (Aff, delay)
import Effect.Aff.Class (liftAff, class MonadAff)
import Effect.Class.Console (log)
import Gitlab as Gitlab
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP

type State = Array PipelineRow

data Query a = FetchProjects a

type Config =
  { baseUrl :: Gitlab.BaseUrl
  , token   :: Gitlab.Token
  }

ui :: forall input output m. MonadAff m => Config -> H.Component Query input output m
ui { baseUrl, token } =
  H.mkComponent
    { initialState: const initialState
    , render
    , eval: H.mkEval H.defaultEval {handleQuery = handleQuery}
    --, receive: const Nothing
    }
  where

  initialState :: State
  initialState = []

  render :: forall action. State -> H.ComponentHTML action () m
  render pipelines =
    HH.table
      [ HP.classes [ H.ClassName "table"
                  , H.ClassName "table-dark"
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

  --eval :: forall a m. Query a -> H.HalogenM State Query Unit Void Aff
  handleQuery :: forall a action s o m0. MonadAff m0 => Query a -> H.HalogenM State action s o m0 (Maybe a)
  handleQuery (FetchProjects next) = Just next <$ do
    projects <- liftAff getProjects
    for_ projects \project -> do
      jobs <- liftAff do
        delay (Milliseconds 1000.0)
        getJobs project
      H.modify $ upsertProjectPipelines jobs

  getProjects :: Aff Gitlab.Projects
  getProjects = do
    log "Fetching list of projects..."
    Gitlab.getProjects baseUrl token

  getJobs :: Gitlab.Project -> Aff Gitlab.Jobs
  getJobs project@{ id: Gitlab.ProjectId pid } = do
    log $ "Fetching Jobs for Project with id: " <> show pid
    Gitlab.getJobs baseUrl token project

  upsertProjectPipelines :: Gitlab.Jobs -> State -> State
  upsertProjectPipelines jobs =
    Array.take 40
      <<< Array.reverse
      <<< Array.sortWith createdDateTime
      -- Always include the pipelines passed as new data.
      -- Filter out of the state the pipelines that we have in the new data,
      -- and merge the remaining ones to get the new state.
      <<< (pipelines <> _)
      <<< Array.filter (\pr -> not $ Array.elem pr.id (map _.id pipelines))
    where
      pipelines = makeProjectRows jobs

