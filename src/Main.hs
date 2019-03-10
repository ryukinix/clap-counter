{-# LANGUAGE OverloadedStrings #-}
import Web.Scotty
import qualified Counter as C
import qualified Data.Text.Lazy as L

counterText :: C.CounterState () -> L.Text
counterText = L.pack . show . C.getS

getCounter :: C.CounterState () ->  ActionM ()
getCounter cs = html $ L.concat [counterText cs, "\n"]


counterAPI :: C.CounterState () -> ScottyM ()
counterAPI cs = do
  get "/" $ do
    getCounter cs
  post "/" $ do
    getCounter $ C.incS1 cs


main :: IO ()
main = scotty 3000 $ counterAPI C.zeroState
