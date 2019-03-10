module Counter where

import Control.Monad.State

newtype Counter = MkCounter {cValue :: Integer}
  deriving (Show)

-- | 'inc c n' increments the counter by 'n' units.
zeroCounter :: Counter
zeroCounter = MkCounter 0

inc :: Counter -> Integer -> Counter
inc (MkCounter c) n = MkCounter (c + n)

-- | Unwrap the integer of Counter
cnt :: Counter -> Integer
cnt (MkCounter c) = c

-- | Increment the counter by 'n' units.
incS :: Integer -> State Counter ()
incS n = modify (\c -> inc c n)

-- | Get the inner state of State Counter monad instance
getS :: State Counter () -> Integer
getS = cnt . snd . (flip runState) zeroCounter

-- | zeroState
zeroState :: State Counter ()
zeroState = incS 0

-- | Example of mutation using the monadic counter
mutation :: Integer -> State Counter ()
mutation n
  | n <= 0 = zeroState
  | otherwise  = incS 1 >> (mutation (n - 1))


main :: IO ()
main = print $ getS $ mutation 30
