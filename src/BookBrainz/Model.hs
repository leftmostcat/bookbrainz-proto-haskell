module BookBrainz.Model
       ( Model
       , query
       , model
       , modelIO
       ) where

import BookBrainz.Types.MVC
import Data.Map (Map)
import Database.HDBC (fetchAllRowsMap, prepare, execute, SqlValue)

import           Control.Monad.Reader

-- | Run a model action.
model :: Model a -> Controller a
model action = do
  conn <- asks controllerStateConn
  liftIO $ runReaderT (runModel action) $ ModelState conn

query :: String -> [SqlValue] -> Model [Map String SqlValue]
query queryString bind = do
  conn <- env modelStateConn
  modelIO $ do
    stmt <- prepare conn queryString
    execute stmt bind
    fetchAllRowsMap stmt

modelIO :: IO a -> Model a
modelIO action = Model $ ReaderT (\_ -> action)

env :: MonadReader env m => (env -> val) -> m val
env = asks
