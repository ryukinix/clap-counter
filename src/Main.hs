{-# LANGUAGE OverloadedStrings,GeneralizedNewtypeDeriving #-}

import Prelude
import Control.Concurrent.STM
import Control.Monad.Reader
import Data.String
import Data.Text.Lazy (Text)

import Network.Wai.Middleware.RequestLogger
import Web.Scotty.Trans

import Counter

import Data.Default.Class

-- HACK: this should be defined in Counter.hs now the compiler warns
-- as orphan instance.  However if I put this at Counter.hs the `def`
-- variable will not be visible to this scope.
instance Default Counter where
    def = MkCounter 0

-- Why 'ReaderT (TVar AppState)' rather than 'StateT C.Counter'?
-- With a state transformer, 'runActionToIO' (below) would have
-- to provide the state to _every action_, and save the resulting
-- state, using an MVar. This means actions would be blocking,
-- effectively meaning only one request could be serviced at a time.
-- The 'ReaderT' solution means only actions that actually modify
-- the state need to block/retry.
--
-- Also note: your monad must be an instance of 'MonadIO' for
-- Scotty to use it.
newtype WebM a = WebM { runWebM :: ReaderT (TVar Counter) IO a }
    deriving (Applicative, Functor, Monad, MonadIO, MonadReader (TVar Counter))

-- Scotty's monads are layered on top of our custom monad.
-- We define this synonym for lift in order to be explicit
-- about when we are operating at the 'WebM' layer.
webM :: MonadTrans t => WebM a -> t WebM a
webM = lift

-- Some helpers to make this feel more like a state monad.
gets :: (Counter -> b) -> WebM b
gets f = ask >>= liftIO . readTVarIO >>= return . f

modify :: (Counter -> Counter) -> WebM ()
modify f = ask >>= liftIO . atomically . flip modifyTVar' f


counterAPI :: ScottyT Text WebM ()
counterAPI = do
  middleware logStdoutDev
  get "/v1/claps/" $ do
    c <- webM $ gets cValue
    text $ fromString $ (show c ++ "\n")
  post "/v1/claps/" $ do
    webM $ modify $ \ st -> st { cValue = cValue st + 1 }
    c <- webM $ gets cValue
    text $ fromString $ (show c ++ "\n")



main :: IO ()
main = do
    sync <- newTVarIO def
    -- 'runActionToIO' is called once per action.
    let runActionToIO m = runReaderT (runWebM m) sync

    scottyT 3000 runActionToIO counterAPI
