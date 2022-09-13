module Routing.Hash.Link where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Ref (new, read, write)
import Routing.Duplex (RouteDuplex', parse, print)
import Routing.Hash (setHash)
import Routing.Hash as RH

matchesWith :: forall a. RouteDuplex' a -> (Maybe a -> a -> Effect Unit) -> Effect { unsubscribe :: Effect Unit, navigateTo :: a -> Effect Unit }
matchesWith router cb = do
  stashNew <- new Nothing
  stashPrev <- new Nothing
  let
    navigateTo a = do
      write (Just a) stashNew
      setHash (print router a)
  unsubscribe <- RH.matchesWith (parse router) \old new -> do
    stashedNew <- read stashNew
    stashedPrev <- read stashPrev
    write stashedNew stashPrev
    case stashedPrev, stashedNew of
      Nothing, Nothing -> cb old new
      Just cheatingPrev, Just cheatingNew -> cb (Just cheatingPrev) cheatingNew
      Nothing, Just cheatingNew -> cb old cheatingNew
      Just cheatingPrev, Nothing -> cb (Just cheatingPrev) new
  pure { unsubscribe, navigateTo }
